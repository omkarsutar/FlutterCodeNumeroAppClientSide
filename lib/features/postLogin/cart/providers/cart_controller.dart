import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/cart_order_service.dart';
import 'package:flutter_supabase_order_app_mobile/core/providers/core_providers.dart';
import 'package:flutter_supabase_order_app_mobile/router/app_routes.dart';
import '../../../../core/utils/dialogs.dart';
import '../../../../core/providers/app_localization_provider.dart';
import 'cart_providers.dart';

final cartOrderServiceProvider = Provider(
  (ref) => CartOrderService(client: ref.watch(supabaseClientProvider)),
);

class CartController {
  final Ref ref;
  final CartOrderService _orderService;

  CartController(this.ref) : _orderService = ref.read(cartOrderServiceProvider);

  Future<void> handleOrderAction(
    BuildContext context, {
    DateTime? birthdate,
  }) async {
    final l10n = ref.read(appL10nProvider);
    final session = ref.read(supabaseClientProvider).auth.currentSession;
    if (session == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n['cart_saved_login'] ??
                  'Cart saved. Please login to complete your order.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        context.pushNamed(AppRoute.loginName);
      }
      return;
    }

    final confirm = await _showConfirmDialog(
      context: context,
      title: 'Place Order?',
      message: 'Are you sure you want to place this order?',
      confirmLabel: l10n['confirm'] ?? 'Confirm',
      confirmColor: Colors.green,
    );

    if (confirm == true) {
      await placeOrder(context, birthdate: birthdate);
    }
  }

  Future<void> handlePaymentAction(
    BuildContext context,
    List<String> poIds,
  ) async {
    final l10n = ref.read(appL10nProvider);
    final confirm = await _showConfirmDialog(
      context: context,
      title: l10n['pay_now'] ?? 'Pay Now',
      message: 'Are you sure you want to pay for ${poIds.length} orders?',
      confirmLabel: l10n['pay_now'] ?? 'Pay Now',
      confirmColor: Colors.green,
    );

    if (confirm == true) {
      await processPayments(context, poIds);
    }
  }

  Future<void> processPayments(BuildContext context, List<String> poIds) async {
    final l10n = ref.read(appL10nProvider);
    showLoadingDialog(
      context: context,
      message: l10n['processing_payment'] ?? 'Processing order...',
    );

    try {
      final client = ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Create the main purchase order
      final poResponse = await client
          .from('purchase_order')
          .insert({
            'status': 'confirmed',
            'birthdate_ids': poIds,
            'created_by': user.id,
            'updated_by': user.id,
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

      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading

        // Clear selection
        ref.read(selectedOrdersProvider.notifier).state = {};

        // Invalidate relevant providers to force fresh data fetch
        ref.invalidate(birthdatesStreamProvider);
        ref.invalidate(unpaidOrdersProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order Placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading
        debugPrint('[CartController] Error placing order: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> deleteBirthdate(BuildContext context, String id) async {
    final l10n = ref.read(appL10nProvider);
    final confirm = await _showConfirmDialog(
      context: context,
      title: 'Delete Order?',
      message: 'Are you sure you want to delete this specific analysis record?',
      confirmLabel: 'Delete',
      confirmColor: Colors.red,
    );

    if (confirm == true) {
      showLoadingDialog(
        context: context,
        message: l10n['please_wait'] ?? 'Deleting...',
      );

      try {
        final client = ref.read(supabaseClientProvider);
        await client.from('birthdates').delete().eq('id', id);

        if (context.mounted) {
          Navigator.of(context).pop(); // Dismiss loading

          // Remove from selection if deleted
          final currentSelection = ref.read(selectedOrdersProvider);
          if (currentSelection.contains(id)) {
            final newSelection = Set<String>.from(currentSelection)..remove(id);
            ref.read(selectedOrdersProvider.notifier).state = newSelection;
          }

          // Invalidate relevant providers to force fresh data fetch
          ref.invalidate(birthdatesStreamProvider);
          ref.invalidate(unpaidOrdersProvider);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Record deleted successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop(); // Dismiss loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete record: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> placeOrder(BuildContext context, {DateTime? birthdate}) async {
    if (birthdate == null) return;
    final l10n = ref.read(appL10nProvider);
    // Show loading dialog
    showLoadingDialog(
      context: context,
      message: l10n['please_wait'] ?? 'Placing order...',
    );

    try {
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

      if (context.mounted) {
        // Dismiss loading dialog
        Navigator.of(context).pop();

        // Invalidate relevant providers to force fresh data fetch
        ref.invalidate(birthdatesStreamProvider);
        ref.invalidate(unpaidOrdersProvider);
        ref.invalidate(currentBirthdateRecordProvider);

        // Show premium Thank You dialog
        await _showThankYouDialog(context);
      }
    } catch (e) {
      if (context.mounted) {
        // Dismiss loading dialog
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool?> _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showThankYouDialog(BuildContext context) {
    final l10n = ref.read(appL10nProvider);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green[700],
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n['thank_you'] ?? 'Thank You!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n['order_success'] ??
                      'Your order has been placed successfully.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.goNamed(AppRoute.birthdateAnalysisName);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n['continue_shopping'] ?? 'Continue Shopping',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

final cartControllerProvider = Provider((ref) => CartController(ref));
