// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:html' as html;
import 'dart:js' as js;

class _WebPaymentSuccessResponse {
  final String paymentId;
  final String? orderId;
  final String? signature;

  const _WebPaymentSuccessResponse({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });
}

class _WebPaymentFailureResponse {
  final String message;

  const _WebPaymentFailureResponse(this.message);
}

class RazorpayService {
  final String _apiKey;
  Function(dynamic)? _onSuccess;
  Function(dynamic)? _onFailure;

  static Future<void>? _scriptLoadFuture;

  RazorpayService({required String apiKey}) : _apiKey = apiKey;

  void initialize({
    required Function(dynamic) onSuccess,
    required Function(dynamic) onFailure,
    required Function(dynamic) onExternalWallet,
  }) {
    _onSuccess = onSuccess;
    _onFailure = onFailure;
    onExternalWallet;
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
    _openCheckout(
      description: description,
      amount: amount,
      contact: contact,
      email: email,
      apiKey: apiKey,
      orderId: orderId,
      notes: notes,
    );
  }

  Future<void> _openCheckout({
    required String description,
    required double amount,
    required String contact,
    required String email,
    String? apiKey,
    String? orderId,
    Map<String, String>? notes,
  }) async {
    try {
      await _ensureCheckoutScriptLoaded();

      final razorpayCtor = js.context['Razorpay'];
      if (razorpayCtor == null) {
        throw Exception('Razorpay checkout script is not available.');
      }

      final options = <String, Object?>{
        'key': apiKey ?? _apiKey,
        'amount': (amount * 100).toInt(),
        'currency': 'INR',
        'name': 'Numero Shastra',
        'description': description,
        'prefill': <String, Object?>{
          'contact': contact,
          'email': email,
        },
        'theme': <String, Object?>{
          'color': '#003BFF',
        },
        'handler': (dynamic response) {
          final paymentId = _extractString(
            response,
            const ['razorpay_payment_id', 'payment_id'],
          );
          final responseOrderId = _extractString(
            response,
            const ['razorpay_order_id', 'order_id'],
          );
          final signature = _extractString(
            response,
            const ['razorpay_signature', 'signature'],
          );

          if (paymentId == null || paymentId.isEmpty) {
            _onFailure?.call(
              const _WebPaymentFailureResponse('Payment was completed, but no payment id was returned.'),
            );
            return;
          }

          _onSuccess?.call(
            _WebPaymentSuccessResponse(
              paymentId: paymentId,
              orderId: responseOrderId ?? orderId,
              signature: signature,
            ),
          );
        },
      };

      if (orderId != null && orderId.isNotEmpty) {
        options['order_id'] = orderId;
      }

      if (notes != null && notes.isNotEmpty) {
        options['notes'] = notes;
      }

      final checkout = js.JsObject(razorpayCtor, [js.JsObject.jsify(options)]);

      checkout.callMethod(
        'on',
        [
          'payment.failed',
          (dynamic response) {
            final message = _extractNestedString(
                  response,
                  const ['error', 'description'],
                ) ??
                _extractNestedString(
                  response,
                  const ['error', 'reason'],
                ) ??
                'Payment failed';
            _onFailure?.call(_WebPaymentFailureResponse(message));
          },
        ],
      );

      checkout.callMethod('open');
    } catch (e) {
      developer.log('Error opening Razorpay web checkout: $e');
      _onFailure?.call(_WebPaymentFailureResponse(e.toString()));
    }
  }

  Future<void> _ensureCheckoutScriptLoaded() async {
    if (js.context['Razorpay'] != null) {
      return;
    }

    _scriptLoadFuture ??= _loadCheckoutScript();
    await _scriptLoadFuture;
  }

  Future<void> _loadCheckoutScript() {
    final completer = Completer<void>();
    final script = html.ScriptElement()
      ..src = 'https://checkout.razorpay.com/v1/checkout.js'
      ..type = 'text/javascript'
      ..async = true;

    script.onLoad.first.then((_) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    script.onError.first.then((_) {
      if (!completer.isCompleted) {
        completer.completeError(
          Exception('Failed to load Razorpay checkout script.'),
        );
      }
    });

    html.document.head?.append(script);
    return completer.future;
  }

  String? _extractString(dynamic response, List<String> path) {
    try {
      dynamic current = response;
      for (final key in path) {
        if (current == null) return null;
        current = current[key];
      }
      final value = current?.toString().trim();
      return (value == null || value.isEmpty) ? null : value;
    } catch (_) {
      return null;
    }
  }

  String? _extractNestedString(dynamic response, List<String> path) {
    return _extractString(response, path);
  }

  void dispose() {
    _onSuccess = null;
    _onFailure = null;
  }
}
