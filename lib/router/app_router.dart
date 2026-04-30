import '../features/postLogin/notifications/ui/notification_admin_page.dart';
import '../features/postLogin/purchase_orders/ui/purchase_order_list_page.dart';
import 'package:flutter_supabase_order_app_mobile/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/entity_meta.dart';

import '../features/postLogin/loading_page/loading_page.dart';
import '../features/preLogin/welcome_page.dart';
import '../features/auth/auth_page.dart';
import '../features/postLogin/cart/cart_barrel.dart';
import '../features/postLogin/birthdate_analysis/ui/birthdate_analysis_page.dart';
import '../shared/widgets/shared_widget_barrel.dart';
import '../features/postLogin/vacation_mode/vacation_mode_screen.dart';
import '../core/routing/module_route_generator.dart';
import '../core/services/rbac_service.dart';
import '../core/models/route_permission.dart';
import 'route_guards.dart';
import '../core/services/analytics_service.dart';

import '../core/globals.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Register permissions for non-generic modules
  ModuleRouteRegistry.registerRoutePermission(
    AppRoute.birthdateAnalysisName,
    RoutePermission(moduleId: 'birthdate_analysis', action: RbacAction.read),
  );

  ModuleRouteRegistry.registerRoutePermission(
    AppRoute.notificationAdminName,
    RoutePermission(moduleId: 'notification_admin', action: RbacAction.read),
  );

  return GoRouter(
    navigatorKey: navigatorKey,
    routes: [
      ...authRoutes,
      GoRoute(
        path: AppRoute.purchaseOrders,
        name: AppRoute.purchaseOrdersName,
        builder: (context, state) {
          return PurchaseOrdersPage(
            entityMeta: EntityMeta(
              entityName: 'Purchase Order',
              entityNamePlural: 'Purchase Orders',
              entityNameLower: 'purchase order',
              entityNamePluralLower: 'purchase orders',
            ),
            idField: 'po_id',
            fieldConfigs: [],
            timestampField: 'created_at',
            viewRouteName: 'purchase-order-view',
            newRouteName: 'purchase-order-new',
            rbacModule: 'purchase_order',
            searchFields: ['po_id', 'status'],
          );
        },
      ),
    ],
    observers: [ref.read(analyticsServiceProvider).getObserver()],
    initialLocation: AppRoute.welcome,
    redirect: (context, state) {
      final path = state.uri.path;
      // Handle GitHub Pages sub-path prefixing issues on redirect
      if (path.startsWith('/NumeroShastraV01')) {
        final newPath = path.replaceFirst('/NumeroShastraV01', '');
        return newPath.isEmpty ? '/' : newPath;
      }
      return ref.read(routeGuardServiceProvider).handleRedirect(ref, state);
    },
  );
});

final List<RouteBase> authRoutes = [
  GoRoute(
    path: AppRoute.loading,
    builder: (context, state) => const LoadingPage(),
  ),
  GoRoute(
    name: AppRoute.welcomeName,
    path: AppRoute.welcome,
    builder: (context, state) => const WelcomePage(),
  ),
  GoRoute(
    name: AppRoute.loginName,
    path: AppRoute.login,
    builder: (context, state) => const AuthPage(),
  ),
  GoRoute(
    name: AppRoute.signupName,
    path: AppRoute.signup,
    builder: (context, state) => const AuthPage(),
  ),
  GoRoute(
    name: AppRoute.profileName,
    path: AppRoute.profile,
    builder: (context, state) => const UserProfilePage(),
  ),
  GoRoute(
    name: AppRoute.cartName,
    path: AppRoute.cart,
    builder: (context, state) => const CartPage(),
  ),
  GoRoute(
    name: AppRoute.birthdateAnalysisName,
    path: AppRoute.birthdateAnalysis,
    builder: (context, state) => const BirthdateAnalysisPage(),
  ),
  GoRoute(
    name: AppRoute.notificationAdminName,
    path: AppRoute.notificationAdmin,
    builder: (context, state) => const NotificationAdminPage(),
  ),
  GoRoute(
    name: AppRoute.unauthorizedName,
    path: AppRoute.unauthorized,
    builder: (context, state) => const UnauthorizedPage(),
  ),
  GoRoute(
    name: AppRoute.vacationName,
    path: AppRoute.vacation,
    builder: (context, state) => const VacationModeScreen(),
  ),
];
