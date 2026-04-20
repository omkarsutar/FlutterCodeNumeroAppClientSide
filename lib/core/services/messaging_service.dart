import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/core_providers.dart';
import '../../features/postLogin/users/user_barrel.dart';

final messagingServiceProvider = Provider<MessagingService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return MessagingService(FirebaseMessaging.instance, client);
});

class MessagingService {
  final FirebaseMessaging _messaging;
  final SupabaseClient _supabase;

  MessagingService(this._messaging, this._supabase);
  StreamSubscription<AuthState>? _authSubscription;

  /// Initialize messaging settings and request permissions.
  Future<void> initialize() async {
    debugPrint('MessagingService: Starting initialization...');
    try {
      // Request permissions for iOS and newer Android versions.
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('MessagingService: requestPermission timed out after 5s');
          return const NotificationSettings(
            alert: AppleNotificationSetting.notSupported,
            announcement: AppleNotificationSetting.notSupported,
            authorizationStatus: AuthorizationStatus.notDetermined,
            badge: AppleNotificationSetting.notSupported,
            carPlay: AppleNotificationSetting.notSupported,
            lockScreen: AppleNotificationSetting.notSupported,
            notificationCenter: AppleNotificationSetting.notSupported,
            showPreviews: AppleShowPreviewSetting.notSupported,
            sound: AppleNotificationSetting.notSupported,
            criticalAlert: AppleNotificationSetting.notSupported,
            timeSensitive: AppleNotificationSetting.notSupported,
            providesAppNotificationSettings: AppleNotificationSetting.notSupported,
          );


        },
      );

      debugPrint('MessagingService: Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized || 
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        
        // Get the token for this device (skip on web if not explicitly configured with VAPID)
        if (!kIsWeb) {
          debugPrint('MessagingService: Attempting to retrieve FCM Token...');
          try {
            // Add a timeout to prevent hanging on app startup
            final token = await _messaging.getToken().timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                debugPrint('MessagingService: FCM Token retrieval timed out after 10 seconds');
                return null;
              },
            );
            if (token != null) {
              debugPrint('FCM Token retrieved successfully');
              await _syncTokenToDatabase(token);
            } else {
              debugPrint('MessagingService: Token received was null');
            }
          } catch (e) {
            debugPrint('MessagingService: Error getting FCM token: $e');
          }
        } else {
          debugPrint('MessagingService: Token retrieval skipped on Web (requires VAPID key configuration)');
        }
      } else {
        debugPrint('MessagingService: Token retrieval skipped due to insufficient permissions');
      }

      // Handle incoming messages while the app is in the foreground.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('MessagingService: Received foreground message: ${message.notification?.title}');
      });

      // Handle token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        debugPrint('MessagingService: FCM Token refreshed');
        _syncTokenToDatabase(newToken);
      });

      // Handle auth state changes to sync token on login
      _authSubscription?.cancel();
      _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.signedIn) {
          debugPrint('MessagingService: User signed in, triggering token sync');
          syncCurrentToken();
        }
      });
    } catch (e) {
      debugPrint('MessagingService: Error initializing Firebase Messaging: $e');
    }
  }

  /// Manually trigger a sync of the current FCM token to the database.
  Future<void> syncCurrentToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _syncTokenToDatabase(token);
      }
    } catch (e) {
      debugPrint('MessagingService: Error during manual token sync: $e');
    }
  }

  /// Syncs the token to the Supabase users table if a user is logged in.
  Future<void> _syncTokenToDatabase(String token) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('MessagingService: No authenticated user, skipping token sync');
      return;
    }

    try {
      debugPrint('MessagingService: Syncing FCM token for user ${user.id}...');
      await _supabase
          .from(ModelUserFields.table)
          .update({ModelUserFields.fcmToken: token})
          .eq(ModelUserFields.userId, user.id);
      debugPrint('MessagingService: FCM token synced successfully');
    } catch (e) {
      debugPrint('MessagingService: Error syncing FCM token to database: $e');
    }
  }

  /// Optional: Get current token for specific troubleshooting or manual targeting.
  Future<String?> getToken() => _messaging.getToken();

  void dispose() {
    _authSubscription?.cancel();
  }
}
