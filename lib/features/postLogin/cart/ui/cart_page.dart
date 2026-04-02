import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_supabase_order_app_mobile/shared/widgets/shared_widget_barrel.dart';
import 'package:flutter_supabase_order_app_mobile/router/app_routes.dart';
import '../providers/cart_controller.dart';
import '../../../../core/providers/app_localization_provider.dart';
import '../providers/cart_providers.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  Future<void> _refreshCartData() async {
    ref.invalidate(currentBirthdateRecordProvider);
    ref.invalidate(unpaidOrdersProvider);
    ref.invalidate(birthdatesStreamProvider);
    await ref.refresh(birthdatesStreamProvider.future);
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
              onRefresh: _refreshCartData,
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
                    onRefresh: _refreshCartData,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.all(16),
                      itemCount: unpaidOrders.length,
                      itemBuilder: (context, index) {
                        final order = unpaidOrders[index];
                        final recordId = order.id ?? '';
                        final isSelected = selectedIds.contains(recordId);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Checkbox(
                              value: isSelected,
                              onChanged: (val) {
                                final current = Set<String>.from(selectedIds);
                                if (val == true) {
                                  current.add(recordId);
                                } else {
                                  current.remove(recordId);
                                }
                                ref
                                        .read(selectedOrdersProvider.notifier)
                                        .state =
                                    current;
                              },
                            ),
                            title: Text(
                              DateFormat('dd-MMM-yyyy').format(order.birthdate),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Record ID: ${recordId.substring(0, 8)}...",
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome_rounded,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                  color: theme.colorScheme.error,
                                  tooltip: 'Delete this record',
                                  onPressed: () => ref
                                      .read(cartControllerProvider)
                                      .deleteBirthdate(context, recordId),
                                ),
                              ],
                            ),
                            onTap: () {
                              ref.read(birthdateProvider.notifier).state =
                                  order.birthdate;
                              context.pushNamed(AppRoute.birthdateAnalysisName);
                            },
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

  Widget _buildPaymentFooter(
    BuildContext context,
    Set<String> selectedIds,
    Map<String, String> l10n,
  ) {
    final theme = Theme.of(context);
    final count = selectedIds.length;

    // Pricing logic: 1 -> 299, 1+ -> 249 each (e.g., 2=498, 3=747)
    final totalAmount = count == 1 ? 299 : count * 249;
    final originalAmount = count * 1000;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add Birthdate and special offer row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Special Offer:',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'For 1+ analysis only ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '\u20B9299',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            ' \u20B9249 each.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.pushNamed(AppRoute.birthdateAnalysisName),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: const Text('Add'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Bottom row with selection count and Pay button
            Row(
              children: [
                Expanded(
                  child: Text(
                    count == 0
                        ? 'Select a Birthdate'
                        : '$count ${count == 1 ? "birthdate" : "birthdates"} selected',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: count == 0
                      ? null
                      : () => ref
                            .read(cartControllerProvider)
                            .handlePaymentAction(context, selectedIds.toList()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (count > 0) ...[
                        Text(
                          '\u20B9$originalAmount',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        count == 0 ? 'Pay' : 'Pay \u20B9$totalAmount',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
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
    return Container(
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
