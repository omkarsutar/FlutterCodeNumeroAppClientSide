import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../constants/app_constants.dart';
import 'auth_providers.dart';
import 'user_profile_state_provider.dart';
import '../models/app_remote_config.dart';
import '../services/logger_service.dart';
import '../services/connectivity_service.dart';
import '../services/error_handler.dart';
import '../services/rbac_service.dart';
import '../services/razorpay_service.dart';
import '../interfaces/connectivity_service_interface.dart';

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

/// Debug info for remote config resolution path on device.
final appRemoteConfigDebugInfoProvider = StateProvider<String>((ref) {
  return 'NOT_FETCHED';
});

/// Fetches app remote configuration (pricing, Razorpay key) from Supabase
/// based on the runtime package name. Falls back gracefully on error.
final appRemoteConfigProvider = FutureProvider<AppRemoteConfig>((ref) async {
  const cacheKey = 'app_remote_config_cache_v1';

  Future<void> persistConfig(Map<String, dynamic> row) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, jsonEncode(row));
    } catch (_) {}
  }

  Future<AppRemoteConfig?> readCachedConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(cacheKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AppRemoteConfig.fromMap(decoded);
      }
    } catch (_) {}
    return null;
  }

  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName.trim();
    
    // Log the start of the request
    ref.read(appRemoteConfigDebugInfoProvider.notifier).state = 
        'FETCHING runtime=$packageName';

    final client = ref.read(supabaseClientProvider);

    // Strategy 1: Exact match on current package name (Highest Priority)
    final primaryRow = await client
        .from('app_remote_configs')
        .select()
        .eq('package_name', packageName)
        .maybeSingle();

    if (primaryRow != null) {
      await persistConfig(primaryRow);
      final config = AppRemoteConfig.fromMap(primaryRow);
      ref.read(appRemoteConfigDebugInfoProvider.notifier).state =
          'LIVE_MATCH row=${config.packageName} price=${config.numerologyPriceInr}';
      return config;
    }

    // Strategy 2: Match on base package name (if current is .debug)
    final basePackage = packageName.replaceAll('.debug', '');
    if (basePackage != packageName) {
      final secondaryRow = await client
          .from('app_remote_configs')
          .select()
          .eq('package_name', basePackage)
          .maybeSingle();

      if (secondaryRow != null) {
        await persistConfig(secondaryRow);
        final config = AppRemoteConfig.fromMap(secondaryRow);
        ref.read(appRemoteConfigDebugInfoProvider.notifier).state =
            'LIVE_BASE row=${config.packageName} price=${config.numerologyPriceInr}';
        return config;
      }
    }

    // Strategy 3: Try AppConstants.appPackageName
    if (AppConstants.appPackageName != packageName) {
       final constRow = await client
          .from('app_remote_configs')
          .select()
          .eq('package_name', AppConstants.appPackageName)
          .maybeSingle();

      if (constRow != null) {
        await persistConfig(constRow);
        final config = AppRemoteConfig.fromMap(constRow);
        ref.read(appRemoteConfigDebugInfoProvider.notifier).state =
            'LIVE_CONST row=${config.packageName} price=${config.numerologyPriceInr}';
        return config;
      }
    }

    // Strategy 4: Fallback to the latest updated row in the table
    final latestRow = await client
        .from('app_remote_configs')
        .select()
        .order('updated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (latestRow != null) {
      await persistConfig(latestRow);
      final config = AppRemoteConfig.fromMap(latestRow);
      ref.read(appRemoteConfigDebugInfoProvider.notifier).state =
          'LIVE_LATEST row=${config.packageName} price=${config.numerologyPriceInr}';
      return config;
    }

    // Strategy 5: Use cached data if available
    final cached = await readCachedConfig();
    if (cached != null) {
      ref.read(appRemoteConfigDebugInfoProvider.notifier).state =
          'CACHE row=${cached.packageName} price=${cached.numerologyPriceInr}';
      return cached;
    }

    // Ultimate fallback (The Hardcoded 299)
    ref.read(appRemoteConfigDebugInfoProvider.notifier).state = 'FALLBACK_299 no_rows';
    debugPrint('AppRemoteConfig: No rows found in DB for $packageName, using fallback.');
    return AppRemoteConfig.fallback();

  } catch (e, st) {
    debugPrint('AppRemoteConfig: Error fetching: $e\n$st');
    
    final cached = await readCachedConfig();
    if (cached != null) {
      ref.read(appRemoteConfigDebugInfoProvider.notifier).state =
          'CACHE_ERROR err=$e';
      return cached;
    }
    
    ref.read(appRemoteConfigDebugInfoProvider.notifier).state = 'FALLBACK_299 error=$e';
    return AppRemoteConfig.fallback();
  }
});


/// Provides the Razorpay service instance
final razorpayServiceProvider = Provider<RazorpayService>((ref) {
  // Base key intentionally left empty; runtime key is passed dynamically
  // from appRemoteConfigProvider during checkout.
  return RazorpayService(apiKey: '');
});
