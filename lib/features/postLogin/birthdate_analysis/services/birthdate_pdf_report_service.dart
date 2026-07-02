import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:numero_shastra/core/providers/localization_provider.dart';
import 'package:numero_shastra/features/postLogin/birthdate_analysis/model/birthdate_model.dart';
import 'package:numero_shastra/features/postLogin/birthdate_analysis/model/numerology_models.dart';

class BirthdateAnalysisPdfInput {
  final ModelBirthdate birthdate;
  final AppLanguage language;
  final PersonalityData? personalityData;
  final List<LoshuPlane> loshuPlanes;
  final List<NumberOccurrenceDetail> numberOccurrenceDetails;
  final List<MissingNumberTell> missingNumberTells;
  final List<ImportantPoint> importantPoints;
  final List<StockMarketInfo> stockMarketInfo;
  final List<RemedyValues> remedyValues;
  final List<MissingNumberRemedy> missingNumberRemedies;
  final List<int> numbersNotForRemedy;
  final List<PinnacleData> pinnacleData1;
  final List<PinnacleData> pinnacleData2;
  final List<PinnacleData> pinnacleData3;
  final List<PinnacleData> pinnacleData4;
  final List<LifePathData> lifePathData;
  final List<CareerData> careerData;
  final List<BoostingPersonalityData> boostingPersonalityData;
  final List<CombinationData> combinationData;

  const BirthdateAnalysisPdfInput({
    required this.birthdate,
    required this.language,
    required this.personalityData,
    required this.loshuPlanes,
    required this.numberOccurrenceDetails,
    required this.missingNumberTells,
    required this.importantPoints,
    required this.stockMarketInfo,
    required this.remedyValues,
    required this.missingNumberRemedies,
    required this.numbersNotForRemedy,
    required this.pinnacleData1,
    required this.pinnacleData2,
    required this.pinnacleData3,
    required this.pinnacleData4,
    required this.lifePathData,
    required this.careerData,
    required this.boostingPersonalityData,
    required this.combinationData,
  });
}

class BirthdateAnalysisPdfReportService {
  Future<Uint8List> build(BirthdateAnalysisPdfInput input) async {
    final doc = pw.Document();
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );
    final devanagariFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Mangal-Regular.ttf'),
    );
    final devanagariBoldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Mangal-Bold.ttf'),
    );
    final useIndicBaseFont = _usesIndicBaseFont(input.language);
    final bodyFont = useIndicBaseFont ? devanagariFont : regularFont;
    final bodyBoldFont = useIndicBaseFont ? devanagariBoldFont : boldFont;
    final fallbackFonts = useIndicBaseFont
        ? <pw.Font>[regularFont, boldFont]
        : <pw.Font>[devanagariFont, devanagariBoldFont];

    final dateLabel = DateFormat('dd-MMM-yyyy').format(input.birthdate.birthdate);
    final generatedAt = DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.now());
    final titleName = _textOrFallback(
      input.birthdate.fullName,
      'Birthdate Analysis',
    );
    final subtitle = 'Analysis report for $dateLabel';

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          theme: pw.ThemeData.withFont(
            base: bodyFont,
            bold: bodyBoldFont,
          ),
        ),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
            'Numero Shastra',
            style: _style(
              font: bodyFont,
              fallbackFonts: fallbackFonts,
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 12),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: _style(
              font: bodyFont,
              fallbackFonts: fallbackFonts,
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
        ),
        build: (context) => [
          _buildHero(
            bodyFont: bodyFont,
            bodyBoldFont: bodyBoldFont,
            devanagariFont: devanagariFont,
            devanagariBoldFont: devanagariBoldFont,
            fallbackFonts: fallbackFonts,
            title: titleName,
            subtitle: subtitle,
            generatedAt: generatedAt,
            birthdateLabel: dateLabel,
          ),
          _sectionCard(
            title: 'Quick Summary',
            subtitle: 'A concise overview of the selected birthdate analysis.',
            children: [
              _infoLine(
                font: bodyFont,
                fallbackFonts: fallbackFonts,
                label: 'Status',
                value: _textOrFallback(input.birthdate.status, 'pending'),
              ),
              _infoLine(
                font: bodyFont,
                fallbackFonts: fallbackFonts,
                label: 'Personality Number',
                value: input.birthdate.personalityNumber?.toString() ?? 'N/A',
              ),
              _infoLine(
                font: bodyFont,
                fallbackFonts: fallbackFonts,
                label: 'Life Path Number',
                value: input.birthdate.lifePathNumber?.toString() ?? 'N/A',
              ),
              _infoLine(
                font: bodyFont,
                fallbackFonts: fallbackFonts,
                label: 'Pinnacle Base',
                value: input.birthdate.pinnacleBase?.toString() ?? 'N/A',
              ),
            ],
          ),
          if (input.personalityData != null)
            _sectionCard(
              title: 'Personality Analysis',
              subtitle:
                  'How your outer personality is generally perceived by others.',
              children: [
                _infoLine(
                  font: bodyFont,
                  fallbackFonts: fallbackFonts,
                  label: 'Number',
                  value: input.personalityData!.personalityNumber.toString(),
                ),
                _paragraph(
                  font: bodyFont,
                  fallbackFonts: fallbackFonts,
                  label: 'Ruling Planet',
                  value: input.personalityData!.getLord(input.language),
                ),
                _paragraph(
                  font: bodyFont,
                  fallbackFonts: fallbackFonts,
                  label: 'Strengths',
                  value: input.personalityData!.getQualities(input.language),
                ),
                _paragraph(
                  font: bodyFont,
                  fallbackFonts: fallbackFonts,
                  label: 'Watch Outs',
                  value: input.personalityData!.getWeaknesses(input.language),
                ),
                _paragraph(
                  font: bodyFont,
                  fallbackFonts: fallbackFonts,
                  label: 'Best Approach',
                  value: input.personalityData!.getYouShould(input.language),
                ),
                _paragraph(
                  font: bodyFont,
                  fallbackFonts: fallbackFonts,
                  label: 'Description',
                  value: input.personalityData!.getDescription(input.language),
                  isNarrative: true,
                ),
              ],
            ),
          if (input.loshuPlanes.isNotEmpty)
            _sectionCard(
              title: 'Lo Shu Planes',
              subtitle:
                  'Core behavior patterns identified from the Lo Shu grid positions.',
              children: input.loshuPlanes
                  .map(
                    (plane) => _subSection(
                      font: bodyFont,
                      fallbackFonts: fallbackFonts,
                      title: _cleanText(
                        '${plane.gridPosition} - ${plane.getTitle(input.language)}',
                      ),
                      description: _cleanText(
                        plane.getDescription(input.language),
                      ),
                    ),
                  )
                  .toList(),
            ),
          if (input.numberOccurrenceDetails.isNotEmpty)
            _sectionCard(
              title: 'Number Occurrences',
              subtitle:
                  'How often each number appears and what that means in your chart.',
              children: input.numberOccurrenceDetails
                  .map(
                    (item) => _subSection(
                      font: bodyFont,
                      fallbackFonts: fallbackFonts,
                      title: 'Number ${item.number} x ${item.occurrence}',
                      description: _cleanText(item.getDescription(input.language)),
                    ),
                  )
                  .toList(),
            ),
          if (input.missingNumberTells.isNotEmpty)
            _sectionCard(
              title: 'Missing Numbers',
              subtitle:
                  'Areas that may need more awareness or conscious balance.',
              children: input.missingNumberTells
                  .map(
                    (item) => _subSection(
                      font: bodyFont,
                      fallbackFonts: fallbackFonts,
                      title: 'Missing Number ${item.missingNumber}',
                      description: _cleanText(item.getDescription(input.language)),
                    ),
                  )
                  .toList(),
            ),
          if (input.importantPoints.isNotEmpty)
            _sectionCard(
              title: 'Important Points',
              subtitle:
                  'Key reminders and practical observations for this birthdate.',
              children: input.importantPoints
                  .map(
                    (item) => _subSection(
                      font: bodyFont,
                      fallbackFonts: fallbackFonts,
                      title: 'Numbers: ${item.includedNumbers.join(', ')}',
                      description: _cleanText(item.getDescription(input.language)),
                    ),
                  )
                  .toList(),
            ),
          if (input.stockMarketInfo.isNotEmpty)
            _sectionCard(
              title: 'Stock Market Advice',
              subtitle:
                  'Numbers linked with financial timing and market-facing tendencies.',
              children: input.stockMarketInfo
                  .map(
                    (item) => _subSection(
                      font: bodyFont,
                      fallbackFonts: fallbackFonts,
                      title: 'Numbers: ${item.includedNumbers.join(', ')}',
                      description: _cleanText(item.getDescription(input.language)),
                    ),
                  )
                  .toList(),
            ),
          if (input.remedyValues.isNotEmpty)
            _sectionCard(
              title: 'Remedy Values',
              subtitle:
                  'Suggested lucky and unlucky influences, colors, and days to note.',
              children: input.remedyValues
                  .map(
                    (item) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _subSection(
                          font: bodyFont,
                          fallbackFonts: fallbackFonts,
                          title:
                              'Unlucky Numbers: ${item.unluckyNumbers.join(', ')}',
                          description: _cleanText(
                            'Unlucky Colors: ${item.getUnluckyColors(input.language).join(', ')}\n'
                            'Lucky Numbers: ${item.luckyNumbers.join(', ')}\n'
                            'Lucky Colors: ${item.getLuckyColors(input.language).join(', ')}\n'
                            'Lucky Days: ${item.getLuckyDays(input.language).join(', ')}\n'
                            'Numbers for Remedy: ${item.numbersForRemedy.join(', ')}\n'
                            'Numbers not for Remedy: ${item.numbersNotForRemedy.join(', ')}',
                          ),
                        ),
                        pw.SizedBox(height: 8),
                      ],
                    ),
                  )
                  .toList(),
            ),
          if (input.missingNumberRemedies.isNotEmpty)
            _sectionCard(
              title: 'Missing Number Remedies',
              subtitle:
                  'Practical remedies and suggestions for the missing numbers.',
              children: input.missingNumberRemedies
                  .map(
                    (item) => _subSection(
                      font: bodyFont,
                      fallbackFonts: fallbackFonts,
                      title: 'Missing Number ${item.missingNumber}',
                      description: _cleanText(item.getDescription(input.language)),
                    ),
                  )
                  .toList(),
            ),
          if (input.numbersNotForRemedy.isNotEmpty)
            _sectionCard(
              title: 'Numbers Not For Remedy',
              subtitle: 'Numbers that are better left untouched in remedies.',
              children: [
                _paragraph(
                  font: bodyFont,
                  fallbackFonts: fallbackFonts,
                  label: 'Numbers',
                  value: input.numbersNotForRemedy.join(', '),
                ),
              ],
            ),
          if (input.pinnacleData1.isNotEmpty)
            _sectionCard(
              title: 'Pinnacle 1',
              subtitle: 'First major life period and its lessons.',
              children: input.pinnacleData1
                  .map(
                    (item) => _subSection(
                      font: bodyFont,
                      fallbackFonts: fallbackFonts,
                      title: _cleanText(item.lifePeriodRange),
                      description: _cleanText(item.getDescription(input.language)),
                    ),
                  )
                  .toList(),
            ),
          if (input.pinnacleData2.isNotEmpty)
            _sectionCard(
              title: 'Pinnacle 2',
              subtitle: 'Second major life period and its lessons.',
              children: input.pinnacleData2
                  .map(
                    (item) => _subSection(
                      font: bodyFont,
                      fallbackFonts: fallbackFonts,
                      title: _cleanText(item.lifePeriodRange),
                      description: _cleanText(item.getDescription(input.language)),
                    ),
                  )
                  .toList(),
            ),
          if (input.pinnacleData3.isNotEmpty)
            _sectionCard(
              title: 'Pinnacle 3',
              subtitle: 'Third major life period and its lessons.',
              children: input.pinnacleData3
                  .map(
                    (item) => _subSection(
                      font: bodyFont,
                      fallbackFonts: fallbackFonts,
                      title: _cleanText(item.lifePeriodRange),
                      description: _cleanText(item.getDescription(input.language)),
                    ),
                  )
                  .toList(),
            ),
          if (input.pinnacleData4.isNotEmpty)
            _sectionCard(
              title: 'Pinnacle 4',
              subtitle: 'Fourth major life period and its lessons.',
              children: input.pinnacleData4
                  .map(
                    (item) => _subSection(
                      font: bodyFont,
                      fallbackFonts: fallbackFonts,
                      title: _cleanText(item.lifePeriodRange),
                      description: _cleanText(item.getDescription(input.language)),
                    ),
                  )
                  .toList(),
            ),
          if (input.lifePathData.isNotEmpty)
            _sectionCard(
              title: 'Life Path',
              subtitle: 'Your deeper life direction and main journey theme.',
              children: input.lifePathData
                  .map(
                    (item) => _subSection(
                      font: bodyFont,
                      fallbackFonts: fallbackFonts,
                      title: 'Life Path Number ${item.lifePathNumber}',
                      description: _cleanText(item.getDescription(input.language)),
                    ),
                  )
                  .toList(),
            ),
          if (input.careerData.isNotEmpty)
            _sectionCard(
              title: 'Career Guidance',
              subtitle:
                  'Career styles and work patterns that align with your chart.',
              children: input.careerData
                  .map(
                    (item) => _subSection(
                      font: bodyFont,
                      fallbackFonts: fallbackFonts,
                      title: 'Life Path Number ${item.lifePathNumber}',
                      description: _cleanText(item.getDescription(input.language)),
                    ),
                  )
                  .toList(),
            ),
          if (input.boostingPersonalityData.isNotEmpty)
            _sectionCard(
              title: 'Boosting Personality',
              subtitle:
                  'Ways to strengthen the positive expression of your personality number.',
              children: input.boostingPersonalityData
                  .map(
                    (item) => _subSection(
                      font: bodyFont,
                      fallbackFonts: fallbackFonts,
                      title: 'Personality Number ${item.personalityNumber}',
                      description: _cleanText(item.getDescription(input.language)),
                    ),
                  )
                  .toList(),
            ),
          if (input.combinationData.isNotEmpty)
            _sectionCard(
              title: 'Personality and Life Path Combination',
              subtitle:
                  'How your personality and life path numbers interact together.',
              children: input.combinationData
                  .map(
                    (item) => _subSection(
                      font: bodyFont,
                      fallbackFonts: fallbackFonts,
                      title: 'P${item.personalityNumber} + L${item.lifePathNumber}',
                      description: _cleanText(
                        '${item.getDescription(input.language)}\n\nExample: ${item.getExample(input.language)}',
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _buildHero({
    required pw.Font bodyFont,
    required pw.Font bodyBoldFont,
    required pw.Font devanagariFont,
    required pw.Font devanagariBoldFont,
    required List<pw.Font> fallbackFonts,
    required String title,
    required String subtitle,
    required String generatedAt,
    required String birthdateLabel,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(18),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Birthdate Analysis Report',
            style: _style(
              font: bodyBoldFont,
              fallbackFonts: fallbackFonts,
              fontSize: 24,
              color: PdfColors.blue900,
              bold: true,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            title,
            style: _style(
              font: bodyBoldFont,
              fallbackFonts: fallbackFonts,
              fontSize: 18,
              color: PdfColors.black,
              bold: true,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            subtitle,
            style: _style(
              font: bodyFont,
              fallbackFonts: fallbackFonts,
              fontSize: 11,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Birthdate: $birthdateLabel',
            style: _style(
              font: bodyFont,
              fallbackFonts: fallbackFonts,
              fontSize: 11,
              color: PdfColors.grey800,
            ),
          ),
          pw.Text(
            'Generated: $generatedAt',
            style: _style(
              font: bodyFont,
              fallbackFonts: fallbackFonts,
              fontSize: 11,
              color: PdfColors.grey800,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _sectionCard({
    required String title,
    required String subtitle,
    required List<pw.Widget> children,
  }) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(top: 14),
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(14),
        color: PdfColors.white,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 44,
            height: 4,
            decoration: pw.BoxDecoration(
              color: PdfColors.blue700,
              borderRadius: pw.BorderRadius.circular(4),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            subtitle,
            style: pw.TextStyle(fontSize: 10.3, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _subSection({
    required pw.Font font,
    required List<pw.Font> fallbackFonts,
    required String title,
    required String description,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.grey200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: _style(
              font: font,
              fallbackFonts: fallbackFonts,
              fontSize: 12.2,
              color: PdfColors.blue900,
              bold: true,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            description,
            style: _style(
              font: font,
              fallbackFonts: fallbackFonts,
              fontSize: 10.5,
              color: PdfColors.grey800,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _paragraph({
    required pw.Font font,
    required List<pw.Font> fallbackFonts,
    required String label,
    required String value,
    bool isNarrative = false,
  }) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: isNarrative ? PdfColors.blue50 : PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: isNarrative ? PdfColors.blue100 : PdfColors.grey200,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: pw.BoxDecoration(
              color: isNarrative ? PdfColors.blue100 : PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(999),
            ),
            child: pw.Text(
              label,
              style: _style(
                font: font,
                fallbackFonts: fallbackFonts,
                fontSize: 9.2,
                color: PdfColors.grey900,
                bold: true,
              ),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            value.isEmpty ? 'N/A' : value,
            textAlign: pw.TextAlign.justify,
            style: _style(
              font: font,
              fallbackFonts: fallbackFonts,
              fontSize: isNarrative ? 11.2 : 10.3,
              color: PdfColors.grey900,
              height: isNarrative ? 1.5 : 1.35,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _infoLine({
    required pw.Font font,
    required List<pw.Font> fallbackFonts,
    required String label,
    required String value,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        '$label: ${value.isEmpty ? 'N/A' : value}',
        style: _style(
          font: font,
          fallbackFonts: fallbackFonts,
          fontSize: 10.5,
          color: PdfColors.grey800,
        ),
      ),
    );
  }

  pw.TextStyle _style({
    required pw.Font font,
    required List<pw.Font> fallbackFonts,
    required double fontSize,
    PdfColor color = PdfColors.black,
    bool bold = false,
    double? height,
  }) {
    return pw.TextStyle(
      font: font,
      fontSize: fontSize,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: color,
      height: height,
      fontFallback: fallbackFonts,
    );
  }

  String _textOrFallback(String? value, String fallback) {
    final clean = value?.trim();
    if (clean == null || clean.isEmpty) return fallback;
    return clean;
  }

  String _cleanText(String value) {
    return value
        .replaceAll('\u2013', '-')
        .replaceAll('\u2014', '-')
        .replaceAll('\u2011', '-')
        .replaceAll('\u2022', '-');
  }

  bool _usesIndicBaseFont(AppLanguage language) {
    return language == AppLanguage.hindi || language == AppLanguage.marathi;
  }
}



