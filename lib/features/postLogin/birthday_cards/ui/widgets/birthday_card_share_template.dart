import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:intl/intl.dart';
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

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFFF4C542);
    final secondaryColor = const Color(0xFF66D1C1);
    final cardColor = const Color(0xFF16263E);
    final years = ageComponents['years'] ?? 0;

    return Screenshot(
      controller: screenshotController,
      child: Container(
        width: 1080,
        height: 1920,
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
            // Decorative circles
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

            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  // App name header
                  Text(
                    "NUMERO SHASTRA",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.66),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    (l10n['happy_birthday'] ?? 'Happy Birthday').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Person info card
                  Container(
                    padding: const EdgeInsets.all(20),
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
                        Text(
                          personName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('dd MMMM yyyy').format(birthdate),
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Age metrics
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberCard(
                          ageComponents['years'].toString(),
                          lang == AppLanguage.hindi
                              ? 'साल'
                              : lang == AppLanguage.marathi
                              ? 'वर्ष'
                              : 'Years',
                          accentColor,
                          cardColor,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildNumberCard(
                          ageComponents['months'].toString(),
                          lang == AppLanguage.hindi
                              ? 'महीने'
                              : lang == AppLanguage.marathi
                              ? 'महिने'
                              : 'Months',
                          secondaryColor,
                          cardColor,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildNumberCard(
                          ageComponents['days'].toString(),
                          lang == AppLanguage.hindi
                              ? 'दिन'
                              : lang == AppLanguage.marathi
                              ? 'दिवस'
                              : 'Days',
                          accentColor,
                          cardColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Wish text
                  Text(
                    _getTurningYearsText(years),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Age text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: secondaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'You are ${ageComponents['years']} years ${ageComponents['months']} months ${ageComponents['days']} days old',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Footer branding
                  Column(
                    children: [
                      Divider(
                        color: Colors.white.withValues(alpha: 0.15),
                        height: 24,
                      ),
                      Text(
                        (l10n['birthday_card_by'] ?? 'Birthday card by')
                            .toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'NUMERO SHASTRA',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
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
