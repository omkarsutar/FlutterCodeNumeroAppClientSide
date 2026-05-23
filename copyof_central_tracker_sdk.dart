/* import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CentralTrackerSDK {
  static late final String _packageName;
  static late final String _trackInstallUrl;
  static late final String _validateCodeUrl;

  /// Initializes the centralized SDK engine with your target cloud endpoint links.
  static void initialize({
    required String packageName,
    required String trackInstallUrl,
    required String validateCodeUrl,
  }) {
    _packageName = packageName;
    _trackInstallUrl = trackInstallUrl;
    _validateCodeUrl = validateCodeUrl;
  }

  /// Automatically monitors store install intents and manages multi-touch SharedPreferences slots safely.
  static Future<void> trackInstallation() async {
    final prefs = await SharedPreferences.getInstance();
    String? incomingReferrer;
    int clickTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    try {
      // 1. Priority 1: Check for Incoming Deep Link or Web URL parameters (Most Reliable for Test/Marketing)
      final initialRoute = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
      if (initialRoute.contains('utm_source=')) {
        // Normalize route for parsing
        final uri = Uri.parse(initialRoute.startsWith('/') ? initialRoute : '/$initialRoute');
        final utmParams = uri.queryParameters.entries
            .where((e) => e.key.startsWith('utm_'))
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        
        if (utmParams.isNotEmpty) {
          incomingReferrer = utmParams;
          debugPrint('CentralTracker: Captured from Initial Link: $utmParams');
        }
      }
    } catch (e) {
      debugPrint('CentralTracker: Deep link parse error: $e');
    }

    // 2. Priority 2: Query Play Install Referrer (Android Only)
    if (incomingReferrer == null && !kIsWeb && Platform.isAndroid) {
      try {
        ReferrerDetails details = await PlayInstallReferrer.installReferrer;
        incomingReferrer = details.installReferrer;
        if (details.referrerClickTimestampSeconds > 0) {
          clickTime = details.referrerClickTimestampSeconds;
        }
      } catch (e) {
        debugPrint('CentralTracker: Play Referrer Error: $e');
      }
    }

    // 3. Normalize Result
    bool isOrganicOrNull = incomingReferrer == null ||
        incomingReferrer.isEmpty ||
        incomingReferrer.contains('utm_source=(not%20set)') ||
        incomingReferrer.contains('utm_source=organic');

    if (isOrganicOrNull) {
      if (kIsWeb) {
        incomingReferrer = 'utm_source=web&utm_medium=direct&utm_campaign=none';
      } else {
        incomingReferrer = 'utm_source=organic&utm_medium=direct&utm_campaign=none';
      }
    }

    // 4. FIRST-TOUCH HANDLING (Locks in on the very first boot of the application)
    final isFirstTouchLogged = prefs.getBool('sdk_first_touch_locked') ?? false;
    if (!isFirstTouchLogged) {
      await prefs.setString('second_touch_source', incomingReferrer!);
      await prefs.setString('first_touch_source', incomingReferrer);

      try {
        // Report initial app download event
        final response = await http.post(
          Uri.parse(_trackInstallUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'package_name': _packageName,
            'referrer_raw': incomingReferrer,
            'click_time': clickTime,
          }),
        );

        if (response.statusCode == 200) {
          await prefs.setBool('sdk_first_touch_locked', true);
        } else {
          debugPrint("CentralTracker: Server warning: ${response.statusCode} - ${response.body}");
        }
      } catch (e) {
        debugPrint("CentralTracker: Network error reporting install: $e");
      }
      return;
    }

    // 5. SECOND-TOUCH RETARGETING HANDLING (Overwrites if driven by a paid campaign)
    bool isIncomingOrganic = incomingReferrer!.contains('utm_source=organic') || 
                             incomingReferrer.contains('utm_source=web') ||
                             incomingReferrer.contains('utm_source=app');

    if (!isIncomingOrganic) {
      await prefs.setString('second_touch_source', incomingReferrer);
      debugPrint('CentralTracker: Second touch updated: $incomingReferrer');
    }
  }

  /// Securely queries your database to validate promo codes.
  static Future<Map<String, dynamic>> verifyPromoCode(String typedCode) async {
    try {
      final response = await http.post(
        Uri.parse(_validateCodeUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': typedCode}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {
          'valid': false,
          'message': 'Validation gateway verification failed.'
        };
      }
    } catch (e) {
      return {
        'valid': false,
        'message': 'Network connectivity lookup timeout: $e'
      };
    }
  }
}
 */
