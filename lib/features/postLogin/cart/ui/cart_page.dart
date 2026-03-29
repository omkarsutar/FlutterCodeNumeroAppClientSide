import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_supabase_order_app_mobile/shared/widgets/shared_widget_barrel.dart';
import 'package:flutter_supabase_order_app_mobile/router/app_routes.dart';
import '../providers/cart_controller.dart';
import '../../../../core/providers/localization_provider.dart';
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
    final l10n = ref.watch(l10nProvider);
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
                                ref.read(selectedOrdersProvider.notifier).state =
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

    return Container(
      padding: const EdgeInsets.all(20),
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: count == 0
                ? null
                : () => ref.read(cartControllerProvider).handlePaymentAction(
                      context,
                      selectedIds.toList(),
                    ),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
            label: Text(
              "${l10n['place_order'] ?? 'Place Order'} ($count)",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
