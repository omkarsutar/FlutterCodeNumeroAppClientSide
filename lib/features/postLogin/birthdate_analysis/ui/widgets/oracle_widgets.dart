import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../../providers/narration_provider.dart';
import '../utils/analysis_theme.dart';

class OracleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? label;
  final bool isPrimary;
  final bool isError;

  const OracleButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.isPrimary = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AnalysisTheme.getAccent(theme);
    final baseColor = isPrimary
        ? theme.colorScheme.secondary
        : isError
        ? theme.colorScheme.error
        : accent;

    if (label != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: baseColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label!,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      );
    }

    return IconButton.filled(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: baseColor.withValues(alpha: isError ? 0.1 : 0.15),
        foregroundColor: baseColor,
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: baseColor.withValues(alpha: 0.2)),
      ),
      icon: Icon(icon, size: 20),
    );
  }
}

class OracleAvatar extends StatelessWidget {
  final bool isPlaying;
  final AnimationController pulseController;

  const OracleAvatar({
    super.key,
    required this.isPlaying,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AnalysisTheme.getAccent(theme);

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isPlaying)
          ScaleTransition(
            scale: Tween(begin: 1.0, end: 1.3).animate(
              CurvedAnimation(
                parent: pulseController,
                curve: Curves.easeInOutSine,
              ),
            ),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.secondary.withValues(
                      alpha: 0.2,
                    ),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        Container(
          width: 90,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.secondary.withValues(
                  alpha: 0.2,
                ),
                accent.withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(
              color: theme.colorScheme.secondary.withValues(
                alpha: 0.3,
              ),
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 15,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 55,
                child: Container(
                  width: 55,
                  height: 60,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              // Wave Indicator
              if (isPlaying)
                Positioned(
                  bottom: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      return ScaleTransition(
                        scale: Tween(begin: 0.6, end: 1.2).animate(
                          CurvedAnimation(
                            parent: pulseController,
                            curve: Interval(
                              index * 0.2,
                              1.0,
                              curve: Curves.easeInOut,
                            ),
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 2,
                          ),
                          width: 5,
                          height: 15,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
class OracleGuideVideoDialog extends ConsumerStatefulWidget {
  final AnimationController pulseController;

  const OracleGuideVideoDialog({
    super.key,
    required this.pulseController,
  });

  @override
  ConsumerState<OracleGuideVideoDialog> createState() => _OracleGuideVideoDialogState();
}

class _OracleGuideVideoDialogState extends ConsumerState<OracleGuideVideoDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final narrationState = ref.watch(narrationProvider);
    final narrationNotifier = ref.read(narrationProvider.notifier);
    final accent = AnalysisTheme.getAccent(theme);
    
    // Progress calculation
    final progress = narrationState.totalChunks > 0 
        ? narrationState.currentChunk / narrationState.totalChunks 
        : 0.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accent.withValues(alpha: 0.2), width: 2),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: -5,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Video Player Area
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background/Character Image
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: 0.9,
                        child: Image.network(
                          'https://api.gemini.google.com/image/oracle_guide_character_1777359525221.png', // Placeholder or use generated image path
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person_pin_rounded,
                            size: 100,
                            color: accent.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Talking Animation (Subtle Pulse on character)
                  if (narrationState.isPlaying)
                    AnimatedBuilder(
                      animation: widget.pulseController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                accent.withValues(alpha: 0.2 * widget.pulseController.value),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  // Overlay Controls (YouTube Style)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Top Title Bar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "LIVE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "Oracle Guide - Birthdate Analysis",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Center Play/Pause Overlay
                  if (narrationState.isPaused)
                    IconButton(
                      icon: const Icon(Icons.play_arrow_rounded, size: 80, color: Colors.white70),
                      onPressed: () => narrationNotifier.playNarration(ref.read(languageProvider)),
                    ),

                  // Bottom Progress Bar
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                          minHeight: 3,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  narrationState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () {
                                  if (narrationState.isPlaying) {
                                    narrationNotifier.pauseNarration();
                                  } else {
                                    narrationNotifier.playNarration(ref.read(languageProvider));
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.stop_rounded, color: Colors.white, size: 30),
                                onPressed: () => narrationNotifier.stopNarration(),
                              ),
                              const Spacer(),
                              Text(
                                "${(progress * 100).toInt()}%",
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.fullscreen_rounded, color: Colors.white),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Info Area
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF1E293B),
                        child: Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Personalized Oracle Guide",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              "Listening to your mystical patterns...",
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
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
