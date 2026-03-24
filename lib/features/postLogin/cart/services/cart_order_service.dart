import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../purchase_orders/purchase_order_barrel.dart';

class CartOrderService {
  final SupabaseClient client;
  final PurchaseOrderServiceImpl poService;

  CartOrderService({required this.client, required this.poService});

  Future<ModelPurchaseOrder> placeOrder({
    required String userId,
    required String? roleName,
    required String userName,
    required DateTime birthdate,
  }) async {
    // Check connectivity before placing order
    if (!await ConnectivityService.isOnline()) {
      throw NoInternetException();
    }

    // Default hardcoded IDs for guest and salesperson
    String poShopId = '322d2aeb-34b3-47ef-aa5b-e411add1c7ba';
    String poRouteId = '1ce6a931-4866-4645-a680-102b4b9e923b';

    // Handle Retailer specific IDs
    if (roleName?.toLowerCase() == 'retailer') {
      try {
        final link = await client
            .from('retailer_shop_link')
            .select('shop_id, shops!inner(shops_primary_route)')
            .eq('user_id', userId)
            .maybeSingle();

        if (link != null) {
          poShopId = link['shop_id'] as String;
          poRouteId = link['shops']['shops_primary_route'] as String;
          debugPrint(
            '[CartOrderService] Retailer link found: shop=$poShopId, route=$poRouteId',
          );
        }
      } catch (e) {
        debugPrint('[CartOrderService] Error fetching retailer link: $e');
      }
    }

    final currentUser = client.auth.currentUser;
    final userEmail = currentUser?.email ?? '';
    final userName =
        currentUser?.userMetadata?['full_name'] ??
        currentUser?.userMetadata?['name'] ??
        userEmail.split('@').first;

    final prefs = await SharedPreferences.getInstance();
    final utmSource = prefs.getString('utm_source') ?? '';

    String userRoleStr = roleName != null ? ' [$roleName]' : '';
    String userComment = '$userName ($userEmail)$userRoleStr';
    if (utmSource.isNotEmpty) {
      userComment += ' [UTM: $utmSource]';
    }

    final po = ModelPurchaseOrder(
      poTotalAmount: 0,
      poLineItemCount: 0,
      poShopId: null,
      poRouteId: null,
      status: 'confirmed',
      userComment: DateFormat('dd-MMM-yyyy').format(birthdate),
      adminComment: userComment,
      createdBy: userId,
      updatedBy: userId,
    );

    final createdPo = await poService.create(po);
    final String? poId = createdPo.poId;

    if (poId != null) {
      final dateStr =
          "${birthdate.year}-${birthdate.month.toString().padLeft(2, '0')}-${birthdate.day.toString().padLeft(2, '0')}";

      await client.from('birthdates').insert({
        'user_id': userId,
        'po_id': poId,
        'birthdate': dateStr,
        'full_name': userName,
      });
    }

    return createdPo;
  }
}
