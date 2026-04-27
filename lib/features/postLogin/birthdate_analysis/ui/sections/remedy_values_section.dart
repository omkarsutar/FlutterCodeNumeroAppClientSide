import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/numerology_content_providers.dart';
import '../../model/numerology_ui_content.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

class RemedyValuesSection extends ConsumerWidget {
  final Function(String, AppLanguage) onHelp;

  const RemedyValuesSection({super.key, required this.onHelp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remedyValuesAsync = ref.watch(remedyValuesProvider);
    final theme = Theme.of(context);
    final lang = ref.watch(languageProvider);
    final accent = AnalysisTheme.getAccent(theme);

    return remedyValuesAsync.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        final remedy = items.first;

        final luckyNumbers = remedy.luckyNumbers
            .map((e) => e.toString())
            .toList();
        final unluckyNumbers = remedy.unluckyNumbers
            .map((e) => e.toString())
            .toList();
        final luckyColors = remedy.getLuckyColors(lang);
        final unluckyColors = remedy.getUnluckyColors(lang);
        final luckyDays = remedy.getLuckyDays(lang);
        final numbersForRemedy = remedy.numbersForRemedy
            .map((e) => e.toString())
            .toList();
        final numbersNotForRemedy = remedy.numbersNotForRemedy
            .map((e) => e.toString())
            .toList();

        if (luckyNumbers.isEmpty &&
            unluckyNumbers.isEmpty &&
            luckyColors.isEmpty &&
            unluckyColors.isEmpty &&
            luckyDays.isEmpty &&
            numbersForRemedy.isEmpty &&
            numbersNotForRemedy.isEmpty) {
          return const SizedBox.shrink();
        }

        return MysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MysticHeader(
                title: NumerologyUIContent.getHeaderTitle(
                  'lucky_unlucky',
                  lang,
                ),
                icon: Icons.auto_fix_high_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                onHelp: () => onHelp('lucky_unlucky', lang),
              ),
              const SizedBox(height: 24),
              if (luckyNumbers.isNotEmpty)
                _buildRemedyGroup(
                  context,
                  title: NumerologyUIContent.getLabel('lucky_number', lang),
                  values: luckyNumbers,
                  color: Colors.green,
                  accent: accent,
                ),
              if (unluckyNumbers.isNotEmpty)
                _buildRemedyGroup(
                  context,
                  title: NumerologyUIContent.getLabel('unlucky_number', lang),
                  values: unluckyNumbers,
                  color: Colors.red,
                  accent: accent,
                ),
              if (luckyColors.isNotEmpty)
                _buildRemedyGroup(
                  context,
                  title: NumerologyUIContent.getLabel('lucky_color', lang),
                  values: luckyColors,
                  color: Colors.blue,
                  accent: accent,
                ),
              if (unluckyColors.isNotEmpty)
                _buildRemedyGroup(
                  context,
                  title: NumerologyUIContent.getLabel('unlucky_color', lang),
                  values: unluckyColors,
                  color: Colors.orange,
                  accent: accent,
                ),
              if (luckyDays.isNotEmpty)
                _buildRemedyGroup(
                  context,
                  title: NumerologyUIContent.getLabel('lucky_day', lang),
                  values: luckyDays,
                  color: theme.colorScheme.secondary,
                  accent: accent,
                ),
              if (numbersForRemedy.isNotEmpty)
                _buildRemedyGroup(
                  context,
                  title: NumerologyUIContent.getLabel(
                    'numbers_for_remedy',
                    lang,
                  ),
                  values: numbersForRemedy,
                  color: accent,
                  accent: accent,
                ),
              if (numbersNotForRemedy.isNotEmpty)
                _buildRemedyGroup(
                  context,
                  title: NumerologyUIContent.getLabel(
                    'numbers_not_for_remedy',
                    lang,
                  ),
                  values: numbersNotForRemedy,
                  color: theme.colorScheme.error,
                  accent: accent,
                  isLast: true,
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildRemedyGroup(
    BuildContext context, {
    required String title,
    required List<String> values,
    required Color color,
    required Color accent,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: values.map((v) {
            return MysticChip(label: v, color: color);
          }).toList(),
        ),
        if (!isLast) ...[
          const SizedBox(height: 20),
          Divider(color: accent.withValues(alpha: 0.08)),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}
