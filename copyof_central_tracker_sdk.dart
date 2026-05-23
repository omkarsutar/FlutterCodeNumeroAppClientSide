import 'dart:convert';
import 'dart:io';
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
    // 1. Guard clause: Ensure execution happens strictly on physical Android environments
    if (kIsWeb || !Platform.isAndroid) return;

    final prefs = await SharedPreferences.getInstance();

    try {
      // 2. Query the native Google Play Services AIDL client channel
      ReferrerDetails details = await PlayInstallReferrer.installReferrer;
      String? incomingReferrer = details.installReferrer;

      // Robust fallback check: Normalize if organic reach or un-tracked store entries occur
      bool isOrganicOrNull = incomingReferrer == null ||
          incomingReferrer.isEmpty ||
          incomingReferrer.contains('utm_source=(not%20set)');

      if (isOrganicOrNull) {
        incomingReferrer =
            'utm_source=organic&utm_medium=direct&utm_campaign=none';
      }

      // 3. FIRST-TOUCH HANDLING (Locks in on the very first boot of the application)
      final isFirstTouchLogged =
          prefs.getBool('sdk_first_touch_locked') ?? false;
      if (!isFirstTouchLogged) {
        await prefs.setString(
            'second_touch_source', incomingReferrer); // Match initially
        await prefs.setString('first_touch_source', incomingReferrer);

        // Asynchronously report the initial app download event to your central installations schema
        final response = await http.post(
          Uri.parse(_trackInstallUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'package_name': _packageName,
            'referrer_raw': incomingReferrer,
            'click_time': isOrganicOrNull
                ? DateTime.now().millisecondsSinceEpoch ~/ 1000
                : details.referrerClickTimestampSeconds,
          }),
        );

        // Only lock the first-touch state if the server actually acknowledged it successfully
        if (response.statusCode == 200) {
          await prefs.setBool('sdk_first_touch_locked', true);
        } else {
          print(
              "SDK Server warning: ${response.statusCode} - ${response.body}");
        }
        return;
      }

      // 4. SECOND-TOUCH RETARGETING HANDLING (Overwrites on subsequent opens if driven by a paid campaign)
      bool isIncomingOrganic = incomingReferrer.contains('utm_source=organic');
      if (!isIncomingOrganic) {
        await prefs.setString('second_touch_source', incomingReferrer);
      }
    } catch (e) {
      print("Central Tracking SDK Pipeline Exception: $e");
    }
  }

  /// Securely queries your database to validate promo codes before letting the user reach the gateway.
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
