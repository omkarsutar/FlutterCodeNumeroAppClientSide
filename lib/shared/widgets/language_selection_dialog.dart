import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/localization_provider.dart';
import '../../core/providers/app_localization_provider.dart';

class LanguageSelectionDialog extends ConsumerWidget {
  const LanguageSelectionDialog({super.key});

  static bool _isShowing = false;

  static Future<void> show(BuildContext context) async {
    if (_isShowing) return;
    _isShowing = true;
    await showDialog(
      context: context,
      barrierDismissible: false, // Force selection
      builder: (context) => const LanguageSelectionDialog(),
    );
    _isShowing = false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLang = ref.watch(languageProvider);
    final l10n = ref.watch(appL10nProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.language_rounded,
                color: theme.colorScheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n['choose_language_title'] ?? 'Choose Language',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n['select_language_subtitle'] ??
                  'Select your preferred language to continue',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            _LanguageOption(
              title: 'English',
              subtitle: l10n['default_language_label'] ?? 'Default language',
              isSelected: currentLang == AppLanguage.english,
              onTap: () => _handleSelection(context, ref, AppLanguage.english),
            ),
            const SizedBox(height: 12),
            _LanguageOption(
              title: 'हिंदी',
              subtitle: 'Hindi',
              isSelected: currentLang == AppLanguage.hindi,
              onTap: () => _handleSelection(context, ref, AppLanguage.hindi),
            ),
            const SizedBox(height: 12),
            _LanguageOption(
              title: 'मराठी',
              subtitle: 'Marathi',
              isSelected: currentLang == AppLanguage.marathi,
              onTap: () => _handleSelection(context, ref, AppLanguage.marathi),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _handleSelection(BuildContext context, WidgetRef ref, AppLanguage lang) {
    ref.read(languageProvider.notifier).setLanguage(lang);
    Navigator.of(context).pop();
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.7)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
