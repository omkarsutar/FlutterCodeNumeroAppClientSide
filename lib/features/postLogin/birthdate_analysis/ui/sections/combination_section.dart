import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/numerology_content_providers.dart';
import '../../model/numerology_ui_content.dart';
import '../../model/numerology_models.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

class CombinationSection extends ConsumerWidget {
  final Function(String, AppLanguage) onHelp;

  const CombinationSection({
    super.key,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combinationAsync = ref.watch(combinationDataProvider);
    final theme = Theme.of(context);
    final currentLang = ref.watch(languageProvider);

    return combinationAsync.when(
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();

        return MysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MysticHeader(
                title: NumerologyUIContent.getHeaderTitle(
                  'combination_analysis',
                  currentLang,
                ),
                subtitle: NumerologyUIContent.getHeaderTitle(
                  'combination_subtitle',
                  currentLang,
                ),
                icon: Icons.hub_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                onHelp: () => onHelp('combination_analysis', currentLang),
              ),
              const SizedBox(height: 24),
              ...data.map(
                (item) => MysticContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCombinationGrid(context, item, currentLang),
                      const SizedBox(height: 20),
                      Text(
                        item.getDescription(currentLang),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                      if (item.getExample(currentLang).isNotEmpty) ...[
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
                                  "${NumerologyUIContent.getLabel('example', currentLang)}: ${item.getExample(currentLang)}",
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildCombinationGrid(
    BuildContext context,
    CombinationData data,
    AppLanguage currentLang,
  ) {
    final theme = Theme.of(context);
    final accent = AnalysisTheme.getAccent(theme);
    final items = [
      {
        'label': NumerologyUIContent.getLabel('personality', currentLang),
        'val': data.personalityNumber,
        'icon': Icons.person_3_rounded,
      },
      {
        'label': NumerologyUIContent.getLabel('life_path', currentLang),
        'val': data.lifePathNumber,
        'icon': Icons.directions_rounded,
      },
    ];

    return Row(
      children: items.map((item) {
        if (item['val'] == null) return const SizedBox.shrink();
        final isFirst = item == items.first;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: isFirst ? 6 : 0,
              left: isFirst ? 0 : 6,
            ),
            child: MysticContentCard(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 14,
                        color: accent.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          item['label'] as String,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item['val'].toString(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
