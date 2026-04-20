import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../../../cart/providers/birthdate_record_providers.dart';
import '../../providers/narration_provider.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';
import '../widgets/oracle_widgets.dart';

class NarrationGuideSection extends ConsumerWidget {
  final AnimationController pulseController;

  const NarrationGuideSection({
    super.key,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(birthdateProvider) == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final accent = AnalysisTheme.getAccent(theme);
    final currentLang = ref.watch(languageProvider);
    final narrationState = ref.watch(narrationProvider);
    final narrationNotifier = ref.read(narrationProvider.notifier);

    final canPlay = ref.watch(birthdateProvider) != null;
    final playLabel = switch (currentLang) {
      AppLanguage.hindi => 'सुनिए',
      AppLanguage.marathi => 'ऐका',
      AppLanguage.english => 'Listen',
    };

    final title = switch (currentLang) {
      AppLanguage.hindi => 'नमस्ते!',
      AppLanguage.marathi => 'नमस्कार!',
      AppLanguage.english => 'Hello!',
    };

    final subtitle = switch (currentLang) {
      AppLanguage.hindi => 'क्या आप अपनी रिपोर्ट सुनना चाहते हैं?',
      AppLanguage.marathi => 'तुम्हाला तुमचा अहवाल ऐकायचा आहे का?',
      AppLanguage.english => 'Would you like to listen to your report?',
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.05),
                border: Border(
                  bottom: BorderSide(
                    color: accent.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: MysticHeader(
                title: title,
                subtitle: subtitle,
                icon: Icons.record_voice_over_rounded,
                iconColor: theme.colorScheme.secondary,
                iconBgColor: theme.colorScheme.secondary.withValues(
                  alpha: 0.12,
                ),
              ),
            ),
            MysticContentCard(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              gradientColors: [
                theme.brightness == Brightness.dark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.7),
                theme.brightness == Brightness.dark
                    ? const Color(0xFF0F172A).withValues(alpha: 0.6)
                    : accent.withValues(alpha: 0.05),
              ],
              borderColor: accent.withValues(alpha: 0.15),
              child: Row(
                children: [
                  OracleAvatar(
                    isPlaying: narrationState.isPlaying,
                    pulseController: pulseController,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          switch (currentLang) {
                            AppLanguage.hindi => 'ज्योतिष मार्गदर्शक',
                            AppLanguage.marathi => 'मार्गदर्शक आवाज',
                            AppLanguage.english => 'Oracle Guide',
                          },
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.secondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          switch (currentLang) {
                            AppLanguage.hindi =>
                              narrationState.isPlaying
                                  ? 'आपकी रिपोर्ट अभी पढ़ी जा रही है।'
                                  : narrationState.isPaused
                                  ? 'पठन रोका गया है।'
                                  : 'अपनी रिपोर्ट को आवाज़ में सुनें।',
                            AppLanguage.marathi =>
                              narrationState.isPlaying
                                  ? 'अहवाल वाचला जात आहे.'
                                  : narrationState.isPaused
                                  ? 'वाचन थांबवले आहे.'
                                  : 'अहवाल आवाजात ऐका.',
                            AppLanguage.english =>
                              narrationState.isPlaying
                                  ? 'Reading report aloud...'
                                  : narrationState.isPaused
                                  ? 'Reading is paused.'
                                  : 'Listen to your analysis.',
                          },
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OracleButton(
                              onPressed: canPlay
                                  ? () => narrationNotifier.playNarration(currentLang)
                                  : null,
                              icon: narrationState.isPaused
                                  ? Icons.play_arrow_rounded
                                  : Icons.volume_up_rounded,
                              label: playLabel,
                              isPrimary: true,
                            ),
                            if (narrationState.isPlaying || narrationState.isPaused) ...[
                              OracleButton(
                                onPressed: () => narrationNotifier.pauseNarration(),
                                icon: Icons.pause_rounded,
                              ),
                              OracleButton(
                                onPressed: () => narrationNotifier.stopNarration(),
                                icon: Icons.stop_rounded,
                                isError: true,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
