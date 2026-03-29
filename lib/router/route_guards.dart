import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_supabase_order_app_mobile/core/providers/app_config_provider.dart';
import 'package:flutter_supabase_order_app_mobile/core/providers/core_providers.dart';
import 'package:flutter_supabase_order_app_mobile/core/providers/user_profile_state_provider.dart';
import 'package:flutter_supabase_order_app_mobile/core/routing/module_route_generator.dart';
import 'package:flutter_supabase_order_app_mobile/router/app_routes.dart';

class RouteGuardService {
  const RouteGuardService();

  Future<String?> handleRedirect(Ref ref, GoRouterState state) async {
    final vacationRedirect = _handleVacationMode(ref, state);
    if (vacationRedirect != null) return vacationRedirect;

    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final path = state.uri.path;
    final isAtRoot = path == AppRoute.welcome;
    final isAuthPage = path == AppRoute.login || path == AppRoute.signup;
    final isPublicRoute = path.startsWith('/cart');

    final pendingOrderRedirect = await _handlePendingOrderRedirect(
      isLoggedIn: isLoggedIn,
      isAuthPage: isAuthPage,
      isAtRoot: isAtRoot,
      state: state,
    );
    if (pendingOrderRedirect != null) return pendingOrderRedirect;

    final authRedirect = _handleAuthenticationRedirect(
      isLoggedIn: isLoggedIn,
      isAuthPage: isAuthPage,
      isAtRoot: isAtRoot,
      isPublicRoute: isPublicRoute,
      state: state,
      ref: ref,
    );
    if (authRedirect != null) return authRedirect;

    return _handlePermissionRedirect(
      isLoggedIn: isLoggedIn,
      state: state,
      ref: ref,
    );
  }

  String? _handleVacationMode(Ref ref, GoRouterState state) {
    final appConfig = ref.read(appConfigProvider).valueOrNull;
    if (appConfig != null && appConfig.vacationMode) {
      if (state.uri.path != AppRoute.vacation) {
        debugPrint('AppRouter: Vacation Mode active -> Redirecting to Vacation Screen');
        return AppRoute.vacation;
      }
      return null;
    }

    if (state.uri.path == AppRoute.vacation) {
      return AppRoute.welcome;
    }

    return null;
  }

  Future<String?> _handlePendingOrderRedirect({
    required bool isLoggedIn,
    required bool isAuthPage,
    required bool isAtRoot,
    required GoRouterState state,
  }) async {
    if (!isLoggedIn || (!isAuthPage && !isAtRoot)) return null;

    final prefs = await SharedPreferences.getInstance();
    final hasPendingOrder = prefs.containsKey('pending_order');
    debugPrint('[AppRouter] Checking for pending order in router: $hasPendingOrder');
    if (hasPendingOrder) {
      debugPrint('AppRouter: Pending order found -> Redirecting to Cart');
      return state.namedLocation(AppRoute.cartName);
    }
    return null;
  }

  String? _handleAuthenticationRedirect({
    required bool isLoggedIn,
    required bool isAuthPage,
    required bool isAtRoot,
    required bool isPublicRoute,
    required GoRouterState state,
    required Ref ref,
  }) {
    final rbacService = ref.read(rbacServiceProvider);
    final profile = ref.read(userProfileStateProvider).profile;
    final roleName = rbacService.roleName?.toLowerCase();
    final isGuest = roleName == 'guest';
    final isProfileReady =
        rbacService.isInitialized && (isGuest || profile?.preferredRouteId != null);

    debugPrint(
      'AppRouter: Redirect Check | LoggedIn: $isLoggedIn | Role: $roleName | Path: ${state.uri.path}',
    );

    if (!isLoggedIn && !isAuthPage && !isAtRoot && !isPublicRoute) {
      return state.namedLocation(AppRoute.birthdateAnalysisName);
    }

    if (!isLoggedIn && isAtRoot) {
      return state.namedLocation(AppRoute.birthdateAnalysisName);
    }

    if (isLoggedIn && (isAuthPage || isAtRoot)) {
      debugPrint('AppRouter: Handling Root/Auth Page Redirect for LoggedIn User');

      if (!isProfileReady && !rbacService.isInitialized) {
        debugPrint('AppRouter: Profile/RBAC not ready -> Loading');
        return AppRoute.loading;
      }

      if (rbacService.isInitialized && !isGuest && profile?.preferredRouteId == null) {
        debugPrint('AppRouter: Profile missing preferredRouteId -> Loading');
        return AppRoute.loading;
      }

      debugPrint('AppRouter: User role is $roleName');
      return state.namedLocation(AppRoute.birthdateAnalysisName);
    }

    return null;
  }

  String? _handlePermissionRedirect({
    required bool isLoggedIn,
    required GoRouterState state,
    required Ref ref,
  }) {
    final routeName = state.name ?? state.topRoute?.name;
    final rbacService = ref.read(rbacServiceProvider);
    final roleName = rbacService.roleName?.toLowerCase();

    debugPrint(
      'AppRouter: RBAC Permission Check | Path: ${state.uri.path} | RouteName: $routeName',
    );

    if (!isLoggedIn || routeName == null) return null;

    final permission = ModuleRouteRegistry.getRoutePermission(routeName);
    if (permission == null) {
      debugPrint('AppRouter: No RBAC permission found for route $routeName');
      return null;
    }

    final hasAccess = rbacService.hasPermission(
      permission.moduleId,
      permission.action,
    );

    debugPrint(
      'AppRouter: RBAC Check | Route: $routeName | Module: ${permission.moduleId} | Action: ${permission.action.name} | Role: $roleName | Allowed: $hasAccess',
    );

    if (!hasAccess) {
      debugPrint('AppRouter: Access denied for route $routeName -> Redirecting to unauthorized');
      return AppRoute.unauthorized;
    }

    return null;
  }
}

final routeGuardServiceProvider = Provider<RouteGuardService>((ref) {
  return const RouteGuardService();
});
