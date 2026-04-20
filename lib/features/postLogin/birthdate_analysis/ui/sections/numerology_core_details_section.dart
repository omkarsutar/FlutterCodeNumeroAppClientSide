import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/numerology_providers.dart';
import '../../model/numerology_ui_content.dart';
import '../../model/numerology_models.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../../../../../core/providers/birthdate_localization_provider.dart';
import '../../../cart/providers/birthdate_record_providers.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

class NumerologyCoreDetailsSection extends ConsumerWidget {
  final Function(String, AppLanguage) onHelp;

  const NumerologyCoreDetailsSection({
    super.key,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(birthdateProvider) == null) return const SizedBox.shrink();

    final numerology = ref.watch(numerologyProvider);
    final l10n = ref.watch(birthdateL10nProvider);

    return MysticSection(
      child: _buildNumerologyGrid(context, ref, numerology, l10n),
    );
  }

  Widget _buildNumerologyGrid(
    BuildContext context,
    WidgetRef ref,
    NumerologyState data,
    Map<String, String> l10n,
  ) {
    final theme = Theme.of(context);
    final currentLang = ref.watch(languageProvider);
    final accent = AnalysisTheme.getAccent(theme);

    final items = [
      {
        'label': NumerologyUIContent.getLabel('personality', currentLang),
        'val': data.personality,
        'icon': Icons.person_3_rounded,
        'key': 'personality_number',
      },
      {
        'label': NumerologyUIContent.getLabel('life_path', currentLang),
        'val': data.lifePath,
        'icon': Icons.directions_rounded,
        'key': 'life_path_number',
      },
    ];

    return Row(
      children: items.map((item) {
        if (item['val'] == null) return const Expanded(child: SizedBox());
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: items.indexOf(item) == 0 ? 6 : 0,
              left: items.indexOf(item) == 1 ? 6 : 0,
            ),
            child: MysticContentCard(
              padding: const EdgeInsets.all(12),
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
                      Expanded(
                        child: Text(
                          item['label'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => onHelp(item['key'] as String, currentLang),
                        borderRadius: BorderRadius.circular(12),
                        child: Icon(
                          Icons.help_outline_rounded,
                          size: 14,
                          color: accent.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
