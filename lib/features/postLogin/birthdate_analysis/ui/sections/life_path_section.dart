import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/numerology_content_providers.dart';
import '../../model/numerology_ui_content.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

class LifePathSection extends ConsumerWidget {
  final Function(String, AppLanguage) onHelp;
  final GlobalKey Function(int)? getSubKey;

  const LifePathSection({
    super.key,
    required this.onHelp,
    this.getSubKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lifePathAsync = ref.watch(lifePathNumberDataProvider);
    final theme = Theme.of(context);
    final currentLang = ref.watch(languageProvider);
    final accent = AnalysisTheme.getAccent(theme);

    return lifePathAsync.when(
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();

        return MysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MysticHeader(
                title: NumerologyUIContent.getHeaderTitle(
                  'life_path_details',
                  currentLang,
                ),
                subtitle: NumerologyUIContent.getHeaderTitle(
                  'life_path_subtitle',
                  currentLang,
                ),
                icon: Icons.auto_stories_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                onHelp: () => onHelp('life_path_number', currentLang),
              ),
              const SizedBox(height: 24),
              ...data.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return MysticContentCard(
                    key: getSubKey?.call(index),
                    margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          MysticChip(
                            label: 'Life Path No: ${item.lifePathNumber}',
                            color: accent,
                            icon: Icons.explore_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.getDescription(currentLang),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
