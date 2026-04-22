import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_supabase_order_app_mobile/shared/widgets/shared_widget_barrel.dart';
import 'package:flutter_supabase_order_app_mobile/router/app_routes.dart';
import '../../birthdate_analysis/ui/utils/analysis_theme.dart';
import '../../birthdate_analysis/ui/widgets/mystic_widgets.dart';
import '../../../../core/providers/birthdate_localization_provider.dart';
import '../providers/cart_controller.dart';
import '../../../../core/providers/app_localization_provider.dart';
import '../providers/cart_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/dialogs.dart';
import '../../../../core/services/analytics_service.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  late final CartController _cartController;

  @override
  void initState() {
    super.initState();
    _cartController = ref.read(cartControllerProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cartController.initRazorpay(
        onPaymentSuccess: _onPaymentSuccess,
        onPaymentError: _onPaymentError,
      );
    });
  }

  @override
  void dispose() {
    _cartController.disposeRazorpay();
    super.dispose();
  }

  void _onPaymentSuccess(String poId) {
    if (mounted) {
      // Defensively pop only if we are currently showing a loading dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ref
          .read(analyticsServiceProvider)
          .logPaymentEvent(
            status: 'success',
            itemCount: 1, // poId indicates specific order
          );
      _showSuccessDialog(poId);
    }
  }

  void _showSuccessDialog(String poId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Analysis Unlocked!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your payment was successful and your birthdate analysis is now unlocked! You can find it in your History or by clicking the button below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.goNamed(AppRoute.purchaseOrdersName);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'View Analysis',
                      style: TextStyle(fontWeight: FontWeight.bold),
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

  void _onPaymentError(String error) {
    if (mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      ref
          .read(analyticsServiceProvider)
          .logPaymentEvent(status: 'failure', error: error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment Failed: $error',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(unpaidOrdersProvider);
    ref.invalidate(birthdatesStreamProvider);
    final _ = await ref.refresh(birthdatesStreamProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(appL10nProvider);
    final unpaidOrders = ref.watch(unpaidOrdersProvider);
    final selectedIds = ref.watch(selectedOrdersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: l10n['my_cart'] ?? 'My Cart'),
      drawer: const CustomDrawer(),
      body: unpaidOrders.isEmpty
          ? RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n['cart_empty'] ?? 'Your cart is empty',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPromoFooter(context),
                  const SizedBox(height: 16),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.all(16),
                      // +1 for the premium features tile appended at the end
                      itemCount: unpaidOrders.length + 1,
                      itemBuilder: (context, index) {
                        // Last item: show the "What you get" premium features tile
                        if (index == unpaidOrders.length) {
                          final cartL10n = ref.read(birthdateL10nProvider);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            child: _buildPremiumFeaturesTile(context, cartL10n),
                          );
                        }

                        final order = unpaidOrders[index];
                        final recordId = order.id ?? '';
                        final isSelected = selectedIds.contains(recordId);
                        final dateDisplay = DateFormat(
                          'dd-MMM-yyyy',
                        ).format(order.birthdate);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                              width: isSelected ? 2 : 1.5,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              ref.read(birthdateProvider.notifier).state =
                                  order.birthdate;
                              ref
                                  .read(analyticsServiceProvider)
                                  .logClickEvent('cart_item_tapped');
                              context.pushNamed(AppRoute.birthdateAnalysisName);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.surface,
                                    theme.colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Transform.scale(
                                    scale: 1.2,
                                    child: Checkbox(
                                      value: isSelected,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      side: BorderSide(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                      onChanged: (val) {
                                        final current = Set<String>.from(
                                          selectedIds,
                                        );
                                        if (val == true) {
                                          current.add(recordId);
                                          ref
                                              .read(analyticsServiceProvider)
                                              .logCartAction('item_selected');
                                        } else {
                                          current.remove(recordId);
                                          ref
                                              .read(analyticsServiceProvider)
                                              .logCartAction('item_deselected');
                                        }
                                        ref
                                                .read(
                                                  selectedOrdersProvider
                                                      .notifier,
                                                )
                                                .state =
                                            current;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Birthdate: $dateDisplay',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    theme.colorScheme.onSurface,
                                                letterSpacing: 0.5,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          order.fullName ?? '',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                    ),
                                    color: theme.colorScheme.error,
                                    tooltip: 'Delete this record',
                                    onPressed: () => _deleteBirthdate(recordId),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _buildPaymentFooter(context, selectedIds, l10n),
              ],
            ),
    );
  }

  Future<void> _deleteBirthdate(String id) async {
    final l10n = ref.read(appL10nProvider);
    final confirm = await showConfirmationDialog(
      context: context,
      title: 'Delete Order?',
      content: 'Are you sure you want to delete this specific analysis record?',
      confirmLabel: 'Delete',
    );

    if (confirm == true) {
      if (!mounted) return;
      showLoadingDialog(
        context: context,
        message: l10n['please_wait'] ?? 'Deleting...',
      );

      try {
        await ref.read(cartControllerProvider).deleteBirthdate(id);
        ref.read(analyticsServiceProvider).logCartAction('item_deleted');

        if (mounted) {
          Navigator.of(context).pop(); // Dismiss loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Record deleted successfully.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Color(0xFF15803D),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Dismiss loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to delete record: $e',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      }
    }
  }

  Future<void> _handlePaymentAction(List<String> poIds) async {
    final user = ref.read(supabaseClientProvider).auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to continue.')),
      );
      return;
    }

    final allUnpaid = ref.read(unpaidOrdersProvider);
    final selectedOrders = allUnpaid
        .where((o) => poIds.contains(o.id))
        .toList();
    final count = selectedOrders.length;
    final totalAmount = count == 1 ? 299 : count * 249;

    final confirm = await _showPaymentConfirmationDialog(
      context: context,
      orders: selectedOrders,
      totalAmount: totalAmount,
    );

    if (confirm == true) {
      if (kIsWeb) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'Mobile App Required',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'Payments are currently optimized for our mobile app to ensure the best security. Please use the Android or iOS app to complete your purchase.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Got it'),
                ),
              ],
            ),
          );
        }
        return;
      }

      if (!mounted) return;
      showLoadingDialog(
        context: context,
        message: 'Redirecting to Payment Gateway...',
      );

      try {
        final email = user.email ?? '';
        final contact = user.userMetadata?['phone'] ?? '';

        ref
            .read(analyticsServiceProvider)
            .logPaymentEvent(
              status: 'initiated',
              amount: totalAmount.toDouble(),
              itemCount: poIds.length,
            );

        await ref
            .read(cartControllerProvider)
            .startPaymentFlow(
              poIds: poIds,
              totalAmount: totalAmount.toDouble(),
              email: email,
              contact: contact,
            );
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Dismiss loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to initiate payment: $e',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      }
    }
  }

  Future<bool?> _showPaymentConfirmationDialog({
    required BuildContext context,
    required List<dynamic> orders,
    required int totalAmount,
  }) {
    final theme = Theme.of(context);
    final count = orders.length;

    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Confirm Purchase',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'You are unlocking $count ${count == 1 ? "birthdate analysis" : "birthdate analyses"}:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: orders.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 16, indent: 8, endIndent: 8),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 18,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat(
                                    'dd-MMM-yyyy',
                                  ).format(order.birthdate),

                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  order.fullName ?? 'Unnamed',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '\u20B9$totalAmount',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Pay Now',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentFooter(
    BuildContext context,
    Set<String> selectedIds,
    Map<String, String> l10n,
  ) {
    final theme = Theme.of(context);
    final count = selectedIds.length;
    final birthdateL10n = ref.watch(birthdateL10nProvider);

    // Pricing logic: 1 -> 299, 1+ -> 249 each (e.g., 2=498, 3=747)
    final totalAmount = count == 1 ? 299 : count * 249;
    final originalAmount = count * 1000;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Special Offer Title and Add Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_offer_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      birthdateL10n['special_offer'] ?? 'Special Offer',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    ref
                        .read(analyticsServiceProvider)
                        .logClickEvent('add_more_from_cart');
                    context.pushNamed(AppRoute.birthdateAnalysisName);
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  label: Text(
                    birthdateL10n['add_birthdate'] ?? 'Add Birthdate',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.08,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: Pricing Details (Full Width)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                    theme.colorScheme.primary.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${birthdateL10n['for_limited_time'] ?? 'For 1+ analysis only'} ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '\u20B9299',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    ' \u20B9249 ${birthdateL10n['each'] ?? 'each'}.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Row 3: Selection Count and Pay Button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        count == 0
                            ? (l10n['select'] ?? 'Select')
                            : '$count ${count == 1 ? "birthdate" : "birthdates"}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Selected',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: count == 0
                      ? null
                      : () => _handlePaymentAction(selectedIds.toList()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 18,
                    ),
                    elevation: 4,
                    shadowColor: theme.colorScheme.primary.withValues(
                      alpha: 0.3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (count > 0) ...[
                        Text(
                          '\u20B9$originalAmount',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        count == 0 ? 'Pay' : 'Pay \u20B9$totalAmount',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoFooter(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(birthdateL10nProvider);
    final unpaidOrders = ref.watch(unpaidOrdersProvider);

    // Check if any order in the cart is 'pending'
    // Temporarily always show the tile for debugging
    final hasPendingOrder = unpaidOrders.any(
      (order) => order.status.toLowerCase() == 'pending',
    );

    return Column(
      children: [
        // Always show the tile for debugging - remove this condition later
        _buildPremiumFeaturesTile(context, l10n),
        // if (hasPendingOrder) _buildPremiumFeaturesTile(context, l10n),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Special Offers',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildOfferRow(
                context,
                title: '1 Birthdate Analysis',
                price: '\u20B9299',
                originalPrice: '\u20B9999',
              ),
              const Divider(height: 24),
              _buildOfferRow(
                context,
                title: '2+ Birthdate Analysis',
                price: '\u20B9249 each',
                originalPrice: '\u20B9299',
                isSpecial: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumFeaturesTile(
    BuildContext context,
    Map<String, String> l10n,
  ) {
    final theme = Theme.of(context);
    final features = [
      l10n['premium_feature_1'] ?? 'Detailed Lo Shu Grid Analysis',
      l10n['premium_feature_2'] ?? 'Career Insights',
      l10n['premium_feature_3'] ?? 'Personalized Remedies for Missing Numbers',
      l10n['premium_feature_4'] ?? 'Advanced Personality & Strength Mapping',
      l10n['premium_feature_5'] ?? 'Life Path & Pinnacle Phase Guidance',
      l10n['premium_feature_6'] ?? 'Oracle Voice Guide for Deeper Insights',
    ];

    return MysticSection(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: Colors.amber,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n['premium_title'] ?? 'What you get in Detailed Analysis',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AnalysisTheme.getAccent(theme),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 20,
                    color: AnalysisTheme.getAccent(
                      theme,
                    ).withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AnalysisTheme.getAccent(theme).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AnalysisTheme.getAccent(theme).withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              l10n['premium_footer'] ??
                  'Unlock the full potential of your birthdate today!',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                color: AnalysisTheme.getAccent(theme),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferRow(
    BuildContext context, {
    required String title,
    required String price,
    required String originalPrice,
    bool isSpecial = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          originalPrice,
          style: theme.textTheme.bodySmall?.copyWith(
            decoration: TextDecoration.lineThrough,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          price,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: isSpecial
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
