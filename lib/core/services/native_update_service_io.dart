import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

class NativeUpdateService {
  static bool get supportsImmediateUpdate =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<bool> performImmediateUpdateIfAvailable() async {
    if (!supportsImmediateUpdate) return false;

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      final updateAvailable =
          updateInfo.updateAvailability == UpdateAvailability.updateAvailable;

      if (updateAvailable && updateInfo.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
        return true;
      }
    } catch (error) {
      debugPrint('NativeUpdateService: immediate update unavailable: $error');
    }

    return false;
  }

  static Future<void> openStoreListing(String packageName) async {
    if (!supportsImmediateUpdate) return;

    final marketUri = Uri.parse('market://details?id=$packageName');
    final webUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageName',
    );

    if (await canLaunchUrl(marketUri)) {
      await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      return;
    }

    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }
}
