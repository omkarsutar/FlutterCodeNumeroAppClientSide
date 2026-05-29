import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

import '../../../../../core/providers/localization_provider.dart';

class BirthdayCardShareTemplate extends StatelessWidget {
  final ScreenshotController screenshotController;
  final String personName;
  final DateTime birthdate;
  final Map<String, int> ageComponents;
  final Map<String, String> l10n;
  final AppLanguage lang;

  const BirthdayCardShareTemplate({
    super.key,
    required this.screenshotController,
    required this.personName,
    required this.birthdate,
    required this.ageComponents,
    required this.l10n,
    required this.lang,
  });

  String _getTurningYearsText(int years) {
    final template = l10n['turning_years'] ?? 'Turning {years} years';
    return template.replaceAll('{years}', years.toString());
  }

  String _getYearLabel() {
    return switch (lang) {
      AppLanguage.hindi => 'साल',
      AppLanguage.marathi => 'वर्ष',
      AppLanguage.english => 'Years',
    };
  }

  String _getMonthLabel() {
    return switch (lang) {
      AppLanguage.hindi => 'महीने',
      AppLanguage.marathi => 'महिने',
      AppLanguage.english => 'Months',
    };
  }

  String _getDayLabel() {
    return switch (lang) {
      AppLanguage.hindi => 'दिन',
      AppLanguage.marathi => 'दिवस',
      AppLanguage.english => 'Days',
    };
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFFF4C542);
    final secondaryColor = const Color(0xFF66D1C1);
    final cardColor = const Color(0xFF16263E);
    final years = ageComponents['years'] ?? 0;

    return Screenshot(
      controller: screenshotController,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0B1422),
                const Color(0xFF13243A),
                const Color(0xFF0C1727),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -120,
                right: -80,
                child: _buildDecorativeCircle(
                  360,
                  accentColor.withValues(alpha: 0.09),
                ),
              ),
              Positioned(
                bottom: -70,
                left: -70,
                child: _buildDecorativeCircle(
                  320,
                  secondaryColor.withValues(alpha: 0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'NUMERO SHASTRA',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.66),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (l10n['happy_birthday'] ?? 'Happy Birthday')
                          .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.24),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              personName,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('dd MMMM yyyy').format(birthdate),
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberCard(
                            ageComponents['years'].toString(),
                            _getYearLabel(),
                            accentColor,
                            cardColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildNumberCard(
                            ageComponents['months'].toString(),
                            _getMonthLabel(),
                            secondaryColor,
                            cardColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildNumberCard(
                            ageComponents['days'].toString(),
                            _getDayLabel(),
                            accentColor,
                            cardColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cake_rounded, color: accentColor, size: 24),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _getTurningYearsText(years),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(
                          color: Colors.white.withValues(alpha: 0.15),
                          height: 16,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (l10n['birthday_card_by'] ?? 'Birthday card by')
                              .toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/app_logo.png',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'NUMERO SHASTRA',
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberCard(
    String number,
    String label,
    Color color,
    Color cardColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
