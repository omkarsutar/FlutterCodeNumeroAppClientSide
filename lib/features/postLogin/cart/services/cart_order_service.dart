import 'package:supabase_flutter/supabase_flutter.dart';
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

  Future<String> processPayments({
    required List<String> poIds,
    required String userId,
  }) async {
    if (!await _connectivityService.isOnline()) {
      throw NoInternetException();
    }

    // Create the main purchase order
    final poResponse = await client
        .from('purchase_order')
        .insert({
          'status': 'confirmed',
          'birthdate_ids': poIds,
          'created_by': userId,
          'updated_by': userId,
          'user_comment': 'Birthdate Analysis Order',
          'po_line_item_count': poIds.length,
        })
        .select('po_id')
        .single();

    final generatedPoId = poResponse['po_id'] as String;

    // Update status and po_id for all selected birthdate records
    for (final id in poIds) {
      await client
          .from('birthdates')
          .update({'status': 'confirmed', 'po_id': generatedPoId})
          .eq('id', id);
    }

    return generatedPoId;
  }

  Future<void> deleteBirthdate(String id) async {
    if (!await _connectivityService.isOnline()) {
      throw NoInternetException();
    }

    await client.from('birthdates').delete().eq('id', id);
  }
}
