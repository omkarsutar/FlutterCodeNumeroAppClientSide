import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cart_order_service.dart';
import '../../../../core/services/razorpay_service.dart';
import 'package:numero_shastra/core/providers/core_providers.dart';
import 'package:numero_shastra/features/postLogin/birthdate_analysis/providers/numerology_content_providers.dart';
import 'cart_providers.dart';

final cartOrderServiceProvider = Provider(
  (ref) => CartOrderService(
    client: ref.watch(supabaseClientProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  ),
);

class CartController {
  final Ref ref;
  final CartOrderService _orderService;
  late final RazorpayService _razorpayService;

  List<String>? _pendingPoIds;
  Function(String)? _onPaymentSuccess;
  Function(String)? _onPaymentError;

  CartController(this.ref)
    : _orderService = ref.read(cartOrderServiceProvider),
      _razorpayService = ref.read(razorpayServiceProvider);

  void initRazorpay({
    required Function(String) onPaymentSuccess,
    required Function(String) onPaymentError,
  }) {
    _onPaymentSuccess = onPaymentSuccess;
    _onPaymentError = onPaymentError;

    _razorpayService.initialize(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentFailure,
      onExternalWallet: _handleExternalWallet,
    );
  }

  void disposeRazorpay() {
    _razorpayService.dispose();
  }

  void _handlePaymentSuccess(dynamic response) async {
    if (_pendingPoIds != null) {
      try {
        final poId = await _orderService.completePurchase(
          poIds: _pendingPoIds!,
          userId: ref.read(supabaseClientProvider).auth.currentUser!.id,
          paymentId: response.paymentId ?? '',
          signature: response.signature ?? '',
          orderId: response.orderId ?? '',
        );

        // Invalidate relevant providers to force fresh data fetch
        ref.invalidate(birthdatesStreamProvider);
        ref.invalidate(unpaidOrdersProvider);
        ref.invalidate(currentBirthdateRecordProvider);
        ref.read(selectedOrdersProvider.notifier).state = {};

        // Invalidate all numerology content providers so the analysis
        // page fetches fresh data reflecting the new 'confirmed' status
        ref.invalidate(personalityDataProvider);
        ref.invalidate(loshuPlanesProvider);
        ref.invalidate(numberOccurrenceDetailsProvider);
        ref.invalidate(missingNumberTellsProvider);
        ref.invalidate(importantPointsProvider);
        ref.invalidate(stockMarketInfoProvider);
        ref.invalidate(remedyValuesProvider);
        ref.invalidate(missingNumberRemediesProvider);
        ref.invalidate(pinnacleData1Provider);
        ref.invalidate(pinnacleData2Provider);
        ref.invalidate(pinnacleData3Provider);
        ref.invalidate(pinnacleData4Provider);
        ref.invalidate(lifePathNumberDataProvider);
        ref.invalidate(careerDataProvider);
        ref.invalidate(boostingPersonalityDataProvider);
        ref.invalidate(combinationDataProvider);

        _onPaymentSuccess?.call(poId);
      } catch (e) {
        _onPaymentError?.call(e.toString());
      } finally {
        _pendingPoIds = null;
      }
    }
  }

  void _handlePaymentFailure(dynamic response) {
    _pendingPoIds = null;
    _onPaymentError?.call(response.message ?? 'Payment Failed');
  }

  void _handleExternalWallet(dynamic response) {
    // Handle external wallet if needed
  }

  Future<void> startPaymentFlow({
    required List<String> poIds,
    required double totalAmount,
    required String email,
    required String contact,
    String? apiKey,
    String? appliedPromoCode,
  }) async {
    _pendingPoIds = poIds;

    final prefs = await SharedPreferences.getInstance();
    String? firstReferrerRaw = prefs.getString('first_touch_source');
    String? lastReferrerRaw = prefs.getString('second_touch_source');

    if (firstReferrerRaw == null || firstReferrerRaw.isEmpty) {
      firstReferrerRaw =
          'utm_source=organic&utm_medium=direct&utm_campaign=none';
    }
    if (lastReferrerRaw == null || lastReferrerRaw.isEmpty) {
      lastReferrerRaw = firstReferrerRaw;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final userId = ref.read(supabaseClientProvider).auth.currentUser?.id;

    final selectedBirthdates = ref
        .read(effectiveBirthdateRecordsProvider)
        .where((record) => poIds.contains(record.id))
        .map((record) => DateFormat('yyyy-MM-dd').format(record.birthdate))
        .toList();

    final extraInfo = jsonEncode({
      'user_id': userId,
      'birthdates': selectedBirthdates,
    });

    _razorpayService.openCheckout(
      description: "Payment for ${poIds.length} Birthdate Analysis",
      amount: totalAmount,
      contact: contact,
      email: email,
      apiKey: apiKey,
      notes: {
        'extra_info': extraInfo,
        'package_name': packageInfo.packageName,
        'promo_code_applied': appliedPromoCode ?? 'none',
        'first_touch_referrer_raw': firstReferrerRaw,
        'last_touch_referrer_raw': lastReferrerRaw,
      },
    );
  }

  // Legacy method - refactored to use new flow or kept for compatibility if needed
  // For now, I'll keep the name but change the body to throw or redirect
  Future<void> processPayments(List<String> poIds) async {
    throw UnimplementedError('Use startPaymentFlow instead');
  }

  Future<void> deleteBirthdate(String id) async {
    await _orderService.deleteBirthdate(id);

    // Remove from selection if deleted
    final currentSelection = ref.read(selectedOrdersProvider);
    if (currentSelection.contains(id)) {
      final newSelection = Set<String>.from(currentSelection)..remove(id);
      ref.read(selectedOrdersProvider.notifier).state = newSelection;
    }

    // Invalidate relevant providers to force fresh data fetch
    ref.invalidate(birthdatesStreamProvider);
    ref.invalidate(unpaidOrdersProvider);
  }

  Future<void> updateBirthdateName(String id, String newName) async {
    await _orderService.updateBirthdateName(id: id, newName: newName);

    // Invalidate relevant providers to force fresh data fetch
    ref.invalidate(birthdatesStreamProvider);
    ref.invalidate(currentBirthdateRecordProvider);
  }

  Future<void> placeOrder({required DateTime birthdate}) async {
    final user = ref.read(supabaseClientProvider).auth.currentUser!;
    final userId = user.id;
    final roleName = ref.read(roleNameProvider);
    final userName =
        user.userMetadata?['full_name'] ??
        user.userMetadata?['name'] ??
        user.email?.split('@').first ??
        'User';

    await _orderService.placeOrder(
      userId: userId,
      roleName: roleName,
      userName: userName,
      birthdate: birthdate,
    );

    // Invalidate relevant providers to force fresh data fetch
    ref.invalidate(birthdatesStreamProvider);
    ref.invalidate(unpaidOrdersProvider);
    ref.invalidate(currentBirthdateRecordProvider);
  }
}

final cartControllerProvider = Provider((ref) => CartController(ref));
