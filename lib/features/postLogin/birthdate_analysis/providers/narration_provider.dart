import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../../core/providers/localization_provider.dart';
import '../model/numerology_models.dart';
import '../model/numerology_ui_content.dart';
import 'numerology_content_providers.dart';
import 'numerology_providers.dart';
import '../../cart/providers/birthdate_record_providers.dart';
import '../../../../core/providers/birthdate_localization_provider.dart';

enum NarrationSection {
  intro,
  age,
  coreDetails,
  personality,
  loshuGrid,
  loshuPlanes,
  remedyValues,
  missingTells,
  missingRemedies,
  numberOccurrence,
  importantPoints,
  stockMarket,
  pinnacles,
  lifePath,
  career,
  boosting,
  combination,
}

class NarrationChunk {
  final String text;
  final NarrationSection section;
  final int? subIndex;

  NarrationChunk({
    required this.text,
    required this.section,
    this.subIndex,
  });
}

class NarrationState {
  final bool isPlaying;
  final bool isPaused;
  final bool isStopped;
  final int currentChunk;
  final int totalChunks;
  final String currentText;
  final NarrationSection currentSection;
  final int? currentSubIndex;

  const NarrationState({
    this.isPlaying = false,
    this.isPaused = false,
    this.isStopped = true,
    this.currentChunk = 0,
    this.totalChunks = 0,
    this.currentText = '',
    this.currentSection = NarrationSection.intro,
    this.currentSubIndex,
  });

  NarrationState copyWith({
    bool? isPlaying,
    bool? isPaused,
    bool? isStopped,
    int? currentChunk,
    int? totalChunks,
    String? currentText,
    NarrationSection? currentSection,
    int? currentSubIndex,
  }) {
    return NarrationState(
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      isStopped: isStopped ?? this.isStopped,
      currentChunk: currentChunk ?? this.currentChunk,
      totalChunks: totalChunks ?? this.totalChunks,
      currentText: currentText ?? this.currentText,
      currentSection: currentSection ?? this.currentSection,
      currentSubIndex: currentSubIndex ?? this.currentSubIndex,
    );
  }
}

class NarrationNotifier extends AutoDisposeNotifier<NarrationState> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isNarrationStopped = false;

  @override
  NarrationState build() {
    _configureTts();
    ref.onDispose(() {
      _flutterTts.stop();
    });
    return const NarrationState();
  }

  Future<void> _configureTts() async {
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setErrorHandler((message) {
      state = state.copyWith(isPlaying: false, isPaused: false, isStopped: true);
    });
  }

  Future<void> _setNarrationLanguage(AppLanguage lang) async {
    switch (lang) {
      case AppLanguage.hindi:
        await _flutterTts.setLanguage('hi-IN');
        break;
      case AppLanguage.marathi:
        await _flutterTts.setLanguage('mr-IN');
        break;
      case AppLanguage.english:
        await _flutterTts.setLanguage('en-IN');
        break;
    }
  }

  String _joinList<T>(Iterable<T> values) {
    return values.map((value) => value.toString()).join(', ');
  }

  List<NarrationChunk> _getNarrationChunks(AppLanguage lang, Map<String, String> l10n) {
    final ageText = ref.read(ageProvider);
    final numerology = ref.read(numerologyProvider);
    final personality = ref.read(personalityDataProvider).valueOrNull;
    final planes = ref.read(loshuPlanesProvider).valueOrNull ?? const <LoshuPlane>[];
    final remedies = ref.read(remedyValuesProvider).valueOrNull ?? const <RemedyValues>[];
    final missingTells = ref.read(missingNumberTellsProvider).valueOrNull ?? const <MissingNumberTell>[];
    final missingRemedies = ref.read(missingNumberRemediesProvider).valueOrNull ?? const <MissingNumberRemedy>[];
    final numberDetails = ref.read(numberOccurrenceDetailsProvider).valueOrNull ?? const <NumberOccurrenceDetail>[];
    final importantPoints = ref.read(importantPointsProvider).valueOrNull ?? const <ImportantPoint>[];
    final stockInfo = ref.read(stockMarketInfoProvider).valueOrNull ?? const <StockMarketInfo>[];
    final lifePathItems = ref.read(lifePathNumberDataProvider).valueOrNull ?? const <LifePathData>[];
    final careerItems = ref.read(careerDataProvider).valueOrNull ?? const <CareerData>[];
    final boostingItems = ref.read(boostingPersonalityDataProvider).valueOrNull ?? const <BoostingPersonalityData>[];
    final combinations = ref.read(combinationDataProvider).valueOrNull ?? const <CombinationData>[];
    final pinnacle1 = ref.read(pinnacleData1Provider).valueOrNull ?? const <PinnacleData>[];
    final pinnacle2 = ref.read(pinnacleData2Provider).valueOrNull ?? const <PinnacleData>[];
    final pinnacle3 = ref.read(pinnacleData3Provider).valueOrNull ?? const <PinnacleData>[];
    final pinnacle4 = ref.read(pinnacleData4Provider).valueOrNull ?? const <PinnacleData>[];

    final chunks = <NarrationChunk>[];

    void addSectionHeader(String titleKey, String subtitleKey, NarrationSection section) {
      final title = NumerologyUIContent.getHeaderTitle(titleKey, lang);
      final subtitle = NumerologyUIContent.getHeaderTitle(subtitleKey, lang);
      chunks.add(NarrationChunk(text: title, section: section));
      if (subtitle.isNotEmpty && subtitle != title) {
        chunks.add(NarrationChunk(text: subtitle, section: section));
      }
    }

    // 1. Age
    if (ageText != null && ageText.isNotEmpty) {
      chunks.add(NarrationChunk(text: '${l10n['narrator_age'] ?? 'Based on age: '} $ageText.', section: NarrationSection.age));
    }

    // 2. Numerology Core Details
    if (numerology.personality != null || numerology.lifePath != null) {
      addSectionHeader('numerical_analysis', '', NarrationSection.coreDetails);
      chunks.add(NarrationChunk(text: l10n['narrator_core'] ?? 'Core numbers.', section: NarrationSection.coreDetails));
      chunks.add(NarrationChunk(
        text: switch (lang) {
          AppLanguage.hindi => 'आपका पर्सनैलिटी नंबर ${numerology.personality ?? '-'} और लाइफ पाथ नंबर ${numerology.lifePath ?? '-'} है।',
          AppLanguage.marathi => 'तुमचा पर्सनॅलिटी नंबर ${numerology.personality ?? '-'} आणि लाईफ पाथ नंबर ${numerology.lifePath ?? '-'} आहे.',
          AppLanguage.english => 'Your personality number is ${numerology.personality ?? '-'} and your life path number is ${numerology.lifePath ?? '-'}.',
        },
        section: NarrationSection.coreDetails,
      ));
    }

    // 3. Personality Analysis
    if (personality != null) {
      addSectionHeader('personality_analysis', 'personality_subtitle', NarrationSection.personality);
      chunks.add(NarrationChunk(text: l10n['narrator_personality'] ?? 'Personality analysis.', section: NarrationSection.personality));
      
      final personalityHeader = NumerologyUIContent.getLabel('personality_analysis_label', lang)
          .replaceAll('{number}', personality.personalityNumber.toString());
      chunks.add(NarrationChunk(text: personalityHeader, section: NarrationSection.personality));

      if (personality.getLord(lang).isNotEmpty) {
        chunks.add(NarrationChunk(
          text: '${NumerologyUIContent.getLabel('lord', lang)}: ${personality.getLord(lang)}.',
          section: NarrationSection.personality,
        ));
      }
      if (personality.getQualities(lang).isNotEmpty) {
        chunks.add(NarrationChunk(text: '${NumerologyUIContent.getLabel('qualities', lang)}. ${personality.getQualities(lang)}', section: NarrationSection.personality));
      }
      if (personality.getWeaknesses(lang).isNotEmpty) {
        chunks.add(NarrationChunk(text: '${NumerologyUIContent.getLabel('weaknesses', lang)}. ${personality.getWeaknesses(lang)}', section: NarrationSection.personality));
      }
      if (personality.getYouShould(lang).isNotEmpty) {
        chunks.add(NarrationChunk(text: '${NumerologyUIContent.getLabel('recommendation', lang)}. ${personality.getYouShould(lang)}', section: NarrationSection.personality));
      }
      if (personality.getDescription(lang).isNotEmpty) {
        chunks.add(NarrationChunk(text: '${NumerologyUIContent.getLabel('detailed_insight', lang)}. ${personality.getDescription(lang)}', section: NarrationSection.personality));
      }
    }

    // 4. Lo Shu Grid
    addSectionHeader('lo_shu_grid', 'lo_shu_grid_subtitle', NarrationSection.loshuGrid);
    chunks.add(NarrationChunk(text: l10n['narrator_loshu'] ?? 'Lo Shu Grid.', section: NarrationSection.loshuGrid));
    if (numerology.absentNumbers != null && numerology.absentNumbers!.isNotEmpty) {
      chunks.add(NarrationChunk(text: '${NumerologyUIContent.getLabel('missing_numbers_grid', lang)}: ${_joinList(numerology.absentNumbers!)}.', section: NarrationSection.loshuGrid));
    }
    if (numerology.numberOccurrences != null) {
      final entries = numerology.numberOccurrences!.entries
          .where((e) => e.value > 0)
          .toList();
      
      if (entries.isNotEmpty) {
        final List<String> verbalOccurrences = [];
        for (final entry in entries) {
          final number = entry.key;
          final count = entry.value;
          final timeLabel = count == 1 
              ? NumerologyUIContent.getLabel('time_singular', lang)
              : NumerologyUIContent.getLabel('time_plural', lang);
          
          final verbal = switch (lang) {
            AppLanguage.hindi => 'नंबर $number $count $timeLabel आया है',
            AppLanguage.marathi => 'नंबर $number $count $timeLabel आला आहे',
            AppLanguage.english => 'Number $number comes $count $timeLabel',
          };
          verbalOccurrences.add(verbal);
        }

        final combinedVerbal = verbalOccurrences.join(', ');
        final occurrenceText = switch (lang) {
          AppLanguage.hindi => 'आपके ग्रिड में नंबरों की आवृत्ति: $combinedVerbal.',
          AppLanguage.marathi => 'तुमच्या ग्रिडमधील अंकांची पुनरावृत्ती: $combinedVerbal.',
          AppLanguage.english => 'Number occurrences in your grid: $combinedVerbal.',
        };
        chunks.add(NarrationChunk(text: occurrenceText, section: NarrationSection.loshuGrid));
      }
    }

    // 5. Loshu Planes
    if (planes.isNotEmpty) {
      addSectionHeader('lo_shu_planes', 'lo_shu_planes_subtitle', NarrationSection.loshuPlanes);
      chunks.add(NarrationChunk(text: l10n['narrator_planes'] ?? 'Grid planes.', section: NarrationSection.loshuPlanes));
      for (int i = 0; i < planes.length; i++) {
        final p = planes[i];
        chunks.add(NarrationChunk(text: p.getTitle(lang), section: NarrationSection.loshuPlanes, subIndex: i));
        chunks.add(NarrationChunk(text: p.getDescription(lang), section: NarrationSection.loshuPlanes, subIndex: i));
      }
    }

    // 6. Remedy Values
    if (remedies.isNotEmpty) {
      addSectionHeader('lucky_unlucky', '', NarrationSection.remedyValues);
      chunks.add(NarrationChunk(text: l10n['narrator_remedies'] ?? 'Enhancements.', section: NarrationSection.remedyValues));
      final r = remedies.first;

      // 1. Lucky Numbers
      if (r.luckyNumbers.isNotEmpty) {
        final header = NumerologyUIContent.getLabel('lucky_number', lang);
        final numbers = _joinList(r.luckyNumbers);
        final text = switch (lang) {
          AppLanguage.hindi => 'आपके शुभ अंक $numbers हैं।',
          AppLanguage.marathi => 'तुमचे शुभ अंक $numbers आहेत.',
          AppLanguage.english => 'Your lucky numbers are $numbers.',
        };
        chunks.add(NarrationChunk(text: '$header. $text', section: NarrationSection.remedyValues));
      }

      // 2. Unlucky Numbers
      if (r.unluckyNumbers.isNotEmpty) {
        final header = NumerologyUIContent.getLabel('unlucky_number', lang);
        final numbers = _joinList(r.unluckyNumbers);
        final text = switch (lang) {
          AppLanguage.hindi => 'आपके अशुभ अंक $numbers हैं।',
          AppLanguage.marathi => 'तुमचे अशुभ अंक $numbers आहेत.',
          AppLanguage.english => 'Your unlucky numbers are $numbers.',
        };
        chunks.add(NarrationChunk(text: '$header. $text', section: NarrationSection.remedyValues));
      }

      // 3. Lucky Colors
      final luckyColors = r.getLuckyColors(lang);
      if (luckyColors.isNotEmpty) {
        final header = NumerologyUIContent.getLabel('lucky_color', lang);
        final colors = _joinList(luckyColors);
        final text = switch (lang) {
          AppLanguage.hindi => 'आपके शुभ रंग $colors हैं।',
          AppLanguage.marathi => 'तुमचे शुभ रंग $colors आहेत.',
          AppLanguage.english => 'Your lucky colors are $colors.',
        };
        chunks.add(NarrationChunk(text: '$header. $text', section: NarrationSection.remedyValues));
      }

      // 4. Unlucky Colors
      final unluckyColors = r.getUnluckyColors(lang);
      if (unluckyColors.isNotEmpty) {
        final header = NumerologyUIContent.getLabel('unlucky_color', lang);
        final colors = _joinList(unluckyColors);
        final text = switch (lang) {
          AppLanguage.hindi => 'आपके अशुभ रंग $colors हैं इनसे बचें।',
          AppLanguage.marathi => 'तुमचे अशुभ रंग $colors आहेत, त्यांपासून दूर राहा.',
          AppLanguage.english => 'Your unlucky colors are $colors, please avoid them.',
        };
        chunks.add(NarrationChunk(text: '$header. $text', section: NarrationSection.remedyValues));
      }

      // 5. Lucky Days
      final luckyDays = r.getLuckyDays(lang);
      if (luckyDays.isNotEmpty) {
        final header = NumerologyUIContent.getLabel('lucky_day', lang);
        final days = _joinList(luckyDays);
        final text = switch (lang) {
          AppLanguage.hindi => 'आपके शुभ दिन $days हैं।',
          AppLanguage.marathi => 'तुमचे शुभ दिवस $days आहेत.',
          AppLanguage.english => 'Your lucky days are $days.',
        };
        chunks.add(NarrationChunk(text: '$header. $text', section: NarrationSection.remedyValues));
      }

      // 6. Numbers for Remedy
      if (r.numbersForRemedy.isNotEmpty) {
        final header = NumerologyUIContent.getLabel('numbers_for_remedy', lang);
        final numbers = _joinList(r.numbersForRemedy);
        final text = switch (lang) {
          AppLanguage.hindi => 'उपाय के लिए नंबर $numbers का उपयोग करें।',
          AppLanguage.marathi => 'उपायांसाठी $numbers हे अंक वापरावेत.',
          AppLanguage.english => 'Use numbers $numbers for specific remedies.',
        };
        chunks.add(NarrationChunk(text: '$header. $text', section: NarrationSection.remedyValues));
      }

      // 7. Numbers not for Remedy
      if (r.numbersNotForRemedy.isNotEmpty) {
        final header = NumerologyUIContent.getLabel('numbers_not_for_remedy', lang);
        final numbers = _joinList(r.numbersNotForRemedy);
        final instruction = NumerologyUIContent.getLabel('no_remedy_instruction', lang)
            .replaceAll('{numbers}', numbers);
        chunks.add(NarrationChunk(text: '$header. $instruction', section: NarrationSection.remedyValues));
      }
    }

    // 7. Missing Number Tells
    if (missingTells.isNotEmpty) {
      addSectionHeader('missing_number_tells', 'missing_number_tells_subtitle', NarrationSection.missingTells);
      chunks.add(NarrationChunk(text: l10n['narrator_missing_tells'] ?? 'Challenges.', section: NarrationSection.missingTells));
      for (int i = 0; i < missingTells.length; i++) {
        final t = missingTells[i];
        final header = NumerologyUIContent.getLabel('missing_number_label', lang)
            .replaceAll('{number}', t.missingNumber.toString());
        chunks.add(NarrationChunk(text: header, section: NarrationSection.missingTells, subIndex: i));
        chunks.add(NarrationChunk(text: t.getDescription(lang), section: NarrationSection.missingTells, subIndex: i));
      }
    }

    // 8. Missing Number Remedies
    if (missingRemedies.isNotEmpty) {
      addSectionHeader('missing_number_remedies', '', NarrationSection.missingRemedies);
      chunks.add(NarrationChunk(text: l10n['narrator_missing_remedies'] ?? 'Remedies.', section: NarrationSection.missingRemedies));
      chunks.add(NarrationChunk(text: NumerologyUIContent.getLabel('remedy_instruction', lang), section: NarrationSection.missingRemedies));
      for (int i = 0; i < missingRemedies.length; i++) {
        final r = missingRemedies[i];
        final header = NumerologyUIContent.getLabel('remedy_for_number', lang)
            .replaceAll('{number}', r.missingNumber.toString());
        chunks.add(NarrationChunk(text: header, section: NarrationSection.missingRemedies, subIndex: i));
        chunks.add(NarrationChunk(text: r.getDescription(lang), section: NarrationSection.missingRemedies, subIndex: i));
      }
    }

    // 9. Number Occurrence
    if (numberDetails.isNotEmpty) {
      addSectionHeader('occurrence_details', 'occurrence_details_subtitle', NarrationSection.numberOccurrence);
      chunks.add(NarrationChunk(text: l10n['narrator_occurrence'] ?? 'Repetition.', section: NarrationSection.numberOccurrence));
      for (int i = 0; i < numberDetails.length; i++) {
        final d = numberDetails[i];
        final timeLabel = d.occurrence == 1 
            ? NumerologyUIContent.getLabel('time_singular', lang)
            : NumerologyUIContent.getLabel('time_plural', lang);
        final header = switch (lang) {
          AppLanguage.hindi => 'नंबर ${d.number} ${d.occurrence} $timeLabel आया है',
          AppLanguage.marathi => 'नंबर ${d.number} ${d.occurrence} $timeLabel आला आहे',
          AppLanguage.english => 'Number ${d.number} comes ${d.occurrence} $timeLabel',
        };
        chunks.add(NarrationChunk(text: header, section: NarrationSection.numberOccurrence, subIndex: i));
        chunks.add(NarrationChunk(text: d.getDescription(lang), section: NarrationSection.numberOccurrence, subIndex: i));
      }
    }

    // 10. Important Points
    if (importantPoints.isNotEmpty) {
      addSectionHeader('important_points', 'important_points_subtitle', NarrationSection.importantPoints);
      chunks.add(NarrationChunk(text: l10n['narrator_important'] ?? 'Tailored insights.', section: NarrationSection.importantPoints));
      for (int i = 0; i < importantPoints.length; i++) {
        final p = importantPoints[i];
        final header = '${NumerologyUIContent.getLabel('lo_shu_grid', lang)}: ${_joinList(p.includedNumbers)}';
        chunks.add(NarrationChunk(text: header, section: NarrationSection.importantPoints, subIndex: i));
        chunks.add(NarrationChunk(text: p.getDescription(lang), section: NarrationSection.importantPoints, subIndex: i));
      }
    }

    // 11. Stock Market
    if (stockInfo.isNotEmpty) {
      addSectionHeader('stock_market', 'stock_market_subtitle', NarrationSection.stockMarket);
      chunks.add(NarrationChunk(text: l10n['narrator_stock'] ?? 'Financial influences.', section: NarrationSection.stockMarket));
      for (int i = 0; i < stockInfo.length; i++) {
        final s = stockInfo[i];
        if (s.includedNumbers.isNotEmpty) {
           final header = '${NumerologyUIContent.getLabel('lo_shu_grid', lang)}: ${_joinList(s.includedNumbers)}';
           chunks.add(NarrationChunk(text: header, section: NarrationSection.stockMarket, subIndex: i));
        }
        chunks.add(NarrationChunk(text: s.getDescription(lang), section: NarrationSection.stockMarket, subIndex: i));
      }
    }

    // 12. Pinnacles
    if (pinnacle1.isNotEmpty || pinnacle2.isNotEmpty || pinnacle3.isNotEmpty || pinnacle4.isNotEmpty) {
      addSectionHeader('pinnacle_stage', 'pinnacle_subtitle', NarrationSection.pinnacles);
      chunks.add(NarrationChunk(text: l10n['narrator_pinnacle'] ?? 'Life stages.', section: NarrationSection.pinnacles));
      
      void addP(List<PinnacleData> d, String titleKey, int subIndex) {
        if (d.isEmpty) return;
        final p = d.first;
        final sectionTitle = NumerologyUIContent.getHeaderTitle(titleKey, lang);
        chunks.add(NarrationChunk(text: sectionTitle, section: NarrationSection.pinnacles, subIndex: subIndex));
        
        String det = l10n['narrator_pinnacle_detail'] ?? 'For age {range}, pinnacle is {number}: ';
        det = det.replaceAll('{range}', p.lifePeriodRange).replaceAll('{number}', p.pinnacleno.toString());
        chunks.add(NarrationChunk(text: det, section: NarrationSection.pinnacles, subIndex: subIndex));
        for (final item in d) chunks.add(NarrationChunk(text: item.getDescription(lang), section: NarrationSection.pinnacles, subIndex: subIndex));
      }
      addP(pinnacle1, 'pinnacle_1', 0); 
      addP(pinnacle2, 'pinnacle_2', 1); 
      addP(pinnacle3, 'pinnacle_3', 2); 
      addP(pinnacle4, 'pinnacle_4', 3);
    }

    // 13. Life Path
    if (lifePathItems.isNotEmpty) {
      addSectionHeader('life_path_details', 'life_path_subtitle', NarrationSection.lifePath);
      chunks.add(NarrationChunk(text: l10n['narrator_lifepath'] ?? 'Journey.', section: NarrationSection.lifePath));
      for (int i = 0; i < lifePathItems.length; i++) {
        chunks.add(NarrationChunk(text: lifePathItems[i].getDescription(lang), section: NarrationSection.lifePath, subIndex: i));
      }
    }

    // 14. Career
    if (careerItems.isNotEmpty) {
      addSectionHeader('career_destiny', 'career_destiny_subtitle', NarrationSection.career);
      chunks.add(NarrationChunk(text: l10n['narrator_career'] ?? 'Career paths.', section: NarrationSection.career));
      for (int i = 0; i < careerItems.length; i++) {
        chunks.add(NarrationChunk(text: careerItems[i].getDescription(lang), section: NarrationSection.career, subIndex: i));
      }
    }

    // 15. Boosting
    if (boostingItems.isNotEmpty) {
      addSectionHeader('boosting_personality', 'boosting_personality_subtitle', NarrationSection.boosting);
      chunks.add(NarrationChunk(text: l10n['narrator_boosting'] ?? 'Strengthening.', section: NarrationSection.boosting));
      for (int i = 0; i < boostingItems.length; i++) {
        chunks.add(NarrationChunk(text: boostingItems[i].getDescription(lang), section: NarrationSection.boosting, subIndex: i));
      }
    }

    // 16. Combination
    if (combinations.isNotEmpty) {
      addSectionHeader('combination_analysis', 'combination_subtitle', NarrationSection.combination);
      chunks.add(NarrationChunk(text: l10n['narrator_combination'] ?? 'Interactions.', section: NarrationSection.combination));
      for (int i = 0; i < combinations.length; i++) {
        final c = combinations[i];
        chunks.add(NarrationChunk(text: c.getDescription(lang), section: NarrationSection.combination, subIndex: i));
        if (c.getExample(lang).isNotEmpty) {
          chunks.add(NarrationChunk(text: '${NumerologyUIContent.getLabel('example', lang)}. ${c.getExample(lang)}', section: NarrationSection.combination, subIndex: i));
        }
      }
    }

    return chunks;
  }

  Future<void> playNarration(AppLanguage lang) async {
    final l10n = ref.read(birthdateL10nProvider);
    final chunks = _getNarrationChunks(lang, l10n);
    if (chunks.isEmpty) return;

    await _setNarrationLanguage(lang);
    await _flutterTts.stop();
    _isNarrationStopped = false;

    state = state.copyWith(
      isPlaying: true, isPaused: false, isStopped: false,
      currentChunk: 0, totalChunks: chunks.length,
      currentText: chunks.first.text, currentSection: chunks.first.section,
      currentSubIndex: chunks.first.subIndex,
    );

    for (int i = 0; i < chunks.length; i++) {
      if (_isNarrationStopped) break;
      while (state.isPaused && !_isNarrationStopped) await Future.delayed(const Duration(milliseconds: 300));
      if (_isNarrationStopped) break;

      state = state.copyWith(
        currentChunk: i + 1,
        currentText: chunks[i].text,
        currentSection: chunks[i].section,
        currentSubIndex: chunks[i].subIndex,
      );
      await _flutterTts.speak(chunks[i].text);
    }

    if (!_isNarrationStopped) stopNarration();
  }

  Future<void> pauseNarration() async {
    try { await _flutterTts.pause(); } catch (_) { await _flutterTts.stop(); }
    state = state.copyWith(isPlaying: false, isPaused: true, isStopped: false);
  }

  Future<void> stopNarration() async {
    _isNarrationStopped = true;
    await _flutterTts.stop();
    state = state.copyWith(isPlaying: false, isPaused: false, isStopped: true);
  }
}

final narrationProvider =
    NotifierProvider.autoDispose<NarrationNotifier, NarrationState>(
  NarrationNotifier.new,
);
