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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildBirthdatePickerTile(context, birthdate, ageStr, l10n),
                  _buildBirthdateDigits(context, ref),
                  const SizedBox(height: 32),
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                ],
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
                          birthdate: birthdate,
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

  Widget _buildBirthdateDigits(BuildContext context, WidgetRef ref) {
    final digits = ref.watch(birthdateDigitsProvider);
    if (digits == null || digits.isEmpty) return const SizedBox.shrink();

    final numerology = ref.watch(numerologyProvider);
    final l10n = ref.watch(l10nProvider);

    final labels = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          // Birthdate Digits Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(digits.length, (index) {
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        digits[index],
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[index % labels.length],
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Divider(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          // Advanced Numerology Grid
          _buildNumerologyGrid(context, numerology, l10n),
          if (numerology.loShuGrid != null) ...[
            const SizedBox(height: 24),
            Divider(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text(
              "Lo Shu Grid",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildLoShuGrid(context, numerology.loShuGrid!),
          ],
          if (numerology.absentNumbers != null && numerology.absentNumbers!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Divider(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text(
              l10n['absent_numbers_label'] ?? "Absent Numbers",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: numerology.absentNumbers!.map((n) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    n.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (numerology.numberOccurrences != null) ...[
            const SizedBox(height: 24),
            Divider(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text(
              l10n['occurrence_label'] ?? "Number Occurrences",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: numerology.numberOccurrences!.entries
                  .where((e) => e.value > 0)
                  .map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${e.key}",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        " : ",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        "${e.value}",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoShuGrid(BuildContext context, List<List<String>> grid) {
    final theme = Theme.of(context);
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: List.generate(3, (row) {
          return Row(
            children: List.generate(3, (col) {
              return Expanded(
                child: Container(
                  height: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      right: col < 2 ? BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.1)) : BorderSide.none,
                      bottom: row < 2 ? BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.1)) : BorderSide.none,
                    ),
                  ),
                  child: Text(
                    grid[row][col],
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildNumerologyGrid(BuildContext context, NumerologyState data, Map<String, String> l10n) {
    final theme = Theme.of(context);
    
    final items = [
      {'label': l10n['personality_number_label'] ?? 'Personality', 'val': data.personality},
      {'label': l10n['life_path_number_label'] ?? 'Life Path', 'val': data.lifePath},
      {'label': l10n['pinnacle1_number_label'] ?? 'Pinnacle 1', 'val': data.pinnacle1},
      {'label': l10n['pinnacle2_number_label'] ?? 'Pinnacle 2', 'val': data.pinnacle2},
      {'label': l10n['pinnacle3_number_label'] ?? 'Pinnacle 3', 'val': data.pinnacle3},
      {'label': l10n['pinnacle4_number_label'] ?? 'Pinnacle 4', 'val': data.pinnacle4},
      {'label': l10n['pinnacle_base_label'] ?? 'Pinnacle Base', 'val': data.pinnacleBase},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        if (item['val'] == null) return const SizedBox.shrink();
        return Container(
          width: (MediaQuery.of(context).size.width - 80) / 2, // 2 items per row
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Text(
                item['label'] as String,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item['val'].toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
