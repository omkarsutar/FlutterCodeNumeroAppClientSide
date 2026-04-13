import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_supabase_order_app_mobile/shared/widgets/shared_widget_barrel.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../cart/providers/cart_providers.dart';
import '../../cart/providers/cart_controller.dart';
import '../model/numerology_models.dart';
import '../providers/numerology_content_providers.dart';
import '../providers/numerology_providers.dart';
import '../../../../core/providers/localization_provider.dart';
import '../../../../core/providers/birthdate_localization_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../router/app_routes.dart';
import '../../../../core/utils/dialogs.dart';
import '../../../../core/services/analytics_service.dart';


class BirthdateAnalysisPage extends ConsumerStatefulWidget {
  const BirthdateAnalysisPage({super.key});

  @override
  ConsumerState<BirthdateAnalysisPage> createState() =>
      _BirthdateAnalysisPageState();
}

class _BirthdateAnalysisPageState extends ConsumerState<BirthdateAnalysisPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _testimonialController = PageController(
    viewportFraction: 0.88,
  );
  int _testimonialPage = 0;

  @override
  void dispose() {
    _testimonialController.dispose();
    super.dispose();
  }

  Future<void> _refreshAnalysisData() async {
    ref.invalidate(currentBirthdateRecordProvider);
    ref.invalidate(birthdatesStreamProvider);

    final birthdate = ref.read(birthdateProvider);
    if (birthdate == null) {
      ref.invalidate(birthdatesStreamProvider);
      return;
    }

    await Future.wait([
      ref.refresh(birthdatesStreamProvider.future),
      ref.refresh(personalityDataProvider.future),
      ref.refresh(loshuPlanesProvider.future),
      ref.refresh(numberOccurrenceDetailsProvider.future),
      ref.refresh(missingNumberTellsProvider.future),
      ref.refresh(staticTestimonialsProvider.future),
      ref.refresh(importantPointsProvider.future),
      ref.refresh(stockMarketInfoProvider.future),
      ref.refresh(remedyValuesProvider.future),
      ref.refresh(pinnacleData1Provider.future),
      ref.refresh(pinnacleData2Provider.future),
      ref.refresh(pinnacleData3Provider.future),
      ref.refresh(pinnacleData4Provider.future),
      ref.refresh(lifePathNumberDataProvider.future),
      ref.refresh(careerDataProvider.future),
      ref.refresh(boostingPersonalityDataProvider.future),
      ref.refresh(combinationDataProvider.future),
    ]);
  }

  void _navigateToCartAndSelect(DateTime birthdate) async {
    final record = ref.read(currentBirthdateRecordProvider);

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
    final l10n = ref.watch(birthdateL10nProvider);
    final birthdate = ref.watch(birthdateProvider);
    final cartStatus = ref.watch(cartStatusProvider);
    final currentLang = ref.watch(languageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshAnalysisData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    stretch: true,
                    expandedHeight: 0,
                    toolbarHeight: 70,
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.onSurface,
                    elevation: 0,
                    centerTitle: true,
                    leading: IconButton(
                      icon: const Icon(Icons.menu_rounded),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    title: Text(
                      l10n['birthdate_analysis'] ?? 'Birthdate Analysis',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: TextButton(
                          onPressed: () {
                            ref
                                .read(languageProvider.notifier)
                                .toggleLanguage();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Text(
                            currentLang == AppLanguage.english
                                ? 'EN'
                                : currentLang == AppLanguage.hindi
                                    ? '\u0939\u093f'
                                    : '\u092e',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(1),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _BirthdateHeaderDelegate(
                      child: _buildBirthdatePickerTile(
                        context,
                        birthdate,
                        l10n,
                        integrated: true,
                      ),
                      backgroundColor: theme.colorScheme.surface,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildAgeIndicatorTile(context, birthdate, l10n),
                        _buildNumerologyCoreDetailsTile(context, ref),
                        _buildPersonalityDetails(context, ref),
                        _buildNumerologyAnalysisSection(context, ref),
                        _buildLoshuPlanesSection(context, ref, l10n),
                        _buildRemedyValuesSection(context, ref),
                        _buildMissingNumberTellsSection(context, ref, l10n),
                        _buildMissingNumberRemediesSection(context, ref),
                        _buildNumberOccurrenceDetailsSection(
                          context,
                          ref,
                          l10n,
                        ),
                        _buildImportantPointsSection(context, ref),
                        _buildStockMarketInfoSection(context, ref),
                        _buildPinnacleSection(
                          context,
                          ref,
                          l10n,
                          pinnacleData1Provider,
                          "1st Pinnacle stage of Life",
                        ),
                        _buildPinnacleSection(
                          context,
                          ref,
                          l10n,
                          pinnacleData2Provider,
                          "2nd Pinnacle stage of Life",
                        ),
                        _buildPinnacleSection(
                          context,
                          ref,
                          l10n,
                          pinnacleData3Provider,
                          "3rd Pinnacle stage of Life",
                        ),
                        _buildPinnacleSection(
                          context,
                          ref,
                          l10n,
                          pinnacleData4Provider,
                          "4th Pinnacle stage of Life",
                        ),
                        _buildLifePathSection(context, ref, l10n),
                        _buildCareerSection(context, ref, l10n),
                        _buildBoostingPersonalitySection(context, ref, l10n),
                        _buildCombinationSection(context, ref, l10n),
                        _buildTestimonialsSection(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
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
    if (cartStatus != null && cartStatus.toLowerCase() != 'pending') {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isPending = cartStatus?.toLowerCase() == 'pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isPending ? theme.colorScheme.secondary : theme.colorScheme.primary)
                    .withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: birthdate == null
                ? null
                : () {
                    if (isPending) {
                      ref.read(analyticsServiceProvider).logClickEvent('read_more_clicked');
                      _navigateToCartAndSelect(birthdate);
                    } else {
                      ref.read(analyticsServiceProvider).logClickEvent('save_birthdate_clicked');
                      _handleOrderAction(birthdate);
                    }
                  },
            icon: Icon(
              isPending ? Icons.auto_awesome_rounded : Icons.lock_open_rounded,
              size: 20,
            ),
            label: Text(
              isPending
                  ? (l10n['read_more'] ?? 'Unlock Full Analysis')
                  : (l10n['save_birthdate'] ?? 'Save & Analyze'),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPending
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
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
    Map<String, String> l10n, {
    bool integrated = false,
  }) {
    final theme = Theme.of(context);
    final dateDisplay =
        birthdate != null ? DateFormat('dd-MMM-yyyy').format(birthdate) : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: birthdate ?? DateTime(1990),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            ref.read(birthdateProvider.notifier).state = picked;
            ref.read(analyticsServiceProvider).logAnalysisView(picked);
          }
        },
        child: _buildMysticSection(
          margin: integrated ? EdgeInsets.zero : const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "${l10n['birthdate_label'] ?? 'Birthdate'} : $dateDisplay",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Icon(
                Icons.calendar_month_rounded,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgeIndicatorTile(
    BuildContext context,
    DateTime? birthdate,
    Map<String, String> l10n,
  ) {
    if (birthdate == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final ageText = ref.watch(ageProvider);
    final ageComponents = ref.watch(ageComponentsProvider);
    if (ageComponents == null) return const SizedBox.shrink();

    final birthdateRecord = ref.watch(currentBirthdateRecordProvider);
    final fullName = birthdateRecord?['full_name'] as String? ?? 'Age Snapshot';
    final birthdateId = birthdateRecord?['id'] as String?;

    return _buildMysticSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_top_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fullName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (birthdateId != null)
                          IconButton(
                            icon: const Icon(Icons.edit_note_rounded, size: 22),
                            onPressed: () => _updateBirthdateName(
                              birthdateId,
                              fullName == 'Age Snapshot' ? '' : fullName,
                            ),
                            tooltip: 'Edit Name',
                            color: theme.colorScheme.primary,
                          ),
                      ],
                    ),
                    Text(
                      l10n['age_prefix'] ?? 'Your age today is',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMysticContentCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Text(
              ageText ?? '',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAgeMetricChip(
                  context,
                  value: ageComponents['years']!,
                  label: l10n['years'] ?? 'years',
                  icon: Icons.workspace_premium_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAgeMetricChip(
                  context,
                  value: ageComponents['months']!,
                  label: l10n['months'] ?? 'months',
                  icon: Icons.calendar_view_month_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAgeMetricChip(
                  context,
                  value: ageComponents['days']!,
                  label: l10n['days'] ?? 'days',
                  icon: Icons.today_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgeMetricChip(
    BuildContext context, {
    required int value,
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return _buildMysticContentCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumerologyCoreDetailsTile(BuildContext context, WidgetRef ref) {
    if (ref.watch(birthdateProvider) == null) return const SizedBox.shrink();

    final numerology = ref.watch(numerologyProvider);
    final l10n = ref.watch(birthdateL10nProvider);

    return _buildMysticSection(
      child: _buildNumerologyGrid(context, numerology, l10n),
    );
  }

  Widget _buildNumerologyAnalysisSection(BuildContext context, WidgetRef ref) {
    if (ref.watch(birthdateProvider) == null) return const SizedBox.shrink();

    final numerology = ref.watch(numerologyProvider);
    final l10n = ref.watch(birthdateL10nProvider);
    final theme = Theme.of(context);

    return _buildMysticSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildMysticHeader(
                  title: l10n['numerology_summary'] ?? 'Numerical Analysis',
                  icon: Icons.grid_view_rounded,
                  subtitle: 'Ancient secrets revealed through numbers',
                ),
              ),
              _buildMysticChip(
                label: 'Lo Shu Grid',
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
          if (numerology.loShuGrid != null) ...[
            const SizedBox(height: 24),
            _buildLoShuGrid(context, numerology.loShuGrid!),
          ],
          if (numerology.absentNumbers != null &&
              numerology.absentNumbers!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Divider(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
            const SizedBox(height: 20),
            Text(
              l10n['absent_numbers_label'] ??
                  "Missing Numbers (from Lo Shu Grid)",
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: numerology.absentNumbers!.map((n) {
                return _buildMysticChip(
                  label: n.toString(),
                  color: theme.colorScheme.error,
                  icon: Icons.do_not_disturb_on_rounded,
                );
              }).toList(),
            ),
          ],
          if (numerology.numberOccurrences != null) ...[
            const SizedBox(height: 24),
            Divider(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
            const SizedBox(height: 20),
            Text(
              l10n['occurrence_label'] ?? "Number Occurrences",
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: numerology.numberOccurrences!.entries
                  .where((e) => e.value > 0)
                  .map((e) {
                return _buildMysticChip(
                  label: "${e.key} : ${e.value}",
                  color: theme.colorScheme.primary,
                  icon: Icons.repeat_rounded,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          for (var r = 0; r < 3; r++) ...[
            Row(
              children: [
                for (var c = 0; c < 3; c++) ...[
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _buildGridCell(context, grid[r][c]),
                    ),
                  ),
                  if (c < 2) const SizedBox(width: 6),
                ],
              ],
            ),
            if (r < 2) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  Widget _buildGridCell(BuildContext context, String value) {
    final theme = Theme.of(context);
    final isPresent = value.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isPresent
            ? theme.colorScheme.primary.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPresent
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.primary.withValues(alpha: 0.05),
          width: isPresent ? 2 : 1,
        ),
        boxShadow: isPresent
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: isPresent
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
      ),
    );
  }

  Widget _buildNumerologyMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return _buildMysticContentCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(BuildContext context) {
    final testimonialsAsync = ref.watch(staticTestimonialsProvider);
    final theme = Theme.of(context);

    return testimonialsAsync.when(
      data: (testimonials) {
        if (testimonials.isEmpty) return const SizedBox.shrink();

        final activePage = _testimonialPage.clamp(0, testimonials.length - 1);

        return _buildMysticSection(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildMysticHeader(
                  title: 'Success Stories',
                  icon: Icons.forum_rounded,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 340,
                child: PageView.builder(
                  controller: _testimonialController,
                  itemCount: testimonials.length,
                  onPageChanged: (index) {
                    setState(() {
                      _testimonialPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final testimonial = testimonials[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _buildMysticContentCard(
                        gradientColors: [
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                          theme.colorScheme.surface,
                        ],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.2),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      testimonial.image,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        width: 60,
                                        height: 60,
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    testimonial.personName,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Icon(
                              Icons.format_quote_rounded,
                              size: 28,
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.35,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Text(
                                  testimonial.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.55,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(testimonials.length, (index) {
                  final isActive = index == activePage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SmallErrorView(
        error: err,
        onRetry: () => ref.invalidate(staticTestimonialsProvider),
        message: 'Could not load testimonials',
      ),
    );
  }

  Widget _buildImportantPointsSection(BuildContext context, WidgetRef ref) {
    final importantPointsAsync = ref.watch(importantPointsProvider);
    final theme = Theme.of(context);

    return importantPointsAsync.when(
      data: (points) {
        if (points.isEmpty) return const SizedBox.shrink();

        return _buildMysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMysticHeader(
                title: 'Important Points',
                subtitle: 'Based on present numbers in your Lo Shu Grid',
                icon: Icons.tips_and_updates_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 20),
              ...points.map(
                (point) => _buildMysticContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  borderColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
                  gradientColors: [
                    theme.colorScheme.secondary.withValues(alpha: 0.05),
                    theme.colorScheme.surface,
                  ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: point.includedNumbers
                            .map(
                              (number) => _buildMysticChip(
                                label: number,
                                color: theme.colorScheme.secondary,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        point.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SmallErrorView(
        error: err,
        onRetry: () => ref.invalidate(importantPointsProvider),
        message: 'Could not load important points',
      ),
    );
  }

  Widget _buildStockMarketInfoSection(BuildContext context, WidgetRef ref) {
    final stockMarketInfoAsync = ref.watch(stockMarketInfoProvider);
    final theme = Theme.of(context);

    return stockMarketInfoAsync.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();

        return _buildMysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMysticHeader(
                title: 'Stock Market Insight',
                icon: Icons.trending_up_rounded,
                iconColor: Colors.green,
                iconBgColor: Colors.green.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 20),
              ...items.map(
                (item) => _buildMysticContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  borderColor: Colors.green.withValues(alpha: 0.2),
                  gradientColors: [
                    Colors.green.withValues(alpha: 0.05),
                    theme.colorScheme.surface,
                  ],
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.insights_rounded,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.insight,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.55,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SmallErrorView(
        error: err,
        onRetry: () => ref.invalidate(stockMarketInfoProvider),
        message: 'Could not load stock market insight',
      ),
    );
  }

  Widget _buildRemedyValuesSection(BuildContext context, WidgetRef ref) {
    final remedyValuesAsync = ref.watch(remedyValuesProvider);
    final theme = Theme.of(context);

    return remedyValuesAsync.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        final remedy = items.first;

        return _buildMysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMysticHeader(
                title: 'Lucky - Unlucky',
                icon: Icons.auto_fix_high_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 24),
              _buildRemedyGroup(
                context,
                title: 'Lucky Numbers',
                values: remedy.luckyNumbers.map((e) => e.toString()).toList(),
                color: Colors.green,
              ),
              _buildRemedyGroup(
                context,
                title: 'Unlucky Numbers',
                values: remedy.unluckyNumbers.map((e) => e.toString()).toList(),
                color: Colors.red,
              ),
              _buildRemedyGroup(
                context,
                title: 'Lucky Colors',
                values: remedy.luckyColors,
                color: Colors.blue,
              ),
              _buildRemedyGroup(
                context,
                title: 'Unlucky Colors',
                values: remedy.unluckyColors,
                color: Colors.orange,
              ),
              _buildRemedyGroup(
                context,
                title: 'Lucky Days',
                values: remedy.luckyDays,
                color: theme.colorScheme.secondary,
              ),
              _buildRemedyGroup(
                context,
                title: 'Numbers For Remedy',
                values: remedy.numbersForRemedy
                    .map((e) => e.toString())
                    .toList(),
                color: theme.colorScheme.primary,
              ),
              _buildRemedyGroup(
                context,
                title: 'Numbers Not For Remedy',
                values: remedy.numbersNotForRemedy
                    .map((e) => e.toString())
                    .toList(),
                color: theme.colorScheme.error,
                isLast: true,
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SmallErrorView(
        error: err,
        onRetry: () => ref.invalidate(remedyValuesProvider),
        message: 'Could not load remedies',
      ),
    );
  }

  Widget _buildRemedyGroup(
    BuildContext context, {
    required String title,
    required List<String> values,
    required Color color,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    if (values.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: values
                .map(
                  (value) => _buildMysticChip(
                    label: value,
                    color: color,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingNumberRemediesSection(
    BuildContext context,
    WidgetRef ref,
  ) {
    final remediesAsync = ref.watch(missingNumberRemediesProvider);
    final numbersNotForRemedyAsync = ref.watch(numbersNotForRemedyProvider);
    final theme = Theme.of(context);

    return remediesAsync.when(
      data: (remedies) {
        return numbersNotForRemedyAsync.when(
          data: (numbersNotForRemedy) {
            if (remedies.isEmpty && numbersNotForRemedy.isEmpty) {
              return const SizedBox.shrink();
            }

            return _buildMysticSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMysticHeader(
                    title: 'Missing Number Remedies',
                    icon: Icons.healing_rounded,
                    iconColor: theme.colorScheme.secondary,
                    iconBgColor:
                        theme.colorScheme.secondary.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 8),
                  Divider(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    height: 24,
                  ),
                  if (remedies.isNotEmpty) ...[
                    ...remedies.map(
                      (remedy) => _buildMysticContentCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        gradientColors: [
                          theme.colorScheme.secondary.withValues(alpha: 0.05),
                          theme.colorScheme.surface,
                        ],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Remedy for number ${remedy.missingNumber}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              remedy.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (numbersNotForRemedy.isNotEmpty) ...[
                    _buildMysticContentCard(
                      borderColor: theme.colorScheme.error.withValues(alpha: 0.2),
                      gradientColors: [
                        theme.colorScheme.error.withValues(alpha: 0.05),
                        theme.colorScheme.surface,
                      ],
                      child: Text(
                        'No remedy to number ${_formatNumberList(numbersNotForRemedy)} as ${numbersNotForRemedy.length == 1 ? 'this is' : 'they are'} enemy to you',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    '[Multiple remedies are given for each number, do any 1 remedy for 1 number as per your convenience]',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => SmallErrorView(
            error: err,
            onRetry: () => ref.invalidate(numbersNotForRemedyProvider),
            message: 'Could not load enemy numbers',
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SmallErrorView(
        error: err,
        onRetry: () => ref.invalidate(missingNumberRemediesProvider),
        message: 'Could not load missing number remedies',
      ),
    );
  }

  String _formatNumberList(List<int> numbers) {
    return numbers.map((number) => number.toString()).join(', ');
  }

  Widget _buildNumberOccurrenceDetailsSection(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> l10n,
  ) {
    final occurrenceDetailsAsync = ref.watch(numberOccurrenceDetailsProvider);
    final theme = Theme.of(context);

    return occurrenceDetailsAsync.when(
      data: (details) {
        if (details.isEmpty) return const SizedBox.shrink();

        return _buildMysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMysticHeader(
                title: l10n['occurrence_label'] ?? "Number Occurrences Details",
                subtitle: 'Deep insight into repeated numbers in your grid',
                icon: Icons.auto_graph_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 24),
              ...details.map(
                (detail) => _buildMysticContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                theme.colorScheme.primary.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '${detail.number}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Number ${detail.number} (${detail.occurrence} ${detail.occurrence == 1 ? 'time' : 'times'})',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              detail.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SmallErrorView(
        error: err,
        onRetry: () => ref.invalidate(numberOccurrenceDetailsProvider),
        message: 'Could not load occurrences details',
      ),
    );
  }

  Widget _buildMissingNumberTellsSection(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> l10n,
  ) {
    final missingNumberTellsAsync = ref.watch(missingNumberTellsProvider);
    final theme = Theme.of(context);

    return missingNumberTellsAsync.when(
      data: (tells) {
        if (tells.isEmpty) return const SizedBox.shrink();

        return _buildMysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMysticHeader(
                title: 'Missing Number Tells',
                subtitle: 'Based on absent numbers in your Lo Shu Grid',
                icon: Icons.remove_circle_outline_rounded,
                iconColor: theme.colorScheme.error,
                iconBgColor: theme.colorScheme.error.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 24),
              ...tells.map(
                (tell) => _buildMysticContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  borderColor: theme.colorScheme.error.withValues(alpha: 0.15),
                  gradientColors: [
                    theme.colorScheme.error.withValues(alpha: 0.05),
                    theme.colorScheme.surface,
                  ],
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.error.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '${tell.missingNumber}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Missing Number ${tell.missingNumber}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              tell.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SmallErrorView(
        error: err,
        onRetry: () => ref.invalidate(missingNumberTellsProvider),
        message: 'Could not load missing number details',
      ),
    );
  }

  Widget _buildLoshuPlanesSection(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> l10n,
  ) {
    final loShuPlanesAsync = ref.watch(loshuPlanesProvider);
    final theme = Theme.of(context);

    return loShuPlanesAsync.when(
      data: (planes) {
        if (planes.isEmpty) return const SizedBox.shrink();

        return _buildMysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMysticHeader(
                title: 'Lo Shu Planes',
                subtitle: 'Horizontal, Vertical and Diagonal planes analysis',
                icon: Icons.layers_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 24),
              ...planes.map(
                (plane) => _buildMysticContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              plane.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          _buildMysticChip(
                            label: plane.gridPosition,
                            color: theme.colorScheme.secondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        plane.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SmallErrorView(
        error: err,
        onRetry: () => ref.invalidate(loshuPlanesProvider),
        message: 'Could not load lo shu planes',
      ),
    );
  }

  Widget _buildCareerSection(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> l10n,
  ) {
    final careerInfoAsync = ref.watch(careerDataProvider);
    final theme = Theme.of(context);

    return careerInfoAsync.when(
      data: (info) {
        if (info.isEmpty) return const SizedBox.shrink();

        return _buildMysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMysticHeader(
                title: 'Career & Destiny',
                subtitle: 'Your professional path and life purpose',
                icon: Icons.work_history_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 24),
              ...info.map(
                (item) => _buildMysticContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildMysticChip(
                            label: 'Life Path ${item.lifePathNumber}',
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.careerDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SmallErrorView(
        error: err,
        onRetry: () => ref.invalidate(careerDataProvider),
        message: 'Could not load career info',
      ),
    );
  }

  Widget _buildCombinationSection(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> l10n,
  ) {
    final combinationAsync = ref.watch(combinationDataProvider);
    final theme = Theme.of(context);

    return combinationAsync.when(
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();

        return _buildMysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMysticHeader(
                title: l10n['combination_analysis_label'] ??
                    "Personality & Life Path Combination",
                subtitle: 'Synergy between your numbers',
                icon: Icons.hub_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 24),
              ...data.map(
                (item) => _buildMysticContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCombinationGrid(context, l10n, item),
                      const SizedBox(height: 20),
                      Text(
                        item.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                      if (item.example.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.secondary.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                size: 16,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Example: ${item.example}",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SmallErrorView(
        error: err,
        onRetry: () => ref.invalidate(combinationDataProvider),
        message: 'Could not load combination analysis',
      ),
    );
  }



  Widget _buildBoostingPersonalitySection(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> l10n,
  ) {
    final boostingAsync = ref.watch(boostingPersonalityDataProvider);
    final theme = Theme.of(context);

    return boostingAsync.when(
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();

        return _buildMysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMysticHeader(
                title: l10n['boosting_personality_label'] ?? "Boosting Personality",
                subtitle: 'Practical tips to enhance your vibrational energy',
                icon: Icons.rocket_launch_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 24),
              ...data.map(
                (item) => _buildMysticContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildMysticChip(
                            label: 'Number ${item.personalityNumber}',
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.boostingDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SmallErrorView(
        error: err,
        onRetry: () => ref.invalidate(boostingPersonalityDataProvider),
        message: 'Could not load boosting info',
      ),
    );
  }

  Widget _buildLifePathSection(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> l10n,
  ) {
    final lifePathAsync = ref.watch(lifePathNumberDataProvider);
    final theme = Theme.of(context);

    return lifePathAsync.when(
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();

        return _buildMysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMysticHeader(
                title: l10n['life_path_details_label'] ?? "Life Path Details",
                subtitle: 'Understanding your soul\'s journey through numbers',
                icon: Icons.auto_stories_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 24),
              ...data.map(
                (item) => _buildMysticContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildMysticChip(
                            label: 'Life Path ${item.lifePathNumber}',
                            color: theme.colorScheme.primary,
                            icon: Icons.explore_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SmallErrorView(
        error: err,
        onRetry: () => ref.invalidate(lifePathNumberDataProvider),
        message: 'Could not load life path details',
      ),
    );
  }

  Widget _buildPinnacleSection(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> l10n,
    FutureProvider<List<PinnacleData>> provider,
    String title,
  ) {
    final pinnacleAsync = ref.watch(provider);
    final theme = Theme.of(context);

    return pinnacleAsync.when(
      data: (pinnacles) {
        if (pinnacles.isEmpty) return const SizedBox.shrink();

        return _buildMysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMysticHeader(
                title: title,
                subtitle: 'Life cycle analysis for specific age periods',
                icon: Icons.query_stats_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 24),
              ...pinnacles.map(
                (pinnacle) => _buildMysticContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Age: ${pinnacle.lifePeriodRange}",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          _buildMysticChip(
                            label: 'Number ${pinnacle.pinnacleno}',
                            color: theme.colorScheme.secondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        pinnacle.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SmallErrorView(
        error: err,
        onRetry: () => ref.invalidate(provider),
        message: 'Could not load pinnacle data',
      ),
    );
  }

  // --- Helper Widgets ---

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
        'icon': Icons.person_3_rounded,
      },
      {
        'label': l10n['life_path_number_label'] ?? 'Life Path',
        'val': data.lifePath,
        'icon': Icons.directions_rounded,
      },
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        if (item['val'] == null) return const SizedBox.shrink();
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 44) / 2,
          child: _buildMysticContentCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 14,
                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item['label'] as String,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item['val'].toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCombinationGrid(
    BuildContext context,
    Map<String, String> l10n,
    CombinationData data,
  ) {
    final theme = Theme.of(context);
    final items = [
      {
        'label': l10n['personality_number_label'] ?? 'Personality',
        'val': data.personalityNumber,
        'icon': Icons.person_3_rounded,
      },
      {
        'label': l10n['life_path_number_label'] ?? 'Life Path',
        'val': data.lifePathNumber,
        'icon': Icons.directions_rounded,
      },
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        if (item['val'] == null) return const SizedBox.shrink();
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 44) / 2,
          child: _buildMysticContentCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 14,
                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item['label'] as String,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item['val'].toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPersonalityDetails(BuildContext context, WidgetRef ref) {
    final personalityAsync = ref.watch(personalityDataProvider);
    final l10n = ref.watch(birthdateL10nProvider);
    final theme = Theme.of(context);

    return personalityAsync.when(
      data: (data) {
        if (data == null) return const SizedBox.shrink();

        return _buildMysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMysticHeader(
                title: l10n['personality_analysis_title'] ?? "Personality Analysis",
                icon: Icons.psychology_rounded,
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
                _buildMysticContentCard(
                  borderColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
                  gradientColors: [
                    theme.colorScheme.secondary.withValues(alpha: 0.05),
                    theme.colorScheme.surface,
                  ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n['recommendation_label'] ?? "You Should",
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.youShould!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (data.description != null && data.description!.isNotEmpty) ...[
                Text(
                  l10n['description_label'] ?? "Detailed Insight",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.6,
                    letterSpacing: 0.1,
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
      error: (e, s) => SmallErrorView(
        error: e,
        onRetry: () => ref.invalidate(personalityDataProvider),
        message: 'Could not load personality analysis',
      ),
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

  Future<void> _handleOrderAction(DateTime birthdate) async {
    final l10n = ref.read(birthdateL10nProvider);
    final session = ref.read(supabaseClientProvider).auth.currentSession;
    if (session == null) {
      if (mounted) {
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

    if (!mounted) return;
    showLoadingDialog(
      context: context,
      message: l10n['please_wait'] ?? 'Placing order...',
    );

    try {
      await ref.read(cartControllerProvider).placeOrder(birthdate: birthdate);

      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading
        await _showThankYouDialog();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateBirthdateName(String id, String currentName) async {
    final l10n = ref.read(birthdateL10nProvider);
    final theme = Theme.of(context);
    final controller = TextEditingController(text: currentName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n['edit_name'] ?? 'Edit Name',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n['full_name'] ?? 'Full Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.person_outline),
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n['cancel'] ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n['save'] ?? 'Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != currentName) {
      if (!mounted) return;
      showLoadingDialog(
        context: context,
        message: l10n['please_wait'] ?? 'Updating...',
      );

      try {
        await ref.read(cartControllerProvider).updateBirthdateName(id, newName);

        if (mounted) {
          Navigator.of(context).pop(); // Dismiss loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n['name_updated_success'] ?? 'Name updated successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Dismiss loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update name: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showThankYouDialog() {
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
                  'Analysis Unlocked!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your birthdate analysis is now saved and unlocked successfully. You can now explore all the hidden secrets of your birthdate!',
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
                      'View Analysis',
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

  // --- Mystic Shastra Design System Helpers ---

  Widget _buildMysticSection({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? borderColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: borderColor ?? theme.colorScheme.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMysticHeader({
    required String title,
    required IconData icon,
    String? subtitle,
    Color? iconColor,
    Color? iconBgColor,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor ?? theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor ?? theme.colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMysticContentCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    List<Color>? gradientColors,
    Color? borderColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors ??
              [
                theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
                theme.colorScheme.surface,
              ],
        ),
      ),
      child: child,
    );
  }

  Widget _buildMysticChip({
    required String label,
    Color? color,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final baseColor = color ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: baseColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: baseColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: baseColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}


class _BirthdateHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color backgroundColor;

  _BirthdateHeaderDelegate({
    required this.child,
    required this.backgroundColor,
  });

  @override
  double get minExtent => 76;

  @override
  double get maxExtent => 76;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _BirthdateHeaderDelegate oldDelegate) {
    return child != oldDelegate.child ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
