import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messagingServiceProvider = Provider<MessagingService>((ref) {
  return MessagingService(FirebaseMessaging.instance);
});

class MessagingService {
  final FirebaseMessaging _messaging;

  MessagingService(this._messaging);

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
              debugPrint('FCM Token: $token');
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
    } catch (e) {
      debugPrint('MessagingService: Error initializing Firebase Messaging: $e');
    }
  }

  /// Optional: Get current token for specific troubleshooting or manual targeting.
  Future<String?> getToken() => _messaging.getToken();
}
