import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/numerology_ui_content.dart';
import '../../model/numerology_models.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

class PinnacleSection extends ConsumerWidget {
  final FutureProvider<List<PinnacleData>> provider;
  final String title;
  final Function(String, AppLanguage) onHelp;
  final Key? subKey;

  const PinnacleSection({
    super.key,
    required this.provider,
    required this.title,
    required this.onHelp,
    this.subKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinnacleAsync = ref.watch(provider);
    final theme = Theme.of(context);
    final currentLang = ref.watch(languageProvider);
    final accent = AnalysisTheme.getAccent(theme);

    return pinnacleAsync.when(
      data: (pinnacles) {
        if (pinnacles.isEmpty) return const SizedBox.shrink();

        return MysticSection(
          key: subKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MysticHeader(
                title: NumerologyUIContent.getHeaderTitle(title, currentLang),
                subtitle: NumerologyUIContent.getHeaderTitle(
                  'pinnacle_subtitle',
                  currentLang,
                ),
                icon: Icons.query_stats_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                onHelp: () => onHelp('pinnacles', currentLang),
              ),
              const SizedBox(height: 24),
              ...pinnacles.map(
                (pinnacle) => MysticContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${NumerologyUIContent.getLabel('age_prefix', currentLang)}: ${pinnacle.lifePeriodRange}",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: accent,
                              ),
                            ),
                          ),
                          MysticChip(
                            label: 'Pinnacle No: ${pinnacle.pinnacleno}',
                            color: theme.colorScheme.secondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        pinnacle.getDescription(currentLang),
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
