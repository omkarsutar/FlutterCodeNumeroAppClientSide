import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/cart_order_service.dart';
import 'cart_view_logic.dart';
import 'package:flutter_supabase_order_app_mobile/core/providers/core_providers.dart';
import 'package:flutter_supabase_order_app_mobile/router/app_routes.dart';
import '../../purchase_orders/purchase_order_barrel.dart';
import '../../../../core/utils/dialogs.dart';
import '../../../../core/providers/localization_provider.dart';

final cartOrderServiceProvider = Provider(
  (ref) => CartOrderService(
    client: ref.watch(supabaseClientProvider),
    poService: ref.watch(purchaseOrderServiceProvider),
  ),
);

class CartController {
  final Ref ref;
  final CartOrderService _orderService;

  CartController(this.ref) : _orderService = ref.read(cartOrderServiceProvider);

  Future<void> initPendingOrder(BuildContext context) async {
    // No longer needed since there are no cart items
  }

  Future<void> handleOrderAction(
    BuildContext context,
    ProcessedCartData viewData, {
    String? birthdate,
  }) async {
    final l10n = ref.read(l10nProvider);
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

  Future<void> placeOrder(BuildContext context, {String? birthdate}) async {
    final l10n = ref.read(l10nProvider);
    // Show loading dialog
    showLoadingDialog(
      context: context,
      message: l10n['please_wait'] ?? 'Placing order...',
    );

    try {
      final userId = ref.read(supabaseClientProvider).auth.currentUser!.id;
      final roleName = ref.read(roleNameProvider);

      await _orderService.placeOrder(
        userId: userId,
        roleName: roleName,
        birthdate: birthdate,
      );

      if (context.mounted) {
        // Dismiss loading dialog
        Navigator.of(context).pop();

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
    final l10n = ref.read(l10nProvider);
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
                      context.goNamed(AppRoute.cartName);
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
