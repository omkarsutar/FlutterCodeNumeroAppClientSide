import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/platform/web_utils.dart';
import '../providers/user_profile_state_provider.dart';
import '../providers/localization_provider.dart';

import '../providers/core_providers.dart';
import '../../features/postLogin/users/user_barrel.dart';
import '../constants/app_constants.dart';
import '../exceptions/app_exceptions.dart';
import '../interfaces/connectivity_service_interface.dart';
import 'rbac_service.dart';
import 'error_handler.dart';
import 'analytics_service.dart';

class AuthService {
  final SupabaseClient _client;
  final RbacService _rbacService;
  final IConnectivityService _connectivityService;
  final ErrorHandler _errorHandler;
  final Ref _ref;
  StreamSubscription<List<Map<String, dynamic>>>? _profileSubscription;

  AuthService(
    this._client,
    this._rbacService,
    this._connectivityService,
    this._errorHandler,
    this._ref,
  );

  /// Sign in with Google and load user profile
  Future<void> signInWithGoogle() async {
    final String redirectUri;
    if (kIsWeb) {
      redirectUri = kReleaseMode
          ? AppConstants.webAppProdUrl
          : AppConstants.webAppLocalUrl;
    } else {
      redirectUri = AppConstants.mobileRedirectUri;
    }

    try {
      if (!await _connectivityService.isOnline()) {
        throw NoInternetException();
      }
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUri,
      );
    } catch (e, stackTrace) {
      _errorHandler.handle(
        e,
        stackTrace,
        context: 'Google Sign-In',
        showToUser: true,
      );
      rethrow;
    }
  }

  /// Listen for auth state changes and keep profile in sync
  void initializeAuthListener() {
    _client.auth.onAuthStateChange.listen((authState) async {
      switch (authState.event) {
        case AuthChangeEvent.signedIn:
          if (kIsWeb) {
            webUtils.cleanUrlParameters();
          }
          await loadAndStoreUserProfile();
          initializeUserProfileStream();
          break;
        case AuthChangeEvent.signedOut:
          _ref.read(analyticsServiceProvider).setUserId(null);
          disposeProfileStream();
          _ref.read(userProfileStateProvider.notifier).clearProfile();
          break;
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          // Keep profile fresh when token or user info changes
          await loadAndStoreUserProfile();
          break;
        default:
          break;
      }
    });
  }

  /// Load user profile from Supabase and store globally, then initialize RBAC
  Future<void> loadAndStoreUserProfile() async {
    try {
      if (!await _connectivityService.isOnline()) {
        throw NoInternetException();
      }
      final userId = _client.auth.currentUser?.id;
      debugPrint('[AuthService] Loading profile for userId: $userId');
      if (userId == null) throw Exception('User not logged in');

      final userData = await _client
          .from(ModelUserFields.table)
          .select('*')
          .eq(ModelUserFields.userId, userId)
          .single();

      debugPrint('[AuthService] Profile data fetched successfully');
      final profile = ModelUser.fromMap(userData);

      debugPrint('[AuthService] Initializing RBAC for userId: $userId');
      // Initialize RBAC for the logged-in user BEFORE marking profile as ready
      await _rbacService.initializeRbac(userId);
      debugPrint('[AuthService] RBAC initialized successfully');

      _ref.read(analyticsServiceProvider).setUserId(userId);
      _ref.read(userProfileStateProvider.notifier).setProfile(profile);
      debugPrint('[AuthService] Profile state updated');
    } catch (e, st) {
      _errorHandler.handle(
        e,
        st,
        context: 'Loading user profile',
        showToUser:
            e is! NoInternetException, // Don't show redundant offline toast
        logLevel: e is NoInternetException
            ? ErrorLogLevel.warning
            : ErrorLogLevel.error,
      );
    }
  }

  /// Subscribe to realtime updates for the current user's profile
  void initializeUserProfileStream() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    // Cancel any existing subscription
    _profileSubscription?.cancel();

    _profileSubscription = _client
        .from(ModelUserFields.table)
        .stream(primaryKey: [ModelUserFields.userId])
        .eq(ModelUserFields.userId, userId)
        .listen(
          (snapshot) {
            if (snapshot.isNotEmpty) {
              final updatedProfile = ModelUser.fromMap(snapshot.first);
              _ref
                  .read(userProfileStateProvider.notifier)
                  .setProfile(updatedProfile);
            }
          },
          onError: (error, stackTrace) {
            _ref
                .read(loggerServiceProvider)
                .error(
                  'Error in userProfileStream (AuthService): $error',
                  stackTrace is StackTrace ? stackTrace : null,
                );
          },
        );
  }

  /// Cancel profile stream subscription
  void disposeProfileStream() {
    _profileSubscription?.cancel();
    _profileSubscription = null;
  }

  /// Sign out the current user
  Future<void> signOut() async {
    _rbacService.clearCache();
    await _client.auth.signOut();
    _ref.read(analyticsServiceProvider).setUserId(null);
    disposeProfileStream();
    _ref.read(userProfileStateProvider.notifier).clearProfile();
  }

  /// Get the current Supabase user
  User? get currentUser => _client.auth.currentUser;

  /// Update the user's language preference in Supabase
  Future<void> updateUserLanguage(AppLanguage language) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final langCode = language == AppLanguage.hindi
        ? 'hi'
        : language == AppLanguage.marathi
        ? 'mr'
        : 'en';

    try {
      await _client
          .from(ModelUserFields.table)
          .update({ModelUserFields.userLanguage: langCode})
          .eq(ModelUserFields.userId, userId);
    } catch (e, st) {
      _errorHandler.handle(
        e,
        st,
        context: 'Updating user language',
        showToUser: true,
      );
    }
  }
}
