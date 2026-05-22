import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_providers.dart';
import 'user_profile_state_provider.dart';
import '../models/app_remote_config.dart';
import '../services/logger_service.dart';
import '../services/connectivity_service.dart';
import '../services/error_handler.dart';
import '../services/rbac_service.dart';
import '../services/razorpay_service.dart';
import '../interfaces/connectivity_service_interface.dart';
import '../config/razorpay_config.dart';

/// Provides the global Supabase client instance
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provides the logger service implementation
final loggerServiceProvider = Provider<LoggerService>((ref) {
  return LoggerServiceImpl();
});

/// Provides the error handler service
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  final logger = ref.watch(loggerServiceProvider);
  return ErrorHandler(logger);
});

/// Provides the instance of [IConnectivityService].
final connectivityServiceProvider = Provider<IConnectivityService>((ref) {
  return ConnectivityServiceImpl();
});

/// Provides the RBAC service instance
final rbacServiceProvider = Provider<RbacService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final errorHandler = ref.watch(errorHandlerProvider);

  return RbacService(client, connectivityService, errorHandler);
});

/// Provides the initialization state of the RBAC system
final rbacInitializationProvider = StateProvider<bool>((ref) {
  final rbacService = ref.watch(rbacServiceProvider);

  // Update state when notifier changes
  void listener() {
    ref.controller.state = rbacService.initializationNotifier.value;
  }

  rbacService.initializationNotifier.addListener(listener);

  // Clean up listener when provider is disposed
  ref.onDispose(
    () => rbacService.initializationNotifier.removeListener(listener),
  );

  return rbacService.initializationNotifier.value;
});

/// Provides the current user's role name
final roleNameProvider = Provider<String?>((ref) {
  // 1. Try RBAC service initialization state
  final rbac = ref.watch(rbacServiceProvider);
  final isReady = ref.watch(rbacInitializationProvider);
  if (isReady && rbac.roleName != null) return rbac.roleName;

  // 2. Try enriched profile (resolve labels)
  final enriched = ref.watch(enrichedUserProfileProvider).value;
  if (enriched != null) {
    final label = enriched.resolvedLabels['role_id_label'];
    if (label != null && label.isNotEmpty) return label;
    if (enriched.roleId != null) return enriched.roleId;
  }

  // 3. Try standard profile state
  final profile = ref.watch(userProfileStateProvider).profile;
  return profile?.roleId;
});

/// Fetches app remote configuration (pricing, Razorpay key) from Supabase
/// based on the runtime package name. Falls back gracefully on error.
final appRemoteConfigProvider = FutureProvider<AppRemoteConfig>((ref) async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;

    final client = ref.read(supabaseClientProvider);
    final response = await client
        .from('app_remote_configs')
        .select()
        .eq('package_name', packageName)
        .maybeSingle();

    if (response != null) {
      return AppRemoteConfig.fromMap(response);
    }

    debugPrint('AppRemoteConfig: No config found for $packageName, using fallback.');
    return AppRemoteConfig.fallback();
  } catch (e) {
    debugPrint('AppRemoteConfig: Failed to fetch config: $e');
    return AppRemoteConfig.fallback();
  }
});

/// Provides the Razorpay service instance
final razorpayServiceProvider = Provider<RazorpayService>((ref) {
  return RazorpayService(apiKey: RazorpayConfig.apiKey);
});
