import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_supabase_order_app_mobile/shared/widgets/shared_widget_barrel.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../cart/providers/cart_providers.dart';
import '../../cart/providers/cart_controller.dart';
import '../../../../core/providers/localization_provider.dart';
import '../../../../router/app_routes.dart';

class BirthdateAnalysisPage extends ConsumerStatefulWidget {
  const BirthdateAnalysisPage({super.key});

  @override
  ConsumerState<BirthdateAnalysisPage> createState() =>
      _BirthdateAnalysisPageState();
}

class _BirthdateAnalysisPageState extends ConsumerState<BirthdateAnalysisPage> {
  void _navigateToCartAndSelect(DateTime birthdate) async {
    final recordAsync = ref.read(currentBirthdateRecordProvider);
    final record = recordAsync.valueOrNull;

    if (record != null && record['id'] != null) {
      final birthdateId = record['id'] as String;

      // Update selected orders provider to include this birthdate
      final currentSelection = ref.read(selectedOrdersProvider);
      final newSelection = Set<String>.from(currentSelection)..add(birthdateId);
      ref.read(selectedOrdersProvider.notifier).state = newSelection;

      // Navigate to cart page
      if (mounted) {
        context.goNamed(AppRoute.cartName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final birthdate = ref.watch(birthdateProvider);
    final ageStr = ref.watch(ageProvider);
    final cartStatus = ref.watch(cartStatusProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n['birthdate_analysis'] ?? 'Birthdate Analysis',
        showBack: false,
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildBirthdatePickerTile(context, birthdate, ageStr, l10n),
                  _buildNumerologyAnalysisSection(context, ref),
                  _buildPersonalityDetails(context, ref),
                  _buildLoshuPlanesSection(context, ref, l10n),
                  _buildNumberOccurrenceDetailsSection(context, ref, l10n),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildActionFooter(context, l10n, birthdate, cartStatus),
        ],
      ),
    );
  }

  Widget _buildActionFooter(
    BuildContext context,
    Map<String, String> l10n,
    DateTime? birthdate,
    String? cartStatus,
  ) {
    // Hide button entirely if birthdate is already saved dynamically.
    if (cartStatus != null && cartStatus.toLowerCase() != 'pending') {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isPending = cartStatus?.toLowerCase() == 'pending';

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
            onPressed: birthdate == null
                ? null
                : () {
                    if (isPending) {
                      // Navigate to Cart and select this birthdate
                      _navigateToCartAndSelect(birthdate);
                    } else {
                      // Save new birthdate
                      ref
                          .read(cartControllerProvider)
                          .handleOrderAction(context, birthdate: birthdate);
                    }
                  },
            icon: Icon(
              isPending ? Icons.shopping_cart_outlined : Icons.save_rounded,
              size: 20,
            ),
            label: Text(
              isPending
                  ? (l10n['read_more'] ?? 'Read More')
                  : (l10n['save_birthdate'] ?? 'Save Birthdate'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPending
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primary,
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
    final ageComponents = ref.watch(ageComponentsProvider);

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
          subtitle: ageComponents != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${l10n['age_prefix'] ?? 'Your todays age is'}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${ageComponents['years']} ${l10n['years'] ?? 'years'} ${ageComponents['months']} ${l10n['months'] ?? 'months'} ${ageComponents['days']} ${l10n['days'] ?? 'days'}",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
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

  Widget _buildNumerologyAnalysisSection(BuildContext context, WidgetRef ref) {
    final numerology = ref.watch(numerologyProvider);
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);

    // Don't show anything if no birthdate selected
    if (ref.watch(birthdateProvider) == null) return const SizedBox.shrink();

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

          if (numerology.absentNumbers != null &&
              numerology.absentNumbers!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Divider(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text(
              l10n['absent_numbers_label'] ?? "Missing Numbers",
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.2),
                    ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.05,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                        ),
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
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.5,
                              ),
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
                  })
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoshuPlanesSection(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> l10n,
  ) {
    final loshuPlanesAsync = ref.watch(loshuPlanesProvider);
    final theme = Theme.of(context);

    return loshuPlanesAsync.when(
      data: (planes) {
        if (planes.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.layers_outlined,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n['loshu_planes_label'] ?? "Loshu Grid Planes",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: planes.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final plane = planes[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.05,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.layers_outlined,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                plane.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          plane.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildNumberOccurrenceDetailsSection(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> l10n,
  ) {
    final detailsAsync = ref.watch(numberOccurrenceDetailsProvider);
    final theme = Theme.of(context);

    return detailsAsync.when(
      data: (details) {
        if (details.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.format_list_numbered_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n['number_occurrence_details_label'] ??
                        "Number Occurrence Details",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: details.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final detail = details[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.05,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Number",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    detail.number.toString(),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.secondary.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Occurrence",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    detail.occurrence.toString(),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: theme.colorScheme.secondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          detail.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildLoShuGrid(BuildContext context, List<List<String>> grid) {
    final theme = Theme.of(context);
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
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
                      right: col < 2
                          ? BorderSide(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                            )
                          : BorderSide.none,
                      bottom: row < 2
                          ? BorderSide(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                            )
                          : BorderSide.none,
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

  Widget _buildNumerologyGrid(
    BuildContext context,
    NumerologyState data,
    Map<String, String> l10n,
  ) {
    final theme = Theme.of(context);

    final items = [
      {
        'label': l10n['personality_number_label'] ?? 'Personality',
        'val': data.personality,
      },
      {
        'label': l10n['life_path_number_label'] ?? 'Life Path',
        'val': data.lifePath,
      },
      /* {
        'label': l10n['pinnacle1_number_label'] ?? 'Pinnacle 1',
        'val': data.pinnacle1,
      },
      {
        'label': l10n['pinnacle2_number_label'] ?? 'Pinnacle 2',
        'val': data.pinnacle2,
      },
      {
        'label': l10n['pinnacle3_number_label'] ?? 'Pinnacle 3',
        'val': data.pinnacle3,
      },
      {
        'label': l10n['pinnacle4_number_label'] ?? 'Pinnacle 4',
        'val': data.pinnacle4,
      },
      {
        'label': l10n['pinnacle_base_label'] ?? 'Pinnacle Base',
        'val': data.pinnacleBase,
      }, */
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        if (item['val'] == null) return const SizedBox.shrink();
        return Container(
          width: (MediaQuery.of(context).size.width - 80) / 2,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
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

  Widget _buildPersonalityDetails(BuildContext context, WidgetRef ref) {
    final personalityAsync = ref.watch(personalityDataProvider);
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);

    return personalityAsync.when(
      data: (data) {
        if (data == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.psychology_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n['personality_analysis_title'] ??
                        "Personality Analysis",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                context,
                Icons.stars_rounded,
                l10n['lord_label'] ?? "Lord",
                data.lord ?? "Unknown",
                Colors.amber[800]!,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                Icons.thumb_up_rounded,
                l10n['qualities_label'] ?? "Qualities",
                data.qualities ?? "Not specified",
                Colors.green[700]!,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                Icons.warning_amber_rounded,
                l10n['weaknesses_label'] ?? "Weaknesses",
                data.weaknesses ?? "Not specified",
                Colors.red[700]!,
              ),
              const SizedBox(height: 24),
              if (data.youShould != null && data.youShould!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 20,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n['recommendation_label'] ?? "You Should",
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.youShould!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (data.description != null && data.description!.isNotEmpty) ...[
                Text(
                  l10n['description_label'] ?? "Detailed Description",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.6,
                  ),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
