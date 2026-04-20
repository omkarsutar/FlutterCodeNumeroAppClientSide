import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/numerology_content_providers.dart';
import '../../model/numerology_ui_content.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

class PersonalityAnalysisSection extends ConsumerWidget {
  final Function(String, AppLanguage) onHelp;

  const PersonalityAnalysisSection({
    super.key,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personalityAsync = ref.watch(personalityDataProvider);
    final theme = Theme.of(context);
    final currentLang = ref.watch(languageProvider);
    final accent = AnalysisTheme.getAccent(theme);

    return personalityAsync.when(
      data: (data) {
        if (data == null) return const SizedBox.shrink();

        return MysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MysticHeader(
                title: NumerologyUIContent.getHeaderTitle(
                  'personality_analysis',
                  currentLang,
                ),
                subtitle: NumerologyUIContent.getLabel(
                  'personality_analysis_label',
                  currentLang,
                ).replaceAll('{number}', data.personalityNumber.toString()),
                icon: Icons.psychology_rounded,
                onHelp: () => onHelp('personality_number', currentLang),
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                context,
                Icons.stars_rounded,
                NumerologyUIContent.getLabel('lord', currentLang),
                data.getLord(currentLang),
                Colors.amber[800]!,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                Icons.thumb_up_rounded,
                NumerologyUIContent.getLabel('qualities', currentLang),
                data.getQualities(currentLang),
                Colors.green[700]!,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                Icons.warning_amber_rounded,
                NumerologyUIContent.getLabel('weaknesses', currentLang),
                data.getWeaknesses(currentLang),
                Colors.red[700]!,
              ),
              const SizedBox(height: 24),
              if (data.getYouShould(currentLang).isNotEmpty) ...[
                MysticContentCard(
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
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            NumerologyUIContent.getLabel(
                              'recommendation',
                              currentLang,
                            ),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.getYouShould(currentLang),
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
              if (data.getDescription(currentLang).isNotEmpty) ...[
                Text(
                  NumerologyUIContent.getLabel('detailed_insight', currentLang),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.getDescription(currentLang),
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
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
