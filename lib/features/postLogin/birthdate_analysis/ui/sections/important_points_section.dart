import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/numerology_content_providers.dart';
import '../../model/numerology_ui_content.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

class ImportantPointsSection extends ConsumerWidget {
  final Function(String, AppLanguage) onHelp;

  const ImportantPointsSection({
    super.key,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importantPointsAsync = ref.watch(importantPointsProvider);
    final theme = Theme.of(context);
    final currentLang = ref.watch(languageProvider);
    final accent = AnalysisTheme.getAccent(theme);

    return importantPointsAsync.when(
      data: (points) {
        if (points.isEmpty) return const SizedBox.shrink();

        return MysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MysticHeader(
                title: NumerologyUIContent.getHeaderTitle(
                  'important_points',
                  currentLang,
                ),
                subtitle: NumerologyUIContent.getHeaderTitle(
                  'important_points_subtitle',
                  currentLang,
                ),
                icon: Icons.tips_and_updates_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                onHelp: () => onHelp('important_points', currentLang),
              ),
              const SizedBox(height: 20),
              ...points.map(
                (point) => MysticContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  borderColor: theme.colorScheme.secondary.withValues(
                    alpha: 0.2,
                  ),
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
                              (number) => MysticChip(
                                label: number,
                                color: theme.colorScheme.secondary,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        point.getDescription(currentLang),
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
