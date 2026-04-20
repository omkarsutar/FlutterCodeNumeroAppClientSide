import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/numerology_content_providers.dart';
import '../../model/numerology_ui_content.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

class NumberOccurrenceDetailsSection extends ConsumerWidget {
  final Function(String, AppLanguage) onHelp;

  const NumberOccurrenceDetailsSection({
    super.key,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occurrenceDetailsAsync = ref.watch(numberOccurrenceDetailsProvider);
    final theme = Theme.of(context);
    final lang = ref.watch(languageProvider);
    final accent = AnalysisTheme.getAccent(theme);

    return occurrenceDetailsAsync.when(
      data: (details) {
        if (details.isEmpty) return const SizedBox.shrink();

        return MysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MysticHeader(
                title: NumerologyUIContent.getHeaderTitle(
                  'occurrence_details',
                  lang,
                ),
                subtitle: NumerologyUIContent.getHeaderTitle(
                  'occurrence_details_subtitle',
                  lang,
                ),
                icon: Icons.auto_graph_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                onHelp: () => onHelp('number_occurrences', lang),
              ),
              const SizedBox(height: 24),
              ...details.map(
                (detail) => MysticContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accent.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '${detail.number}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: accent,
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
                              NumerologyUIContent.getLabel(
                                    'occurrence_format',
                                    lang,
                                  )
                                  .replaceAll(
                                    '{number}',
                                    detail.number.toString(),
                                  )
                                  .replaceAll(
                                    '{count}',
                                    detail.occurrence.toString(),
                                  )
                                  .replaceAll(
                                    '{times}',
                                    detail.occurrence == 1
                                        ? NumerologyUIContent.getLabel(
                                            'time_singular',
                                            lang,
                                          )
                                        : NumerologyUIContent.getLabel(
                                            'time_plural',
                                            lang,
                                          ),
                                  ),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: accent,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              detail.getDescription(lang),
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
