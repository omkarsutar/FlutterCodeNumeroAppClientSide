import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/numerology_content_providers.dart';
import '../../model/numerology_ui_content.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

class MissingNumberRemediesSection extends ConsumerWidget {
  final Function(String, AppLanguage) onHelp;

  const MissingNumberRemediesSection({
    super.key,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remediesAsync = ref.watch(missingNumberRemediesProvider);
    final numbersNotForRemedyAsync = ref.watch(numbersNotForRemedyProvider);
    final theme = Theme.of(context);
    final currentLang = ref.watch(languageProvider);
    final accent = AnalysisTheme.getAccent(theme);

    return remediesAsync.when(
      data: (remedies) {
        return numbersNotForRemedyAsync.when(
          data: (numbersNotForRemedy) {
            if (remedies.isEmpty && numbersNotForRemedy.isEmpty) {
              return const SizedBox.shrink();
            }

            return MysticSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MysticHeader(
                    title: NumerologyUIContent.getHeaderTitle(
                      'missing_number_remedies',
                      currentLang,
                    ),
                    icon: Icons.healing_rounded,
                    iconColor: theme.colorScheme.secondary,
                    iconBgColor: theme.colorScheme.secondary.withValues(
                      alpha: 0.1,
                    ),
                    onHelp: () => onHelp('missing_number_remedies', currentLang),
                  ),
                  const SizedBox(height: 8),
                  Divider(
                    color: accent.withValues(alpha: 0.12),
                    height: 24,
                  ),
                  if (remedies.isNotEmpty) ...[
                    ...remedies.map(
                      (remedy) => MysticContentCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        gradientColors: [
                          theme.colorScheme.secondary.withValues(alpha: 0.05),
                          theme.colorScheme.surface,
                        ],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              NumerologyUIContent.getLabel(
                                'remedy_for_number',
                                currentLang,
                              ).replaceAll(
                                '{number}',
                                remedy.missingNumber.toString(),
                              ),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: accent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              remedy.getDescription(currentLang),
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
                    MysticContentCard(
                      borderColor: theme.colorScheme.error.withValues(
                        alpha: 0.2,
                      ),
                      gradientColors: [
                        theme.colorScheme.error.withValues(alpha: 0.05),
                        theme.colorScheme.surface,
                      ],
                      child: Text(
                        NumerologyUIContent.getLabel(
                          'no_remedy_instruction',
                          currentLang,
                        ).replaceAll(
                          '{numbers}',
                          _formatNumberList(numbersNotForRemedy),
                        ),
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
                    NumerologyUIContent.getLabel(
                      'remedy_instruction',
                      currentLang,
                    ),
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => const SizedBox.shrink(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  String _formatNumberList(List<int> numbers) {
    return numbers.map((number) => number.toString()).join(', ');
  }
}
