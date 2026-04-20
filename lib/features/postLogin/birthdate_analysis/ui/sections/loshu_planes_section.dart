import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/numerology_content_providers.dart';
import '../../model/numerology_ui_content.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

class LoshuPlanesSection extends ConsumerWidget {
  final Function(String, AppLanguage) onHelp;

  const LoshuPlanesSection({
    super.key,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loShuPlanesAsync = ref.watch(loshuPlanesProvider);
    final theme = Theme.of(context);
    final lang = ref.watch(languageProvider);
    final accent = AnalysisTheme.getAccent(theme);

    return loShuPlanesAsync.when(
      data: (planes) {
        if (planes.isEmpty) return const SizedBox.shrink();

        return MysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MysticHeader(
                title: NumerologyUIContent.getHeaderTitle(
                  'lo_shu_planes',
                  lang,
                ),
                subtitle: NumerologyUIContent.getHeaderTitle(
                  'lo_shu_planes_subtitle',
                  lang,
                ),
                icon: Icons.layers_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                onHelp: () => onHelp('lo_shu_planes', lang),
              ),
              const SizedBox(height: 24),
              ...planes.map(
                (plane) => MysticContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plane.getTitle(lang),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        plane.getDescription(lang),
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
