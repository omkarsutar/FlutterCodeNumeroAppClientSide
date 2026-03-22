import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_supabase_order_app_mobile/shared/widgets/shared_widget_barrel.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_view_logic.dart';
import '../providers/cart_controller.dart';
import '../../../../core/providers/localization_provider.dart';
import 'package:intl/intl.dart';
import '../providers/cart_providers.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  @override
  Widget build(BuildContext context) {
    final viewData = ref.watch(cartViewLogicProvider);
    final l10n = ref.watch(l10nProvider);
    final canPop = context.canPop();
    final birthdate = ref.watch(birthdateProvider);
    final ageStr = ref.watch(ageProvider);
    final cartStatus = ref.watch(cartStatusProvider);

    return Scaffold(
      appBar: CustomAppBar(title: l10n['my_cart'] ?? 'My Cart'),
      drawer: canPop ? null : const CustomDrawer(),
      body: Column(
        children: [
          _buildBirthdatePickerTile(context, birthdate, ageStr, l10n),
          Expanded(
            child: const Center(
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 120,
                color: Colors.grey,
              ),
            ),
          ),
          _buildActionFooter(context, viewData, l10n, birthdate, cartStatus),
        ],
      ),
    );
  }

  Widget _buildActionFooter(
    BuildContext context,
    ProcessedCartData viewData,
    Map<String, String> l10n,
    DateTime? birthdate,
    String? cartStatus,
  ) {
    final theme = Theme.of(context);
    final isConfirmed = cartStatus?.toLowerCase() == 'confirmed';
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
            onPressed: isConfirmed
                ? null
                : (birthdate == null
                    ? null
                    : () => ref.read(cartControllerProvider).handleOrderAction(
                          context,
                          viewData,
                          birthdate:
                              DateFormat('dd-MMM-yyyy').format(birthdate),
                        )),
            icon: Icon(
              isConfirmed
                  ? Icons.payment_rounded
                  : Icons.shopping_cart_checkout_rounded,
              size: 20,
            ),
            label: Text(
              isConfirmed
                  ? (l10n['pay_now'] ?? 'Pay Now')
                  : (l10n['place_order'] ?? 'Place Order'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
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

  Widget _buildBirthdatePickerTile(
    BuildContext context,
    DateTime? birthdate,
    String? ageStr,
    Map<String, String> l10n,
  ) {
    final theme = Theme.of(context);
    final dateDisplay = birthdate != null
        ? DateFormat('dd-MMM-yyyy').format(birthdate)
        : '';

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      elevation: 4,
      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              theme.colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          title: Text(
            "${l10n['birthdate_label'] ?? 'Birthdate'} : $dateDisplay",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          subtitle: ageStr != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "${l10n['age_prefix'] ?? 'Your todays age is'} $ageStr",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                )
              : null,
          trailing: Icon(
            Icons.calendar_month_rounded,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: birthdate ?? DateTime(1990),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: theme.colorScheme.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              ref.read(birthdateProvider.notifier).state = picked;
            }
          },
        ),
      ),
    );
  }
}
