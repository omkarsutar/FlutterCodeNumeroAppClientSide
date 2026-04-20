import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/numerology_content_providers.dart';
import '../../model/numerology_ui_content.dart';
import '../../../../../core/providers/localization_provider.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

class StockMarketInfoSection extends ConsumerWidget {
  final Function(String, AppLanguage) onHelp;

  const StockMarketInfoSection({
    super.key,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockMarketInfoAsync = ref.watch(stockMarketInfoProvider);
    final theme = Theme.of(context);
    final currentLang = ref.watch(languageProvider);
    final accent = AnalysisTheme.getAccent(theme);

    return stockMarketInfoAsync.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();

        return MysticSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MysticHeader(
                title: NumerologyUIContent.getHeaderTitle(
                  'stock_market',
                  currentLang,
                ),
                subtitle: NumerologyUIContent.getHeaderTitle(
                  'stock_market_subtitle',
                  currentLang,
                ),
                icon: Icons.trending_up_rounded,
                iconColor: Colors.green,
                iconBgColor: Colors.green.withValues(alpha: 0.1),
                onHelp: () => onHelp('stock_market', currentLang),
              ),
              const SizedBox(height: 20),
              ...items.map(
                (item) => MysticContentCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  borderColor: Colors.green.withValues(alpha: 0.2),
                  gradientColors: [
                    Colors.green.withValues(alpha: 0.05),
                    theme.colorScheme.surface,
                  ],
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.insights_rounded,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.includedNumbers.isNotEmpty) ...[
                              Text(
                                'Numbers: ${item.includedNumbers.join(", ")}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            Text(
                              item.getDescription(currentLang),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.55,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
