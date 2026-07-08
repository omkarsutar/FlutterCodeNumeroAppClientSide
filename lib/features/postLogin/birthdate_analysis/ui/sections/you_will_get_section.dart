import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/numerology_content_providers.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

/// A horizontally-scrollable PageView that showcases what a user gets in the
/// Detailed Analysis, sourced from the [birthdate_features] Supabase table.
///
/// Each tile shows:
///   - Localized **title** above the image (accent-colored, bold)
///   - Full-width **image** that fills the tile width
///   - Localized **description** below the image
///
/// Used on both the My Cart page and the Birthdate Analysis page.
class YouWillGetSection extends ConsumerStatefulWidget {
  const YouWillGetSection({super.key});

  @override
  ConsumerState<YouWillGetSection> createState() => _YouWillGetSectionState();
}

class _YouWillGetSectionState extends ConsumerState<YouWillGetSection> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featuresAsync = ref.watch(birthdateFeaturesProvider);
    final lang = ref.watch(languageProvider);
    final theme = Theme.of(context);
    final accent = AnalysisTheme.getAccent(theme);

    return featuresAsync.when(
      loading: () => MysticSection(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: MysticHeader(
                title: 'You will get ✨',
                icon: Icons.stars_rounded,
                iconColor: Colors.amber,
                iconBgColor: Colors.amber.withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 340,
              child: Center(
                child: CircularProgressIndicator(
                  color: accent,
                  strokeWidth: 2,
                ),
              ),
            ),
          ],
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (features) {
        if (features.isEmpty) return const SizedBox.shrink();

        final activePage = _currentPage.clamp(0, features.length - 1);

        return MysticSection(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section header ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: MysticHeader(
                  title: 'You will get ✨',
                  icon: Icons.stars_rounded,
                  iconColor: Colors.amber,
                  iconBgColor: Colors.amber.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(height: 18),

              // ── Feature cards PageView ───────────────────────────────────
              SizedBox(
                height: 340,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: features.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final feature = features[index];
                    final title = feature.getTitle(lang);
                    final description = feature.getDescription(lang);
                    final hasImage =
                        feature.imageUrl != null && feature.imageUrl!.isNotEmpty;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Title above image ──────────────────────────
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    accent.withValues(alpha: 0.08),
                                    theme.colorScheme.surface,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Text(
                                title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // ── Full-width image ──────────────────────────
                            Expanded(
                              child: hasImage
                                  ? Image.network(
                                      feature.imageUrl!,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) =>
                                          _buildPlaceholder(accent),
                                      loadingBuilder: (
                                        context,
                                        child,
                                        progress,
                                      ) {
                                        if (progress == null) return child;
                                        return Container(
                                          color: accent.withValues(alpha: 0.05),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: progress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? progress
                                                          .cumulativeBytesLoaded /
                                                      progress
                                                          .expectedTotalBytes!
                                                  : null,
                                              color: accent,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : _buildPlaceholder(accent),
                            ),

                            // ── Description below image ───────────────────
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                10,
                                16,
                                14,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.surface,
                                    accent.withValues(alpha: 0.05),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Text(
                                description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // ── Page indicator dots ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(features.length, (index) {
                  final isActive = index == activePage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? accent
                          : accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Branded gradient placeholder shown when [imageUrl] is absent or fails to load.
  Widget _buildPlaceholder(Color accent) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.08),
            accent.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome_rounded,
          size: 48,
          color: accent.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}
