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
    try {
      // Request permissions for iOS and newer Android versions.
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted push notification permission');
        
        // Get the token for this device (skip on web if not explicitly configured with VAPID)
        if (!kIsWeb) {
          final token = await _messaging.getToken();
          if (token != null) {
            debugPrint('FCM Token: $token');
          }
        } else {
          debugPrint('FCM Token retrieval skipped on Web (requires VAPID key configuration)');
        }
      } else {
        debugPrint('User declined or has not yet granted push notification permission');
      }

      // Handle incoming messages while the app is in the foreground.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Received foreground message: ${message.notification?.title}');
      });
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
    }
  }

  /// Optional: Get current token for specific troubleshooting or manual targeting.
  Future<String?> getToken() => _messaging.getToken();
}
