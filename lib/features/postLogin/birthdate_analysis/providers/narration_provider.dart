import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../../core/providers/localization_provider.dart';
import '../model/numerology_models.dart';
import 'numerology_content_providers.dart';
import 'numerology_providers.dart';
import '../../cart/providers/birthdate_record_providers.dart';

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

  String _narrationText(AppLanguage lang) {
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

    final intro = switch (lang) {
      AppLanguage.hindi =>
        'यह आपकी जन्मतिथि का व्यक्तिगत विश्लेषण है। मैं अब आपके लिए मुख्य संकेत पढ़ रहा हूँ।',
      AppLanguage.marathi =>
        'हे तुमच्या जन्मतारखेचे वैयक्तिक विश्लेषण आहे. आता मी तुमच्यासाठी मुख्य संकेत वाचत आहे.',
      AppLanguage.english =>
        'This is your personal birthdate analysis. I will now read the key insights for you.',
    };

    final lines = <String>[intro];

    if (birthdate != null) {
      lines.add(switch (lang) {
        AppLanguage.hindi =>
          'जन्मतिथि ${_safeNarrationDate(birthdate, lang)} है।',
        AppLanguage.marathi =>
          'जन्मतारीख ${_safeNarrationDate(birthdate, lang)} आहे.',
        AppLanguage.english =>
          'The selected birthdate is ${_safeNarrationDate(birthdate, lang)}.',
      });
    }

    if (ageText != null && ageText.isNotEmpty) {
      lines.add(ageText);
    }

    if (numerology.personality != null || numerology.lifePath != null) {
      lines.add(switch (lang) {
        AppLanguage.hindi =>
          'आपका पर्सनैलिटी नंबर ${numerology.personality ?? '-'} और लाइफ पाथ नंबर ${numerology.lifePath ?? '-'} है।',
        AppLanguage.marathi =>
          'तुमचा पर्सनॅलिटी नंबर ${numerology.personality ?? '-'} आणि लाईफ पाथ नंबर ${numerology.lifePath ?? '-'} आहे.',
        AppLanguage.english =>
          'Your personality number is ${numerology.personality ?? '-'} and your life path number is ${numerology.lifePath ?? '-'}.',
      });
    }

    if (personality != null) {
      if (personality.getLord(lang).isNotEmpty) {
        lines.add(switch (lang) {
          AppLanguage.hindi =>
            'आपके व्यक्तित्व के अधिपति ${personality.getLord(lang)} हैं।',
          AppLanguage.marathi =>
            'तुमच्या व्यक्तिमत्त्वाचे अधिपती ${personality.getLord(lang)} आहेत.',
          AppLanguage.english =>
            'The ruling influence for your personality is ${personality.getLord(lang)}.',
        });
      }
      if (personality.getQualities(lang).isNotEmpty) {
        lines.add(personality.getQualities(lang));
      }
      if (personality.getWeaknesses(lang).isNotEmpty) {
        lines.add(personality.getWeaknesses(lang));
      }
      if (personality.getYouShould(lang).isNotEmpty) {
        lines.add(personality.getYouShould(lang));
      }
      if (personality.getDescription(lang).isNotEmpty) {
        lines.add(personality.getDescription(lang));
      }
    }

    if (numerology.absentNumbers != null &&
        numerology.absentNumbers!.isNotEmpty) {
      lines.add(switch (lang) {
        AppLanguage.hindi =>
          'लापता नंबर हैं: ${_joinList(numerology.absentNumbers!)}।',
        AppLanguage.marathi =>
          'गहाळ अंक आहेत: ${_joinList(numerology.absentNumbers!)}.',
        AppLanguage.english =>
          'Your missing numbers are ${_joinList(numerology.absentNumbers!)}.',
      });
    }

    if (planes.isNotEmpty) {
      for (final plane in planes.take(3)) {
        lines.add('${plane.getTitle(lang)}. ${plane.getDescription(lang)}');
      }
    }

    if (remedies.isNotEmpty) {
      final remedy = remedies.first;
      lines.add(switch (lang) {
        AppLanguage.hindi =>
          'शुभ नंबर ${_joinList(remedy.luckyNumbers)} हैं। शुभ रंग ${_joinList(remedy.getLuckyColors(lang))} हैं। शुभ दिन ${_joinList(remedy.getLuckyDays(lang))} हैं।',
        AppLanguage.marathi =>
          'शुभ अंक ${_joinList(remedy.luckyNumbers)} आहेत. शुभ रंग ${_joinList(remedy.getLuckyColors(lang))} आहेत. शुभ दिवस ${_joinList(remedy.getLuckyDays(lang))} आहेत.',
        AppLanguage.english =>
          'Your lucky numbers are ${_joinList(remedy.luckyNumbers)}. Your lucky colors are ${_joinList(remedy.getLuckyColors(lang))}. Your lucky days are ${_joinList(remedy.getLuckyDays(lang))}.',
      });
    }

    for (final tell in missingTells.take(3)) {
      lines.add(tell.getDescription(lang));
    }

    for (final remedy in missingRemedies.take(3)) {
      lines.add(remedy.getDescription(lang));
    }

    for (final detail in numberDetails.take(3)) {
      lines.add(detail.getDescription(lang));
    }

    for (final point in importantPoints.take(3)) {
      lines.add(point.getDescription(lang));
    }

    for (final item in stockInfo.take(2)) {
      lines.add(item.getDescription(lang));
    }

    for (final item in lifePathItems.take(1)) {
      lines.add(item.getDescription(lang));
    }

    for (final item in careerItems.take(1)) {
      lines.add(item.getDescription(lang));
    }

    for (final item in boostingItems.take(1)) {
      lines.add(item.getDescription(lang));
    }

    for (final item in combinations.take(1)) {
      lines.add(item.getDescription(lang));
    }

    for (final pinnacle in [
      ...pinnacle1,
      ...pinnacle2,
      ...pinnacle3,
      ...pinnacle4,
    ].take(4)) {
      lines.add(pinnacle.getDescription(lang));
    }

    return lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join(' ');
  }

  Future<void> playNarration(AppLanguage lang) async {
    final script = _narrationText(lang);
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
