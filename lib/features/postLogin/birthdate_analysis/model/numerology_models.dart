import '../../../../core/providers/localization_provider.dart';

class NumerologyState {
  final int? personality;
  final int? lifePath;
  final int? pinnacle1;
  final int? pinnacle2;
  final int? pinnacle3;
  final int? pinnacle4;
  final int? pinnacleBase;
  final List<List<String>>? loShuGrid;
  final List<int>? absentNumbers;
  final Map<int, int>? numberOccurrences;

  NumerologyState({
    this.personality,
    this.lifePath,
    this.pinnacle1,
    this.pinnacle2,
    this.pinnacle3,
    this.pinnacle4,
    this.pinnacleBase,
    this.loShuGrid,
    this.absentNumbers,
    this.numberOccurrences,
  });
}

class PersonalityData {
  final int personalityNumber;
  final String? bornOn;
  final String? lordEn;
  final String? lordHi;
  final String? lordMr;
  final String? qualitiesEn;
  final String? qualitiesHi;
  final String? qualitiesMr;
  final String? weaknessesEn;
  final String? weaknessesHi;
  final String? weaknessesMr;
  final String? youShouldEn;
  final String? youShouldHi;
  final String? youShouldMr;
  final String? descriptionEn;
  final String? descriptionHi;
  final String? descriptionMr;

  PersonalityData({
    required this.personalityNumber,
    this.bornOn,
    this.lordEn,
    this.lordHi,
    this.lordMr,
    this.qualitiesEn,
    this.qualitiesHi,
    this.qualitiesMr,
    this.weaknessesEn,
    this.weaknessesHi,
    this.weaknessesMr,
    this.youShouldEn,
    this.youShouldHi,
    this.youShouldMr,
    this.descriptionEn,
    this.descriptionHi,
    this.descriptionMr,
  });

  factory PersonalityData.fromMap(Map<String, dynamic> map) {
    return PersonalityData(
      personalityNumber: map['personality_number'] as int,
      bornOn: map['born_on'] as String?,
      lordEn: map['lord'] as String?,
      lordHi: map['lord_hindi'] as String?,
      lordMr: map['lord_marathi'] as String?,
      qualitiesEn: map['qualities'] as String?,
      qualitiesHi: map['qualities_hindi'] as String?,
      qualitiesMr: map['qualities_marathi'] as String?,
      weaknessesEn: map['weaknesses'] as String?,
      weaknessesHi: map['weaknesses_hindi'] as String?,
      weaknessesMr: map['weaknesses_marathi'] as String?,
      youShouldEn: map['you_should'] as String?,
      youShouldHi: map['you_should_hindi'] as String?,
      youShouldMr: map['you_should_marathi'] as String?,
      descriptionEn: map['description'] as String?,
      descriptionHi: map['description_hindi'] as String?,
      descriptionMr: map['description_marathi'] as String?,
    );
  }

  String getLord(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return lordHi ?? lordEn ?? '';
      case AppLanguage.marathi:
        return lordMr ?? lordEn ?? '';
      case AppLanguage.english:
        return lordEn ?? '';
    }
  }

  String getQualities(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return qualitiesHi ?? qualitiesEn ?? '';
      case AppLanguage.marathi:
        return qualitiesMr ?? qualitiesEn ?? '';
      case AppLanguage.english:
        return qualitiesEn ?? '';
    }
  }

  String getWeaknesses(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return weaknessesHi ?? weaknessesEn ?? '';
      case AppLanguage.marathi:
        return weaknessesMr ?? weaknessesEn ?? '';
      case AppLanguage.english:
        return weaknessesEn ?? '';
    }
  }

  String getYouShould(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return youShouldHi ?? youShouldEn ?? '';
      case AppLanguage.marathi:
        return youShouldMr ?? youShouldEn ?? '';
      case AppLanguage.english:
        return youShouldEn ?? '';
    }
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHi ?? descriptionEn ?? '';
      case AppLanguage.marathi:
        return descriptionMr ?? descriptionEn ?? '';
      case AppLanguage.english:
        return descriptionEn ?? '';
    }
  }
}

class LoshuPlane {
  final String gridPosition;
  final String titleEn;
  final String descriptionEn;
  final String? titleHi;
  final String? titleMr;
  final String? descriptionHi;
  final String? descriptionMr;

  LoshuPlane({
    required this.gridPosition,
    required this.titleEn,
    required this.descriptionEn,
    this.titleHi,
    this.titleMr,
    this.descriptionHi,
    this.descriptionMr,
  });

  factory LoshuPlane.fromMap(Map<String, dynamic> map) {
    return LoshuPlane(
      gridPosition: map['grid_position'] as String,
      titleEn: map['title'] as String,
      descriptionEn: map['description'] as String,
      titleHi: map['title_hindi'] as String?,
      titleMr: map['title_marathi'] as String?,
      descriptionHi: map['description_hindi'] as String?,
      descriptionMr: map['description_marathi'] as String?,
    );
  }

  String getTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return titleHi ?? titleEn;
      case AppLanguage.marathi:
        return titleMr ?? titleEn;
      case AppLanguage.english:
        return titleEn;
    }
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHi ?? descriptionEn;
      case AppLanguage.marathi:
        return descriptionMr ?? descriptionEn;
      case AppLanguage.english:
        return descriptionEn;
    }
  }
}

class NumberOccurrenceDetail {
  final int number;
  final int occurrence;
  final String descriptionEn;
  final String? descriptionHi;
  final String? descriptionMr;

  NumberOccurrenceDetail({
    required this.number,
    required this.occurrence,
    required this.descriptionEn,
    this.descriptionHi,
    this.descriptionMr,
  });

  factory NumberOccurrenceDetail.fromMap(Map<String, dynamic> map) {
    return NumberOccurrenceDetail(
      number: map['number'] as int,
      occurrence: map['occurrence'] as int,
      descriptionEn: map['description'] as String,
      descriptionHi: map['description_hindi'] as String?,
      descriptionMr: map['description_marathi'] as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHi ?? descriptionEn;
      case AppLanguage.marathi:
        return descriptionMr ?? descriptionEn;
      case AppLanguage.english:
        return descriptionEn;
    }
  }
}

class MissingNumberTell {
  final int missingNumber;
  final String descriptionEn;
  final String? descriptionHi;
  final String? descriptionMr;

  MissingNumberTell({
    required this.missingNumber,
    required this.descriptionEn,
    this.descriptionHi,
    this.descriptionMr,
  });

  factory MissingNumberTell.fromMap(Map<String, dynamic> map) {
    return MissingNumberTell(
      missingNumber: map['missing_number'] as int,
      descriptionEn: map['description'] as String,
      descriptionHi: map['description_hindi'] as String?,
      descriptionMr: map['description_marathi'] as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHi ?? descriptionEn;
      case AppLanguage.marathi:
        return descriptionMr ?? descriptionEn;
      case AppLanguage.english:
        return descriptionEn;
    }
  }
}

class StaticTestimonial {
  final int id;
  final String personName;
  final String descriptionEn;
  final String image;
  final bool isActive;
  final String? descriptionHi;
  final String? descriptionMr;

  StaticTestimonial({
    required this.id,
    required this.personName,
    required this.descriptionEn,
    required this.image,
    required this.isActive,
    this.descriptionHi,
    this.descriptionMr,
  });

  factory StaticTestimonial.fromMap(Map<String, dynamic> map) {
    return StaticTestimonial(
      id: map['id'] as int,
      personName: map['person_name'] as String,
      descriptionEn: map['description'] as String,
      image: map['image'] as String,
      isActive: map['is_active'] as bool? ?? true,
      descriptionHi: map['description_hindi'] as String?,
      descriptionMr: map['description_marathi'] as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHi ?? descriptionEn;
      case AppLanguage.marathi:
        return descriptionMr ?? descriptionEn;
      case AppLanguage.english:
        return descriptionEn;
    }
  }
}

class ImportantPoint {
  final List<String> includedNumbers;
  final String descriptionEn;
  final String? descriptionHi;
  final String? descriptionMr;

  ImportantPoint({
    required this.includedNumbers,
    required this.descriptionEn,
    this.descriptionHi,
    this.descriptionMr,
  });

  factory ImportantPoint.fromMap(Map<String, dynamic> map) {
    return ImportantPoint(
      includedNumbers: (map['included_numbers'] as List<dynamic>)
          .map((item) => item.toString())
          .toList(),
      descriptionEn: (map['description_en'] ?? map['description']) as String,
      descriptionHi:
          (map['description_hi'] ?? map['description_hindi']) as String?,
      descriptionMr:
          (map['description_mr'] ?? map['description_marathi']) as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHi ?? descriptionEn;
      case AppLanguage.marathi:
        return descriptionMr ?? descriptionEn;
      case AppLanguage.english:
        return descriptionEn;
    }
  }
}

class StockMarketInfo {
  final List<String> includedNumbers;
  final String descriptionEn;
  final String? descriptionHi;
  final String? descriptionMr;

  StockMarketInfo({
    required this.includedNumbers,
    required this.descriptionEn,
    this.descriptionHi,
    this.descriptionMr,
  });

  factory StockMarketInfo.fromMap(Map<String, dynamic> map) {
    return StockMarketInfo(
      includedNumbers:
          (map['included_numbers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      descriptionEn:
          map['description_en'] as String? ??
          map['description'] as String? ??
          map['get_stock_market_info'] as String? ??
          '',
      descriptionHi: map['description_hi'] as String?,
      descriptionMr: map['description_mr'] as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHi ?? descriptionEn;
      case AppLanguage.marathi:
        return descriptionMr ?? descriptionEn;
      case AppLanguage.english:
        return descriptionEn;
    }
  }
}

class RemedyValues {
  final List<int> unluckyNumbers;
  final List<String> unluckyColorsEn;
  final List<String>? unluckyColorsHi;
  final List<String>? unluckyColorsMr;
  final List<int> luckyNumbers;
  final List<String> luckyColorsEn;
  final List<String>? luckyColorsHi;
  final List<String>? luckyColorsMr;
  final List<String> luckyDaysEn;
  final List<String>? luckyDaysHi;
  final List<String>? luckyDaysMr;
  final List<int> numbersForRemedy;
  final List<int> numbersNotForRemedy;

  RemedyValues({
    required this.unluckyNumbers,
    required this.unluckyColorsEn,
    this.unluckyColorsHi,
    this.unluckyColorsMr,
    required this.luckyNumbers,
    required this.luckyColorsEn,
    this.luckyColorsHi,
    this.luckyColorsMr,
    required this.luckyDaysEn,
    this.luckyDaysHi,
    this.luckyDaysMr,
    required this.numbersForRemedy,
    required this.numbersNotForRemedy,
  });

  factory RemedyValues.fromMap(Map<String, dynamic> map) {
    List<int> intList(String key) =>
        (map[key] as List<dynamic>? ?? []).map((item) => item as int).toList();
    List<String> stringList(String key) => (map[key] as List<dynamic>? ?? [])
        .map((item) => item.toString())
        .toList();

    return RemedyValues(
      unluckyNumbers: intList('unlucky_numbers'),
      unluckyColorsEn: stringList('unlucky_colors'),
      unluckyColorsHi: map['unlucky_colors_hindi'] != null
          ? stringList('unlucky_colors_hindi')
          : null,
      unluckyColorsMr: map['unlucky_colors_marathi'] != null
          ? stringList('unlucky_colors_marathi')
          : null,
      luckyNumbers: intList('lucky_numbers'),
      luckyColorsEn: stringList('lucky_colors'),
      luckyColorsHi: map['lucky_colors_hindi'] != null
          ? stringList('lucky_colors_hindi')
          : null,
      luckyColorsMr: map['lucky_colors_marathi'] != null
          ? stringList('lucky_colors_marathi')
          : null,
      luckyDaysEn: stringList('lucky_days'),
      luckyDaysHi: map['lucky_days_hindi'] != null
          ? stringList('lucky_days_hindi')
          : null,
      luckyDaysMr: map['lucky_days_marathi'] != null
          ? stringList('lucky_days_marathi')
          : null,
      numbersForRemedy: intList('numbers_for_remedy'),
      numbersNotForRemedy: intList('numbers_not_for_remedy'),
    );
  }

  List<String> getLuckyColors(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return luckyColorsHi ?? luckyColorsEn;
      case AppLanguage.marathi:
        return luckyColorsMr ?? luckyColorsEn;
      case AppLanguage.english:
        return luckyColorsEn;
    }
  }

  List<String> getUnluckyColors(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return unluckyColorsHi ?? unluckyColorsEn;
      case AppLanguage.marathi:
        return unluckyColorsMr ?? unluckyColorsEn;
      case AppLanguage.english:
        return unluckyColorsEn;
    }
  }

  List<String> getLuckyDays(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return luckyDaysHi ?? luckyDaysEn;
      case AppLanguage.marathi:
        return luckyDaysMr ?? luckyDaysEn;
      case AppLanguage.english:
        return luckyDaysEn;
    }
  }
}

class MissingNumberRemedy {
  final int missingNumber;
  final String descriptionEn;
  final String? descriptionHi;
  final String? descriptionMr;

  MissingNumberRemedy({
    required this.missingNumber,
    required this.descriptionEn,
    this.descriptionHi,
    this.descriptionMr,
  });

  factory MissingNumberRemedy.fromMap(Map<String, dynamic> map) {
    return MissingNumberRemedy(
      missingNumber: (map['missing_number'] as num).toInt(),
      descriptionEn: map['description'] as String,
      descriptionHi:
          (map['description_hi'] ?? map['description_hindi']) as String?,
      descriptionMr:
          (map['description_mr'] ?? map['description_marathi']) as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHi ?? descriptionEn;
      case AppLanguage.marathi:
        return descriptionMr ?? descriptionEn;
      case AppLanguage.english:
        return descriptionEn;
    }
  }
}

class NumbersNotForRemedyInfo {
  final List<int> numbers;

  NumbersNotForRemedyInfo({required this.numbers});

  factory NumbersNotForRemedyInfo.fromMap(Map<String, dynamic> map) {
    return NumbersNotForRemedyInfo(
      numbers: (map['get_numbers_not_for_remedy'] as List<dynamic>? ?? [])
          .map((item) => (item as num).toInt())
          .toList(),
    );
  }
}

class PinnacleData {
  final String lifePeriodRange;
  final int pinnacleno;
  final int lifeperiod;
  final String descriptionEn;
  final String? descriptionHi;
  final String? descriptionMr;

  PinnacleData({
    required this.lifePeriodRange,
    required this.pinnacleno,
    required this.lifeperiod,
    required this.descriptionEn,
    this.descriptionHi,
    this.descriptionMr,
  });

  factory PinnacleData.fromMap(Map<String, dynamic> map) {
    String range = '';
    if (map.containsKey('life_period1')) {
      range = map['life_period1'] as String;
    } else if (map.containsKey('life_period2')) {
      range = map['life_period2'] as String;
    } else if (map.containsKey('life_period3')) {
      range = map['life_period3'] as String;
    } else if (map.containsKey('life_period4')) {
      range = map['life_period4'] as String;
    }

    return PinnacleData(
      lifePeriodRange: range,
      pinnacleno: map['pinnacleno'] as int,
      lifeperiod: map['lifeperiod'] as int,
      descriptionEn: map['description'] as String,
      descriptionHi:
          (map['description_hi'] ?? map['description_hindi']) as String?,
      descriptionMr:
          (map['description_mr'] ?? map['description_marathi']) as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHi ?? descriptionEn;
      case AppLanguage.marathi:
        return descriptionMr ?? descriptionEn;
      case AppLanguage.english:
        return descriptionEn;
    }
  }
}

class LifePathData {
  final int lifePathNumber;
  final String descriptionEn;
  final String? descriptionHi;
  final String? descriptionMr;

  LifePathData({
    required this.lifePathNumber,
    required this.descriptionEn,
    this.descriptionHi,
    this.descriptionMr,
  });

  factory LifePathData.fromMap(Map<String, dynamic> map) {
    return LifePathData(
      lifePathNumber: map['life_path_number'] as int,
      descriptionEn: map['description'] as String,
      descriptionHi:
          (map['description_hi'] ?? map['description_hindi']) as String?,
      descriptionMr:
          (map['description_mr'] ?? map['description_marathi']) as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHi ?? descriptionEn;
      case AppLanguage.marathi:
        return descriptionMr ?? descriptionEn;
      case AppLanguage.english:
        return descriptionEn;
    }
  }
}

class CareerData {
  final int lifePathNumber;
  final String careerDescriptionEn;
  final String? careerDescriptionHi;
  final String? careerDescriptionMr;

  CareerData({
    required this.lifePathNumber,
    required this.careerDescriptionEn,
    this.careerDescriptionHi,
    this.careerDescriptionMr,
  });

  factory CareerData.fromMap(Map<String, dynamic> map) {
    return CareerData(
      lifePathNumber: map['life_path_number'] as int,
      careerDescriptionEn: map['career_description'] as String,
      careerDescriptionHi:
          (map['career_description_hi'] ?? map['career_description_hindi'])
              as String?,
      careerDescriptionMr:
          (map['career_description_mr'] ?? map['career_description_marathi'])
              as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return careerDescriptionHi ?? careerDescriptionEn;
      case AppLanguage.marathi:
        return careerDescriptionMr ?? careerDescriptionEn;
      case AppLanguage.english:
        return careerDescriptionEn;
    }
  }
}

class BoostingPersonalityData {
  final int personalityNumber;
  final String boostingDescriptionEn;
  final String? boostingDescriptionHi;
  final String? boostingDescriptionMr;

  BoostingPersonalityData({
    required this.personalityNumber,
    required this.boostingDescriptionEn,
    this.boostingDescriptionHi,
    this.boostingDescriptionMr,
  });

  factory BoostingPersonalityData.fromMap(Map<String, dynamic> map) {
    return BoostingPersonalityData(
      personalityNumber: map['personality_number'] as int,
      boostingDescriptionEn: map['boosting_description'] as String,
      boostingDescriptionHi:
          (map['boosting_description_hi'] ?? map['boosting_description_hindi'])
              as String?,
      boostingDescriptionMr:
          (map['boosting_description_mr'] ??
                  map['boosting_description_marathi'])
              as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return boostingDescriptionHi ?? boostingDescriptionEn;
      case AppLanguage.marathi:
        return boostingDescriptionMr ?? boostingDescriptionEn;
      case AppLanguage.english:
        return boostingDescriptionEn;
    }
  }
}

class CombinationData {
  final int personalityNumber;
  final int lifePathNumber;
  final String descriptionEn;
  final String? descriptionHi;
  final String? descriptionMr;
  final String example;

  CombinationData({
    required this.personalityNumber,
    required this.lifePathNumber,
    required this.descriptionEn,
    this.descriptionHi,
    this.descriptionMr,
    required this.example,
  });

  factory CombinationData.fromMap(Map<String, dynamic> map) {
    return CombinationData(
      personalityNumber: map['personality_number'] as int,
      lifePathNumber: map['life_path_number'] as int,
      descriptionEn: map['description'] as String,
      descriptionHi:
          (map['description_hi'] ?? map['description_hindi']) as String?,
      descriptionMr:
          (map['description_mr'] ?? map['description_marathi']) as String?,
      example: map['example'] as String,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHi ?? descriptionEn;
      case AppLanguage.marathi:
        return descriptionMr ?? descriptionEn;
      case AppLanguage.english:
        return descriptionEn;
    }
  }
}
