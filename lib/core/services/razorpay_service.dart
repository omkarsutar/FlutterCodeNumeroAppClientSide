import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;

class RazorpayService {
  final Razorpay _razorpay = Razorpay();
  final String _apiKey;

  RazorpayService({required String apiKey}) : _apiKey = apiKey;

  void initialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    if (kIsWeb) {
      return; // Avoid native plugin initialization on web if it causes issues
    }

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  void openCheckout({
    required String description,
    required double amount,
    required String contact,
    required String email,
  }) {
    if (kIsWeb) {
      developer.log(
        "Razorpay checkout requested on web. Redirecting to hosted page or showing alternative UI...",
      );
      // For now, prompt the user or handle via standard web checkout if necessary
      return;
    }

    var options = {
      'key': _apiKey,
      'amount': (amount * 100).toInt(), // Amount is in paise
      'name': 'Numero Shastra',
      'description': description,
      'timeout': 300, // in seconds
      'prefill': {'contact': contact, 'email': email},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      developer.log("Error opening Razorpay checkout: $e");
    }
  }

  void dispose() {
    if (!kIsWeb) {
      _razorpay.clear();
    }
  }
}
