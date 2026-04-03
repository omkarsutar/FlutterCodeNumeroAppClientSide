import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/interfaces/connectivity_service_interface.dart';

class CartOrderService {
  final SupabaseClient client;
  final IConnectivityService _connectivityService;

  CartOrderService({
    required this.client,
    required IConnectivityService connectivityService,
  }) : _connectivityService = connectivityService;

  Future<void> placeOrder({
    required String userId,
    required String? roleName,
    required String userName,
    required DateTime birthdate,
  }) async {
    // Check connectivity before placing order
    if (!await _connectivityService.isOnline()) {
      throw NoInternetException();
    }

    final currentUser = client.auth.currentUser;
    final fullName =
        currentUser?.userMetadata?['full_name'] ??
        currentUser?.userMetadata?['name'] ??
        userName;

    final dateStr =
        "${birthdate.year}-${birthdate.month.toString().padLeft(2, '0')}-${birthdate.day.toString().padLeft(2, '0')}";

    // Insert directly into birthdates table with status 'pending'
    await client.from('birthdates').insert({
      'user_id': userId,
      'birthdate': dateStr,
      'full_name': fullName,
      'status': 'pending',
    });
  }

  Future<void> updateBirthdateName({
    required String id,
    required String newName,
  }) async {
    if (!await _connectivityService.isOnline()) {
      throw NoInternetException();
    }

    await client.from('birthdates').update({'full_name': newName}).eq('id', id);
  }

  Future<String> completePurchase({
    required List<String> poIds,
    required String userId,
    required String paymentId,
    required String signature,
    required String orderId,
  }) async {
    if (!await _connectivityService.isOnline()) {
      throw NoInternetException();
    }

    try {
      final response = await client.functions.invoke(
        'verify-payment',
        body: {
          'razorpay_payment_id': paymentId,
          'razorpay_order_id': orderId,
          'razorpay_signature': signature,
          'poIds': poIds,
          'userId': userId,
        },
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Payment verification failed');
      }

      return response.data['poId'] as String;
    } catch (e) {
      developer.log("Error in verify-payment Edge Function: $e", name: 'CartOrderService');
      rethrow;
    }
  }

  Future<void> deleteBirthdate(String id) async {
    if (!await _connectivityService.isOnline()) {
      throw NoInternetException();
    }

    await client.from('birthdates').delete().eq('id', id);
  }
}
