import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(FirebaseAnalytics.instance);
});

class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService(this._analytics);

  /// Log a custom click event.
  /// 
  /// [buttonName] is the name of the button or action performed.
  /// [parameters] provide additional context for the event.
  Future<void> logClickEvent(String buttonName, {Map<String, Object>? parameters}) async {
    await _analytics.logEvent(
      name: 'button_click',
      parameters: {
        'button_name': buttonName,
        ...?parameters,
      },
    );
  }

  /// Track a user's role if needed for better filtering.
  Future<void> setUserRole(String role) async {
    await _analytics.setUserProperty(name: 'user_role', value: role);
  }

  /// Utility to get the analytics observer for navigation tracking.
  FirebaseAnalyticsObserver getObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }
}
