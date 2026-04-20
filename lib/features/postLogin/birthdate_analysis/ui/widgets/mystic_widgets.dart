import 'package:flutter/material.dart';
import '../utils/analysis_theme.dart';

class MysticHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final Color? iconColor;
  final Color? iconBgColor;
  final VoidCallback? onHelp;
  final Widget? trailing;

  const MysticHeader({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.iconColor,
    this.iconBgColor,
    this.onHelp,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AnalysisTheme.getAccent(theme);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor ?? accent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor ?? accent,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  if (trailing != null) ...[const SizedBox(width: 8), trailing!],
                  if (onHelp != null) ...[
                    const SizedBox(width: 4),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onHelp,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.help_outline_rounded,
                            size: 20,
                            color: accent.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class MysticContentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final List<Color>? gradientColors;
  final Color? borderColor;

  const MysticContentCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.gradientColors,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AnalysisTheme.getAccent(theme);

    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? accent.withValues(alpha: 0.1),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              gradientColors ??
              [
                theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.15,
                ),
                theme.colorScheme.surface,
              ],
        ),
      ),
      child: child,
    );
  }
}

class MysticChip extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;

  const MysticChip({
    super.key,
    required this.label,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = color ?? AnalysisTheme.getAccent(theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: baseColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: baseColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: baseColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class MysticSection extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;

  const MysticSection({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AnalysisTheme.getAccent(theme);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: borderColor ?? accent.withValues(alpha: 0.15),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
