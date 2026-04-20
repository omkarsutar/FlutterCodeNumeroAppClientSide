import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/numerology_content_providers.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

class TestimonialsSection extends ConsumerStatefulWidget {
  const TestimonialsSection({super.key});

  @override
  ConsumerState<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends ConsumerState<TestimonialsSection> {
  late final PageController _testimonialController;
  int _testimonialPage = 0;

  @override
  void initState() {
    super.initState();
    _testimonialController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _testimonialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final testimonialsAsync = ref.watch(staticTestimonialsProvider);
    final theme = Theme.of(context);
    final lang = ref.watch(languageProvider);
    final accent = AnalysisTheme.getAccent(theme);

    return testimonialsAsync.when(
      data: (testimonials) {
        if (testimonials.isEmpty) return const SizedBox.shrink();

        final activePage = _testimonialPage.clamp(0, testimonials.length - 1);

        return MysticSection(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: MysticHeader(
                  title: 'Success Stories',
                  icon: Icons.forum_rounded,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 340,
                child: PageView.builder(
                  controller: _testimonialController,
                  itemCount: testimonials.length,
                  onPageChanged: (index) {
                    setState(() {
                      _testimonialPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final testimonial = testimonials[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: MysticContentCard(
                        gradientColors: [
                          accent.withValues(alpha: 0.1),
                          theme.colorScheme.surface,
                        ],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: accent.withValues(alpha: 0.2),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      testimonial.image,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 60,
                                                height: 60,
                                                color: accent.withValues(alpha: 0.1),
                                                child: Icon(
                                                  Icons.person_rounded,
                                                  color: accent,
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    testimonial.personName,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: accent,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Icon(
                              Icons.format_quote_rounded,
                              size: 28,
                              color: accent.withValues(alpha: 0.35),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Text(
                                  testimonial.getDescription(lang),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.55,
                                  ),
                                ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(testimonials.length, (index) {
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
