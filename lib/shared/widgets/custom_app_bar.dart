import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/localization_provider.dart';
import '../../core/services/analytics_service.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;

  const CustomAppBar({
    required this.title,
    this.showBack = true,
    this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectivelyShowBack = showBack && context.canPop();
    final currentLang = ref.watch(languageProvider);

    return AppBar(
      leading: effectivelyShowBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.mounted && context.canPop()) {
                  context.pop();
                }
              },
            )
          : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/app_logo.png',
            height: 32,
            width: 32,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
      automaticallyImplyLeading: !effectivelyShowBack,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextButton(
            onPressed: () {
              ref.read(languageProvider.notifier).toggleLanguage();
              final newLang = ref.read(languageProvider);
              ref
                  .read(analyticsServiceProvider)
                  .logClickEvent(
                    'language_toggled',
                    parameters: {'new_language': newLang.name},
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(
              currentLang == AppLanguage.english
                  ? 'EN'
                  : currentLang == AppLanguage.hindi
                  ? 'हि'
                  : 'म',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
