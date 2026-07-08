class NativeUpdateService {
  static bool get supportsImmediateUpdate => false;

  static Future<bool> performImmediateUpdateIfAvailable() async => false;

  static Future<void> openStoreListing(String packageName) async {}
}
