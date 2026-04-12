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

  /// Log when an analysis is viewed for a specific birthdate.
  Future<void> logAnalysisView(DateTime birthdate) async {
    await _analytics.logEvent(
      name: 'analysis_viewed',
      parameters: {
        'birthdate': birthdate.toIso8601String(),
        'day': birthdate.day,
        'month': birthdate.month,
        'year': birthdate.year,
      },
    );
  }

  /// Log cart interactions (add, remove, select).
  Future<void> logCartAction(String action, {Map<String, Object>? parameters}) async {
    await _analytics.logEvent(
      name: 'cart_action',
      parameters: {
        'action_type': action,
        ...?parameters,
      },
    );
  }

  /// Log payment lifecycle events.
  Future<void> logPaymentEvent({
    required String status,
    double? amount,
    int? itemCount,
    String? error,
  }) async {
    await _analytics.logEvent(
      name: 'payment_lifecycle',
      parameters: {
        'status': status,
        if (amount != null) 'amount': amount,
        if (itemCount != null) 'item_count': itemCount,
        if (error != null) 'error_message': error,
      },
    );
  }
}
