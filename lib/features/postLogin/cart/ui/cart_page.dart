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
    final isTwoBirthdatesSelected = count >= 2;
    final offerPrice = isTwoBirthdatesSelected ? '499' : '299';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
            _buildPromoCard(
              context,
              headline: 'Unlock your birthdate insights today',
              offerPrice: offerPrice,
              showCheckoutAction: true,
              checkoutLabel: "${l10n['place_order'] ?? 'Place Order'} ($count)",
              onCheckout: count == 0
                  ? null
                  : () => ref
                        .read(cartControllerProvider)
                        .handlePaymentAction(context, selectedIds.toList()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoFooter(BuildContext context) {
    return SafeArea(
      top: false,
      child: _buildPromoCard(
        context,
        headline: 'Get your personalized birthdate analysis',
        offerPrice: '299',
        showCheckoutAction: false,
      ),
    );
  }

  Widget _buildPromoCard(
    BuildContext context, {
    required String headline,
    required String offerPrice,
    required bool showCheckoutAction,
    String? checkoutLabel,
    VoidCallback? onCheckout,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headline,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'For 1 birthdate analysis',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.86),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildCompactPriceButton(
                  context,
                  label: '999',
                  isStriked: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactPriceButton(
                  context,
                  label: offerPrice,
                  isHighlighted: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'For 2 birthdates or to add a new one',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.86),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildCompactPriceButton(
                  context,
                  label: '499',
                  suffix: ' x2',
                  isHighlighted: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.pushNamed(AppRoute.birthdateAnalysisName),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: const Text('Add a Birthdate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onPrimary,
                    side: BorderSide(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.45),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (showCheckoutAction) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCheckout,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(checkoutLabel ?? 'Place Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.onPrimary,
                  foregroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactPriceButton(
    BuildContext context, {
    required String label,
    bool isStriked = false,
    bool isHighlighted = false,
    String suffix = '',
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? theme.colorScheme.onPrimary
            : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '\u20B9$label$suffix',
          style: theme.textTheme.titleSmall?.copyWith(
            color: isHighlighted
                ? theme.colorScheme.primary
                : theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w900,
            decoration:
                isStriked ? TextDecoration.lineThrough : TextDecoration.none,
            decorationColor: isHighlighted
                ? theme.colorScheme.primary
                : theme.colorScheme.onPrimary,
            decorationThickness: 2,
          ),
        ),
      ),
    );
  }
}
