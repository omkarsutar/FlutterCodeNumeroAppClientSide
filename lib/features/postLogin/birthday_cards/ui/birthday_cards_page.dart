import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

import '../../../../core/providers/app_localization_provider.dart';
import '../../../../core/providers/localization_provider.dart';
import '../../../../core/providers/birthdate_localization_provider.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../shared/widgets/shared_widget_barrel.dart';
import '../../birthdate_analysis/ui/utils/analysis_theme.dart';
import '../../birthdate_analysis/ui/widgets/mystic_widgets.dart';
import 'widgets/birthday_card_share_template.dart';

class BirthdayCardsPage extends ConsumerStatefulWidget {
  const BirthdayCardsPage({super.key});

  @override
  ConsumerState<BirthdayCardsPage> createState() => _BirthdayCardsPageState();
}

class _BirthdayCardsPageState extends ConsumerState<BirthdayCardsPage> {
  DateTime? _selectedBirthdate;
  late TextEditingController _nameController;
  bool _isSharing = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Map<String, int> _calculateAgeComponents(DateTime birthdate) {
    final now = DateTime.now();
    int years = now.year - birthdate.year;
    int months = now.month - birthdate.month;
    int days = now.day - birthdate.day;

    if (days < 0) {
      months--;
      final prevMonth = DateTime(now.year, now.month, 0);
      days += prevMonth.day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    return {'years': years, 'months': months, 'days': days};
  }

  String _getYearLabel(int years, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return 'साल';
      case AppLanguage.marathi:
        return 'वर्ष';
      case AppLanguage.english:
        return 'Years';
    }
  }

  String _getMonthLabel(int months, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return 'महीने';
      case AppLanguage.marathi:
        return 'महिने';
      case AppLanguage.english:
        return 'Months';
    }
  }

  String _getDayLabel(int days, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return 'दिन';
      case AppLanguage.marathi:
        return 'दिवस';
      case AppLanguage.english:
        return 'Days';
    }
  }

  String _getYourAgeLabel(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return 'आज आपकी आयु है';
      case AppLanguage.marathi:
        return 'आज तुमचे वय आहे';
      case AppLanguage.english:
        return 'Your age today is';
    }
  }

  String _buildBirthdayCardShareText(AppLanguage lang) {
    const appInstallUrl =
        'https://play.google.com/store/apps/details?id=com.numeroshastra.client&referrer=utm_source%3Dsocial_media%26utm_campaign%3Dlaunch_2026%26utm_medium%3Dbirthday_card';
    final typedName = _nameController.text.trim();
    final nameSuffix = typedName.isEmpty ? '' : ' $typedName';
    final greeting = switch (lang) {
      AppLanguage.english => 'Happy Birthday$nameSuffix 🥳 🎉 ✨',
      AppLanguage.hindi => 'जन्मदिन की शुभकामनाएँ$nameSuffix 🥳 🎉 ✨',
      AppLanguage.marathi => 'वाढदिवसाच्या शुभेच्छा$nameSuffix 🥳 🎉 ✨',
    };

    return '$greeting\n\nOpen in app:\n$appInstallUrl\n\n#astrology #numerology #numeroshastra #birthday';
  }

  Future<void> _shareCard() async {
    if (_selectedBirthdate == null) return;

    setState(() {
      _isSharing = true;
    });

    try {
      final lang = ref.read(languageProvider);
      await Future.delayed(const Duration(milliseconds: 500));

      final image = await _screenshotController.capture();

      if (image != null && mounted) {
        final directory = await getTemporaryDirectory();
        final imagePath =
            '${directory.path}/birthday_card_${DateTime.now().millisecondsSinceEpoch}.png';
        await File(imagePath).writeAsBytes(image);

        ref
            .read(analyticsServiceProvider)
            .logClickEvent('birthday_card_shared');

        await Share.shareXFiles([
          XFile(imagePath),
        ], text: _buildBirthdayCardShareText(lang));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appL10nProvider);
    final birthdateL10n = ref.watch(birthdateL10nProvider);
    final lang = ref.watch(languageProvider);
    final accent = AnalysisTheme.getAccent(theme);

    final ageComponents = _selectedBirthdate != null
        ? _calculateAgeComponents(_selectedBirthdate!)
        : null;

    final personName = _nameController.text.isEmpty
        ? (l10n['enter_name'] ?? 'Enter Name')
        : _nameController.text;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n['birthday_cards'] ?? 'Birthday Cards'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
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
                foregroundColor: accent,
                backgroundColor: accent.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(
                lang == AppLanguage.english
                    ? 'EN'
                    : lang == AppLanguage.hindi
                    ? 'हि'
                    : 'म',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Birthdate Picker
            MysticSection(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedBirthdate ?? DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedBirthdate = picked;
                    });
                    ref
                        .read(analyticsServiceProvider)
                        .logClickEvent('birthday_card_date_selected');
                  }
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: accent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            birthdateL10n['birthdate_label'] ?? 'Birthdate',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedBirthdate != null
                                ? DateFormat(
                                    'dd MMMM yyyy',
                                  ).format(_selectedBirthdate!)
                                : (birthdateL10n['no_birthdate'] ??
                                      'No Birthdate'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: accent.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Name Editor
            MysticSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n['full_name'] ?? 'Full Name',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n['enter_name'] ?? 'Enter Name',
                      hintStyle: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: accent.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: accent.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accent, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_selectedBirthdate != null && ageComponents != null) ...[
              // Preview Card
              MysticSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getYourAgeLabel(lang),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Age Metrics
                    Row(
                      children: [
                        Expanded(
                          child: _AgeMetricChip(
                            value: ageComponents['years']!,
                            label: _getYearLabel(ageComponents['years']!, lang),
                            icon: Icons.workspace_premium_rounded,
                            theme: theme,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _AgeMetricChip(
                            value: ageComponents['months']!,
                            label: _getMonthLabel(
                              ageComponents['months']!,
                              lang,
                            ),
                            icon: Icons.calendar_view_month_rounded,
                            theme: theme,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _AgeMetricChip(
                            value: ageComponents['days']!,
                            label: _getDayLabel(ageComponents['days']!, lang),
                            icon: Icons.today_rounded,
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Birthday Card Preview
              BirthdayCardShareTemplate(
                screenshotController: _screenshotController,
                personName: personName,
                birthdate: _selectedBirthdate!,
                ageComponents: ageComponents,
                l10n: l10n,
                lang: lang,
              ),
              const SizedBox(height: 24),

              // Share Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSharing ? null : _shareCard,
                  icon: _isSharing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.share),
                  label: Text(
                    _isSharing
                        ? (l10n['birthday_card_share_loading'] ??
                              'Generating birthday card...')
                        : 'Share',
                    style: theme.textTheme.labelLarge,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: accent.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}

class _AgeMetricChip extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final ThemeData theme;

  const _AgeMetricChip({
    required this.value,
    required this.label,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return MysticContentCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.secondary),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
