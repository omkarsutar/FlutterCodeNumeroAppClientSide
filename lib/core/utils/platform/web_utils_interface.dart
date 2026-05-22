export 'web_utils_interface.dart';

abstract class WebUtils {
  /// Cleans up URL query parameters (code, state, etc.) after Google login redirect on web.
  void cleanUrlParameters();

  /// Gets the current URL's UTM source parameter on web.
  String? getUtmSource();

  /// Gets the full UTM query string from the URL on web (e.g. utm_source=x&utm_medium=y&utm_campaign=z).
  String? getFullUtmParams();

  /// Logs memory diagnostics on web.
  void logMemoryDiagnostics();
}
