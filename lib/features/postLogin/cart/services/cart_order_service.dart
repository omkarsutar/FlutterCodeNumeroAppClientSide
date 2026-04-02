import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/services/connectivity_service.dart';
// Removed unused purchase order import

class CartOrderService {
  final SupabaseClient client;

  CartOrderService({required this.client});

  Future<void> placeOrder({
    required String userId,
    required String? roleName,
    required String userName,
    required DateTime birthdate,
  }) async {
    // Check connectivity before placing order
    if (!await ConnectivityService.isOnline()) {
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
    if (!await ConnectivityService.isOnline()) {
      throw NoInternetException();
    }

    await client.from('birthdates').update({'full_name': newName}).eq('id', id);
  }
}
