import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cart_order_service.dart';
import 'package:flutter_supabase_order_app_mobile/core/providers/core_providers.dart';
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

  CartController(this.ref) : _orderService = ref.read(cartOrderServiceProvider);

  Future<void> processPayments(List<String> poIds) async {
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _orderService.processPayments(poIds: poIds, userId: user.id);

    // Invalidate relevant providers to force fresh data fetch
    ref.invalidate(birthdatesStreamProvider);
    ref.invalidate(unpaidOrdersProvider);
    ref.read(selectedOrdersProvider.notifier).state = {};
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
