import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/numerology_providers.dart';
import '../../model/numerology_ui_content.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../../../cart/providers/birthdate_record_providers.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

class LoShuGridSection extends ConsumerWidget {
  final Function(String, AppLanguage) onHelp;

  const LoShuGridSection({
    super.key,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(birthdateProvider) == null) return const SizedBox.shrink();

    final numerology = ref.watch(numerologyProvider);
    final theme = Theme.of(context);
    final currentLang = ref.watch(languageProvider);
    final accent = AnalysisTheme.getAccent(theme);

    return MysticSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MysticHeader(
            title: NumerologyUIContent.getHeaderTitle(
              'numerical_analysis',
              currentLang,
            ),
            icon: Icons.grid_view_rounded,
            subtitle: NumerologyUIContent.getHeaderTitle(
              'lo_shu_grid_subtitle',
              currentLang,
            ),
            trailing: MysticChip(
              label: NumerologyUIContent.getLabel(
                'lo_shu_grid',
                currentLang,
              ),
              color: theme.colorScheme.secondary,
            ),
            onHelp: () => onHelp('lo_shu_grid', currentLang),
          ),
          if (numerology.loShuGrid != null) ...[
            const SizedBox(height: 24),
            _buildLoShuGrid(context, numerology.loShuGrid!, accent),
          ],
          if (numerology.absentNumbers != null &&
              numerology.absentNumbers!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Divider(color: accent.withValues(alpha: 0.1)),
            const SizedBox(height: 20),
            Text(
              NumerologyUIContent.getLabel('missing_numbers_grid', currentLang),
              style: theme.textTheme.titleSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: numerology.absentNumbers!.map((n) {
                return MysticChip(
                  label: n.toString(),
                  color: theme.colorScheme.error,
                  icon: Icons.do_not_disturb_on_rounded,
                );
              }).toList(),
            ),
          ],
          if (numerology.numberOccurrences != null) ...[
            const SizedBox(height: 24),
            Divider(color: accent.withValues(alpha: 0.1)),
            const SizedBox(height: 20),
            Text(
              NumerologyUIContent.getLabel('occurrences_grid', currentLang),
              style: theme.textTheme.titleSmall?.copyWith(
                color: accent,
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
                    return MysticChip(
                      label:
                          NumerologyUIContent.getLabel(
                                'occurrence_chip_format',
                                currentLang,
                              )
                              .replaceAll('{number}', e.key.toString())
                              .replaceAll('{count}', e.value.toString())
                              .replaceAll(
                                '{times}',
                                e.value == 1
                                    ? NumerologyUIContent.getLabel(
                                        'time_singular',
                                        currentLang,
                                      )
                                    : NumerologyUIContent.getLabel(
                                        'time_plural',
                                        currentLang,
                                      ),
                              ),
                      color: accent,
                      icon: Icons.repeat_rounded,
                    );
                  })
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoShuGrid(BuildContext context, List<List<String>> grid, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accent.withValues(alpha: 0.1),
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
                      child: _buildGridCell(context, grid[r][c], accent),
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

  Widget _buildGridCell(BuildContext context, String value, Color accent) {
    final theme = Theme.of(context);
    final isNotEmpty = value.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isNotEmpty
            ? theme.colorScheme.secondary.withValues(alpha: 0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNotEmpty
              ? theme.colorScheme.secondary.withValues(alpha: 0.3)
              : accent.withValues(alpha: 0.1),
          width: isNotEmpty ? 2 : 1,
        ),
        boxShadow: isNotEmpty
            ? [
                BoxShadow(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: theme.textTheme.headlineSmall?.copyWith(
          color: isNotEmpty ? theme.colorScheme.secondary : accent.withValues(alpha: 0.3),
          fontWeight: isNotEmpty ? FontWeight.w900 : FontWeight.w400,
        ),
      ),
    );
  }
}
