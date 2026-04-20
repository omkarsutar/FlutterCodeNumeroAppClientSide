import 'package:flutter/material.dart';
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
