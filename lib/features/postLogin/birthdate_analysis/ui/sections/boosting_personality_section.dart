import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/numerology_content_providers.dart';
import '../../model/numerology_ui_content.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

class BoostingPersonalitySection extends ConsumerWidget {
  final Function(String, AppLanguage) onHelp;

  const BoostingPersonalitySection({
    super.key,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boostingAsync = ref.watch(boostingPersonalityDataProvider);
    final theme = Theme.of(context);
    final currentLang = ref.watch(languageProvider);
    final accent = AnalysisTheme.getAccent(theme);

    return boostingAsync.when(
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();

        return MysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MysticHeader(
                title: NumerologyUIContent.getHeaderTitle(
                  'boosting_personality',
                  currentLang,
                ),
                subtitle: NumerologyUIContent.getHeaderTitle(
                  'boosting_personality_subtitle',
                  currentLang,
                ),
                icon: Icons.rocket_launch_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                onHelp: () => onHelp('boosting_personality', currentLang),
              ),
              const SizedBox(height: 24),
              ...data.map(
                (item) => MysticContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          MysticChip(
                            label: 'Personality No: ${item.personalityNumber}',
                            color: accent,
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
