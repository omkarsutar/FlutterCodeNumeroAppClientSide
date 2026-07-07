import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:developer' as developer;

class RazorpayService {
  final Razorpay _razorpay = Razorpay();
  final String _apiKey;

  RazorpayService({required String apiKey}) : _apiKey = apiKey;

  void initialize({
    required Function(dynamic) onSuccess,
    required Function(dynamic) onFailure,
    required Function(dynamic) onExternalWallet,
  }) {
    onSuccess;
    onFailure;
    onExternalWallet;

    if (kIsWeb) {
      return;
    }

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      onSuccess as Function(PaymentSuccessResponse),
    );
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      onFailure as Function(PaymentFailureResponse),
    );
    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      onExternalWallet as Function(ExternalWalletResponse),
    );
  }

  void openCheckout({
    required String description,
    required double amount,
    required String contact,
    required String email,
    String? apiKey,
    String? orderId,
    Map<String, String>? notes,
  }) {
    if (kIsWeb) {
      developer.log('Razorpay checkout requested on web but native service was used.');
      return;
    }

    final options = {
      'key': apiKey ?? _apiKey,
      'amount': (amount * 100).toInt(),
      'name': 'Numero Shastra',
      'description': description,
      'timeout': 300,
      'prefill': {'contact': contact, 'email': email},
    };

    if (orderId != null && orderId.isNotEmpty) {
      options['order_id'] = orderId;
    }

    if (notes != null && notes.isNotEmpty) {
      options['notes'] = notes;
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      developer.log('Error opening Razorpay checkout: $e');
      // The caller handles surfaced errors from the payment flow.
    }
  }

  void dispose() {
    if (!kIsWeb) {
      _razorpay.clear();
    }
  }
}
