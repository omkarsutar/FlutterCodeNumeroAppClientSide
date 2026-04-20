import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/numerology_content_providers.dart';
import '../../model/numerology_ui_content.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

class MissingNumberTellsSection extends ConsumerWidget {
  final Function(String, AppLanguage) onHelp;

  const MissingNumberTellsSection({
    super.key,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missingNumberTellsAsync = ref.watch(missingNumberTellsProvider);
    final theme = Theme.of(context);
    final currentLang = ref.watch(languageProvider);
    final accent = AnalysisTheme.getAccent(theme);

    return missingNumberTellsAsync.when(
      data: (tells) {
        if (tells.isEmpty) return const SizedBox.shrink();

        return MysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MysticHeader(
                title: NumerologyUIContent.getHeaderTitle(
                  'missing_number_tells',
                  currentLang,
                ),
                subtitle: NumerologyUIContent.getHeaderTitle(
                  'missing_number_tells_subtitle',
                  currentLang,
                ),
                icon: Icons.remove_circle_outline_rounded,
                iconColor: theme.colorScheme.error,
                iconBgColor: theme.colorScheme.error.withValues(alpha: 0.1),
                onHelp: () => onHelp('missing_number_tells', currentLang),
              ),
              const SizedBox(height: 24),
              ...tells.map(
                (tell) => MysticContentCard(
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
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.2,
                            ),
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
                              NumerologyUIContent.getLabel(
                                'missing_number_label',
                                currentLang,
                              ).replaceAll(
                                '{number}',
                                tell.missingNumber.toString(),
                              ),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: accent,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              tell.getDescription(currentLang),
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
