import 'dart:typed_data';

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
    final dateLabel = DateFormat('dd-MMM-yyyy').format(input.birthdate.birthdate);
    final generatedAt = DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.now());
    final titleName = _textOrFallback(input.birthdate.fullName, 'Birthdate Analysis');
    final subtitle = 'Analysis report for $dateLabel';

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          theme: pw.ThemeData.withFont(base: pw.Font.helvetica()),
        ),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
            'Numero Shastra',
            style: pw.TextStyle(
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
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
        build: (context) => [
          _buildHero(titleName, subtitle, generatedAt, dateLabel),
          _sectionCard(
            'Quick Summary',
            [
              _infoLine('Status', _textOrFallback(input.birthdate.status, 'pending')),
              _infoLine('Personality Number', input.birthdate.personalityNumber?.toString() ?? 'N/A'),
              _infoLine('Life Path Number', input.birthdate.lifePathNumber?.toString() ?? 'N/A'),
              _infoLine('Pinnacle Base', input.birthdate.pinnacleBase?.toString() ?? 'N/A'),
            ],
          ),
          if (input.personalityData != null)
            _sectionCard(
              'Personality Analysis',
              [
                _infoLine('Number', input.personalityData!.personalityNumber.toString()),
                _paragraph('Lord', input.personalityData!.getLord(input.language)),
                _paragraph('Qualities', input.personalityData!.getQualities(input.language)),
                _paragraph('Weaknesses', input.personalityData!.getWeaknesses(input.language)),
                _paragraph('You Should', input.personalityData!.getYouShould(input.language)),
                _paragraph('Description', input.personalityData!.getDescription(input.language)),
              ],
            ),
          if (input.loshuPlanes.isNotEmpty)
            _sectionCard(
              'Lo Shu Planes',
              input.loshuPlanes
                  .map(
                    (plane) => _subSection(
                      '${plane.gridPosition} - ${plane.getTitle(input.language)}',
                      plane.getDescription(input.language),
                    ),
                  )
                  .toList(),
            ),
          if (input.numberOccurrenceDetails.isNotEmpty)
            _sectionCard(
              'Number Occurrences',
              input.numberOccurrenceDetails
                  .map(
                    (item) => _subSection(
                      'Number ${item.number} x ${item.occurrence}',
                      item.getDescription(input.language),
                    ),
                  )
                  .toList(),
            ),
          if (input.missingNumberTells.isNotEmpty)
            _sectionCard(
              'Missing Numbers',
              input.missingNumberTells
                  .map(
                    (item) => _subSection(
                      'Missing Number ${item.missingNumber}',
                      item.getDescription(input.language),
                    ),
                  )
                  .toList(),
            ),
          if (input.importantPoints.isNotEmpty)
            _sectionCard(
              'Important Points',
              input.importantPoints
                  .map(
                    (item) => _subSection(
                      'Numbers: ${item.includedNumbers.join(', ')}',
                      item.getDescription(input.language),
                    ),
                  )
                  .toList(),
            ),
          if (input.stockMarketInfo.isNotEmpty)
            _sectionCard(
              'Stock Market Advice',
              input.stockMarketInfo
                  .map(
                    (item) => _subSection(
                      'Numbers: ${item.includedNumbers.join(', ')}',
                      item.getDescription(input.language),
                    ),
                  )
                  .toList(),
            ),
          if (input.remedyValues.isNotEmpty)
            _sectionCard(
              'Remedy Values',
              input.remedyValues
                  .map(
                    (item) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _subSection(
                          'Unlucky Numbers: ${item.unluckyNumbers.join(', ')}',
                          'Unlucky Colors: ${item.getUnluckyColors(input.language).join(', ')}\n'
                          'Lucky Numbers: ${item.luckyNumbers.join(', ')}\n'
                          'Lucky Colors: ${item.getLuckyColors(input.language).join(', ')}\n'
                          'Lucky Days: ${item.getLuckyDays(input.language).join(', ')}\n'
                          'Numbers for Remedy: ${item.numbersForRemedy.join(', ')}\n'
                          'Numbers not for Remedy: ${item.numbersNotForRemedy.join(', ')}',
                        ),
                        pw.SizedBox(height: 8),
                      ],
                    ),
                  )
                  .toList(),
            ),
          if (input.missingNumberRemedies.isNotEmpty)
            _sectionCard(
              'Missing Number Remedies',
              input.missingNumberRemedies
                  .map(
                    (item) => _subSection(
                      'Missing Number ${item.missingNumber}',
                      item.getDescription(input.language),
                    ),
                  )
                  .toList(),
            ),
          if (input.numbersNotForRemedy.isNotEmpty)
            _sectionCard(
              'Numbers Not For Remedy',
              [_paragraph('Numbers', input.numbersNotForRemedy.join(', '))],
            ),
          if (input.pinnacleData1.isNotEmpty)
            _sectionCard(
              'Pinnacle 1',
              input.pinnacleData1
                  .map((item) => _subSection(item.lifePeriodRange, item.getDescription(input.language)))
                  .toList(),
            ),
          if (input.pinnacleData2.isNotEmpty)
            _sectionCard(
              'Pinnacle 2',
              input.pinnacleData2
                  .map((item) => _subSection(item.lifePeriodRange, item.getDescription(input.language)))
                  .toList(),
            ),
          if (input.pinnacleData3.isNotEmpty)
            _sectionCard(
              'Pinnacle 3',
              input.pinnacleData3
                  .map((item) => _subSection(item.lifePeriodRange, item.getDescription(input.language)))
                  .toList(),
            ),
          if (input.pinnacleData4.isNotEmpty)
            _sectionCard(
              'Pinnacle 4',
              input.pinnacleData4
                  .map((item) => _subSection(item.lifePeriodRange, item.getDescription(input.language)))
                  .toList(),
            ),
          if (input.lifePathData.isNotEmpty)
            _sectionCard(
              'Life Path',
              input.lifePathData
                  .map(
                    (item) => _subSection(
                      'Life Path Number ${item.lifePathNumber}',
                      item.getDescription(input.language),
                    ),
                  )
                  .toList(),
            ),
          if (input.careerData.isNotEmpty)
            _sectionCard(
              'Career Guidance',
              input.careerData
                  .map(
                    (item) => _subSection(
                      'Life Path Number ${item.lifePathNumber}',
                      item.getDescription(input.language),
                    ),
                  )
                  .toList(),
            ),
          if (input.boostingPersonalityData.isNotEmpty)
            _sectionCard(
              'Boosting Personality',
              input.boostingPersonalityData
                  .map(
                    (item) => _subSection(
                      'Personality Number ${item.personalityNumber}',
                      item.getDescription(input.language),
                    ),
                  )
                  .toList(),
            ),
          if (input.combinationData.isNotEmpty)
            _sectionCard(
              'Personality and Life Path Combination',
              input.combinationData
                  .map(
                    (item) => _subSection(
                      'P${item.personalityNumber} + L${item.lifePathNumber}',
                      '${item.getDescription(input.language)}\n\nExample: ${item.getExample(input.language)}',
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _buildHero(
    String title,
    String subtitle,
    String generatedAt,
    String birthdateLabel,
  ) {
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
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            subtitle,
            style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Birthdate: $birthdateLabel',
            style: pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
          ),
          pw.Text(
            'Generated: $generatedAt',
            style: pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
          ),
        ],
      ),
    );
  }

  pw.Widget _sectionCard(String title, List<pw.Widget> children) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(top: 14),
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(14),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _subSection(String title, String description) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            description,
            style: const pw.TextStyle(
              fontSize: 10.5,
              height: 1.4,
              color: PdfColors.grey800,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _paragraph(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.RichText(
        text: pw.TextSpan(
          style: const pw.TextStyle(fontSize: 10.5, color: PdfColors.grey800),
          children: [
            pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.TextSpan(text: value.isEmpty ? 'N/A' : value),
          ],
        ),
      ),
    );
  }

  pw.Widget _infoLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        '$label: ${value.isEmpty ? 'N/A' : value}',
        style: const pw.TextStyle(fontSize: 10.5, color: PdfColors.grey800),
      ),
    );
  }

  String _textOrFallback(String? value, String fallback) {
    final clean = value?.trim();
    if (clean == null || clean.isEmpty) return fallback;
    return clean;
  }
}
