import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../../../cart/providers/birthdate_record_providers.dart';
import '../../model/numerology_ui_content.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

class AgeIndicatorSection extends ConsumerWidget {
  final VoidCallback onEditName;

  const AgeIndicatorSection({
    super.key,
    required this.onEditName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final birthdate = ref.watch(birthdateProvider);
    if (birthdate == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final accent = AnalysisTheme.getAccent(theme);
    final ageText = ref.watch(ageProvider);
    final ageComponents = ref.watch(ageComponentsProvider);
    if (ageComponents == null) return const SizedBox.shrink();

    final currentLang = ref.watch(languageProvider);
    final birthdateRecord = ref.watch(currentBirthdateRecordProvider);
    final fullName = birthdateRecord?['full_name'] as String? ?? 'Age Snapshot';
    final birthdateId = birthdateRecord?['id'] as String?;

    return MysticSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_top_rounded,
                  color: accent,
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
                              color: accent,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (birthdateId != null)
                          IconButton(
                            icon: const Icon(Icons.edit, size: 22),
                            onPressed: onEditName,
                            tooltip: 'Edit Name',
                            color: accent,
                          ),
                      ],
                    ),
                    Text(
                      currentLang == AppLanguage.hindi
                          ? 'आज आपकी आयु है'
                          : currentLang == AppLanguage.marathi
                              ? 'आज तुमचे वय आहे'
                              : 'Your age today is',
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
          MysticContentCard(
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
                child: _AgeMetricChip(
                  value: ageComponents['years']!,
                  label: NumerologyUIContent.getLabel('years', currentLang),
                  icon: Icons.workspace_premium_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AgeMetricChip(
                  value: ageComponents['months']!,
                  label: NumerologyUIContent.getLabel('months', currentLang),
                  icon: Icons.calendar_view_month_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AgeMetricChip(
                  value: ageComponents['days']!,
                  label: NumerologyUIContent.getLabel('days', currentLang),
                  icon: Icons.today_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgeMetricChip extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;

  const _AgeMetricChip({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MysticContentCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.secondary),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.secondary,
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
}
