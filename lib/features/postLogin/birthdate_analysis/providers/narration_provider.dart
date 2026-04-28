import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../../core/providers/localization_provider.dart';
import '../model/numerology_models.dart';
import 'numerology_content_providers.dart';
import 'numerology_providers.dart';
import '../../cart/providers/birthdate_record_providers.dart';
import '../../../../core/providers/birthdate_localization_provider.dart';

class NarrationState {
  final bool isPlaying;
  final bool isPaused;
  final bool isStopped;

  const NarrationState({
    this.isPlaying = false,
    this.isPaused = false,
    this.isStopped = true,
    this.currentChunk = 0,
    this.totalChunks = 0,
  });

  final int currentChunk;
  final int totalChunks;

  NarrationState copyWith({
    bool? isPlaying,
    bool? isPaused,
    bool? isStopped,
    int? currentChunk,
    int? totalChunks,
  }) {
    return NarrationState(
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      isStopped: isStopped ?? this.isStopped,
      currentChunk: currentChunk ?? this.currentChunk,
      totalChunks: totalChunks ?? this.totalChunks,
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

  String _safeNarrationDate(DateTime birthdate, AppLanguage lang) {
    final monthNames = switch (lang) {
      AppLanguage.hindi => const [
        'जनवरी',
        'फरवरी',
        'मार्च',
        'अप्रैल',
        'मई',
        'जून',
        'जुलाई',
        'अगस्त',
        'सितंबर',
        'अक्टूबर',
        'नवंबर',
        'दिसंबर',
      ],
      AppLanguage.marathi => const [
        'जानेवारी',
        'फेब्रुवारी',
        'मार्च',
        'एप्रिल',
        'मे',
        'जून',
        'जुलै',
        'ऑगस्ट',
        'सप्टेंबर',
        'ऑक्टोबर',
        'नोव्हेंबर',
        'डिसेंबर',
      ],
      AppLanguage.english => const [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ],
    };

    return '${birthdate.day} ${monthNames[birthdate.month - 1]} ${birthdate.year}';
  }

  String _narrationText(AppLanguage lang, Map<String, String> l10n) {
    final birthdate = ref.read(birthdateProvider);
    final ageText = ref.read(ageProvider);
    final numerology = ref.read(numerologyProvider);
    final personality = ref.read(personalityDataProvider).valueOrNull;
    final planes =
        ref.read(loshuPlanesProvider).valueOrNull ?? const <LoshuPlane>[];
    final remedies =
        ref.read(remedyValuesProvider).valueOrNull ?? const <RemedyValues>[];
    final missingTells =
        ref.read(missingNumberTellsProvider).valueOrNull ??
        const <MissingNumberTell>[];
    final missingRemedies =
        ref.read(missingNumberRemediesProvider).valueOrNull ??
        const <MissingNumberRemedy>[];
    final numberDetails =
        ref.read(numberOccurrenceDetailsProvider).valueOrNull ??
        const <NumberOccurrenceDetail>[];
    final importantPoints =
        ref.read(importantPointsProvider).valueOrNull ??
        const <ImportantPoint>[];
    final stockInfo =
        ref.read(stockMarketInfoProvider).valueOrNull ??
        const <StockMarketInfo>[];
    final lifePathItems =
        ref.read(lifePathNumberDataProvider).valueOrNull ??
        const <LifePathData>[];
    final careerItems =
        ref.read(careerDataProvider).valueOrNull ?? const <CareerData>[];
    final boostingItems =
        ref.read(boostingPersonalityDataProvider).valueOrNull ??
        const <BoostingPersonalityData>[];
    final combinations =
        ref.read(combinationDataProvider).valueOrNull ??
        const <CombinationData>[];
    final pinnacle1 =
        ref.read(pinnacleData1Provider).valueOrNull ?? const <PinnacleData>[];
    final pinnacle2 =
        ref.read(pinnacleData2Provider).valueOrNull ?? const <PinnacleData>[];
    final pinnacle3 =
        ref.read(pinnacleData3Provider).valueOrNull ?? const <PinnacleData>[];
    final pinnacle4 =
        ref.read(pinnacleData4Provider).valueOrNull ?? const <PinnacleData>[];

    final lines = <String>[];

    // Intro
    lines.add(l10n['narrator_intro'] ?? 'Hello! This is your personal birthdate analysis.');

    // 1. Age
    if (ageText != null && ageText.isNotEmpty) {
      lines.add('${l10n['narrator_age'] ?? 'This is based on your age: '} $ageText.');
    }

    // 2. Numerology Core Details
    if (numerology.personality != null || numerology.lifePath != null) {
      lines.add(l10n['narrator_core'] ?? 'First, let\'s look at your core numbers.');
      lines.add(switch (lang) {
        AppLanguage.hindi =>
          'आपका पर्सनैलिटी नंबर ${numerology.personality ?? '-'} और लाइफ पाथ नंबर ${numerology.lifePath ?? '-'} है।',
        AppLanguage.marathi =>
          'तुमचा पर्सनॅलिटी नंबर ${numerology.personality ?? '-'} आणि लाईफ पाथ नंबर ${numerology.lifePath ?? '-'} आहे.',
        AppLanguage.english =>
          'Your personality number is ${numerology.personality ?? '-'} and your life path number is ${numerology.lifePath ?? '-'}.',
      });
    }

    // 3. Personality Analysis
    if (personality != null) {
      lines.add(l10n['narrator_personality'] ?? 'Personality analysis.');
      if (personality.getLord(lang).isNotEmpty) {
        lines.add(switch (lang) {
          AppLanguage.hindi =>
            'अधिपति: ${personality.getLord(lang)}।',
          AppLanguage.marathi =>
            'अधिपती: ${personality.getLord(lang)}.',
          AppLanguage.english =>
            'The ruling influence is ${personality.getLord(lang)}.',
        });
      }
      if (personality.getQualities(lang).isNotEmpty) {
        lines.add(personality.getQualities(lang));
      }
      if (personality.getWeaknesses(lang).isNotEmpty) {
        lines.add(personality.getWeaknesses(lang));
      }
      if (personality.getDescription(lang).isNotEmpty) {
        lines.add(personality.getDescription(lang));
      }
    }

    // 4. Lo Shu Grid (Simple mention)
    if (numerology.absentNumbers != null &&
        numerology.absentNumbers!.isNotEmpty) {
      lines.add(l10n['narrator_loshu'] ?? 'Lo Shu Grid insights.');
      lines.add('${l10n['absent_numbers_label'] ?? 'Missing Numbers'}: ${_joinList(numerology.absentNumbers!)}.');
    }

    // 5. Loshu Planes
    if (planes.isNotEmpty) {
      lines.add(l10n['narrator_planes'] ?? 'Grid planes analysis.');
      for (final plane in planes) {
        lines.add('${plane.getTitle(lang)}. ${plane.getDescription(lang)}');
      }
    }

    // 6. Remedy Values (Lucky/Unlucky)
    if (remedies.isNotEmpty) {
      lines.add(l10n['narrator_remedies'] ?? 'Positive energy enhancements.');
      final remedy = remedies.first;
      lines.add(switch (lang) {
        AppLanguage.hindi =>
          'शुभ नंबर ${_joinList(remedy.luckyNumbers)} हैं। शुभ रंग ${_joinList(remedy.getLuckyColors(lang))} हैं। शुभ दिन ${_joinList(remedy.getLuckyDays(lang))} हैं।',
        AppLanguage.marathi =>
          'शुभ अंक ${_joinList(remedy.luckyNumbers)} आहेत. शुभ रंग ${_joinList(remedy.getLuckyColors(lang))} आहेत. शुभ दिवस ${_joinList(remedy.getLuckyDays(lang))} आहेत.',
        AppLanguage.english =>
          'Lucky numbers are ${_joinList(remedy.luckyNumbers)}. Lucky colors are ${_joinList(remedy.getLuckyColors(lang))}. Lucky days are ${_joinList(remedy.getLuckyDays(lang))}.',
      });
    }

    // 7. Missing Number Tells
    if (missingTells.isNotEmpty) {
      lines.add(l10n['narrator_missing_tells'] ?? 'Challenges from missing numbers.');
      for (final tell in missingTells) {
        lines.add(tell.getDescription(lang));
      }
    }

    // 8. Missing Number Remedies
    if (missingRemedies.isNotEmpty) {
      lines.add(l10n['narrator_missing_remedies'] ?? 'Balancing missing energies.');
      for (final remedy in missingRemedies) {
        lines.add(remedy.getDescription(lang));
      }
    }

    // 9. Number Occurrence Details
    if (numberDetails.isNotEmpty) {
      lines.add(l10n['narrator_occurrence'] ?? 'Number repetition effects.');
      for (final detail in numberDetails) {
        lines.add(detail.getDescription(lang));
      }
    }

    // 10. Important Points
    if (importantPoints.isNotEmpty) {
      lines.add(l10n['narrator_important'] ?? 'Crucial tailored insights.');
      for (final point in importantPoints) {
        lines.add(point.getDescription(lang));
      }
    }

    // 11. Stock Market Info
    if (stockInfo.isNotEmpty) {
      lines.add(l10n['narrator_stock'] ?? 'Investment and financial influences.');
      for (final item in stockInfo) {
        lines.add(item.getDescription(lang));
      }
    }

    // 12. Pinnacles
    if (pinnacle1.isNotEmpty || pinnacle2.isNotEmpty || pinnacle3.isNotEmpty || pinnacle4.isNotEmpty) {
      lines.add(l10n['narrator_pinnacle'] ?? 'Life stages analysis.');
      
      void addPinnacle(List<PinnacleData> data) {
        if (data.isEmpty) return;
        final p = data.first;
        String detail = l10n['narrator_pinnacle_detail'] ?? 'For age range {range}, your pinnacle number is {number}: ';
        detail = detail.replaceAll('{range}', p.lifePeriodRange);
        detail = detail.replaceAll('{number}', p.pinnacleno.toString());
        lines.add(detail);
        for (final item in data) {
          lines.add(item.getDescription(lang));
        }
      }

      addPinnacle(pinnacle1);
      addPinnacle(pinnacle2);
      addPinnacle(pinnacle3);
      addPinnacle(pinnacle4);
    }

    // 13. Life Path Details
    if (lifePathItems.isNotEmpty) {
      lines.add(l10n['narrator_lifepath'] ?? 'Long-term journey insights.');
      for (final item in lifePathItems) {
        lines.add(item.getDescription(lang));
      }
    }

    // 14. Career Details
    if (careerItems.isNotEmpty) {
      lines.add(l10n['narrator_career'] ?? 'Career path fulfillment.');
      for (final item in careerItems) {
        lines.add(item.getDescription(lang));
      }
    }

    // 15. Boosting Personality
    if (boostingItems.isNotEmpty) {
      lines.add(l10n['narrator_boosting'] ?? 'Strengthening your personality.');
      for (final item in boostingItems) {
        lines.add(item.getDescription(lang));
      }
    }

    // 16. Combination Details
    if (combinations.isNotEmpty) {
      lines.add(l10n['narrator_combination'] ?? 'Unique interaction patterns.');
      for (final item in combinations) {
        lines.add(item.getDescription(lang));
      }
    }

    return lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join(' ');
  }


  Future<void> playNarration(AppLanguage lang) async {
    final l10n = ref.read(birthdateL10nProvider);
    final script = _narrationText(lang, l10n);
    if (script.trim().isEmpty) return;

    await _setNarrationLanguage(lang);
    await _flutterTts.stop();
    _isNarrationStopped = false;

    // chunking logic to prevent Android TTS crashing (max length 4000)
    final List<String> chunks = [];
    int start = 0;
    while (start < script.length) {
      if (start + 3000 < script.length) {
        int end = start + 3000;
        while (end > start &&
            script[end] != ' ' &&
            script[end] != '.' &&
            script[end] != '।') {
          end--;
        }
        if (end == start) end = start + 3000;
        chunks.add(script.substring(start, end).trim());
        start = end;
      } else {
        chunks.add(script.substring(start).trim());
        start = script.length;
      }
    }

    state = state.copyWith(
      isPlaying: true,
      isPaused: false,
      isStopped: false,
      currentChunk: 0,
      totalChunks: chunks.length,
    );

    for (int i = 0; i < chunks.length; i++) {
      if (_isNarrationStopped) break;

      while (state.isPaused && !_isNarrationStopped) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      if (_isNarrationStopped) break;

      state = state.copyWith(currentChunk: i + 1);
      await _flutterTts.speak(chunks[i]);
    }

    if (!_isNarrationStopped) {
      state = state.copyWith(isPlaying: false, isPaused: false, isStopped: true);
    }
  }

  Future<void> pauseNarration() async {
    try {
      await _flutterTts.pause();
    } catch (_) {
      await _flutterTts.stop();
    }
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
