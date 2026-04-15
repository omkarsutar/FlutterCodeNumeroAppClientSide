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
  final String? lord;
  final String? lordHindi;
  final String? lordMarathi;
  final String? qualities;
  final String? qualitiesHindi;
  final String? qualitiesMarathi;
  final String? weaknesses;
  final String? weaknessesHindi;
  final String? weaknessesMarathi;
  final String? youShould;
  final String? youShouldHindi;
  final String? youShouldMarathi;
  final String? description;
  final String? descriptionHindi;
  final String? descriptionMarathi;

  PersonalityData({
    required this.personalityNumber,
    this.bornOn,
    this.lord,
    this.lordHindi,
    this.lordMarathi,
    this.qualities,
    this.qualitiesHindi,
    this.qualitiesMarathi,
    this.weaknesses,
    this.weaknessesHindi,
    this.weaknessesMarathi,
    this.youShould,
    this.youShouldHindi,
    this.youShouldMarathi,
    this.description,
    this.descriptionHindi,
    this.descriptionMarathi,
  });

  factory PersonalityData.fromMap(Map<String, dynamic> map) {
    return PersonalityData(
      personalityNumber: map['personality_number'] as int,
      bornOn: map['born_on'] as String?,
      lord: map['lord'] as String?,
      lordHindi: map['lord_hindi'] as String?,
      lordMarathi: map['lord_marathi'] as String?,
      qualities: map['qualities'] as String?,
      qualitiesHindi: map['qualities_hindi'] as String?,
      qualitiesMarathi: map['qualities_marathi'] as String?,
      weaknesses: map['weaknesses'] as String?,
      weaknessesHindi: map['weaknesses_hindi'] as String?,
      weaknessesMarathi: map['weaknesses_marathi'] as String?,
      youShould: map['you_should'] as String?,
      youShouldHindi: map['you_should_hindi'] as String?,
      youShouldMarathi: map['you_should_marathi'] as String?,
      description: map['description'] as String?,
      descriptionHindi: map['description_hindi'] as String?,
      descriptionMarathi: map['description_marathi'] as String?,
    );
  }

  String getLord(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return lordHindi ?? lord ?? '';
      case AppLanguage.marathi:
        return lordMarathi ?? lord ?? '';
      case AppLanguage.english:
        return lord ?? '';
    }
  }

  String getQualities(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return qualitiesHindi ?? qualities ?? '';
      case AppLanguage.marathi:
        return qualitiesMarathi ?? qualities ?? '';
      case AppLanguage.english:
        return qualities ?? '';
    }
  }

  String getWeaknesses(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return weaknessesHindi ?? weaknesses ?? '';
      case AppLanguage.marathi:
        return weaknessesMarathi ?? weaknesses ?? '';
      case AppLanguage.english:
        return weaknesses ?? '';
    }
  }

  String getYouShould(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return youShouldHindi ?? youShould ?? '';
      case AppLanguage.marathi:
        return youShouldMarathi ?? youShould ?? '';
      case AppLanguage.english:
        return youShould ?? '';
    }
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHindi ?? description ?? '';
      case AppLanguage.marathi:
        return descriptionMarathi ?? description ?? '';
      case AppLanguage.english:
        return description ?? '';
    }
  }
}

class LoshuPlane {
  final String gridPosition;
  final String title;
  final String description;
  final String? titleHindi;
  final String? titleMarathi;
  final String? descriptionHindi;
  final String? descriptionMarathi;

  LoshuPlane({
    required this.gridPosition,
    required this.title,
    required this.description,
    this.titleHindi,
    this.titleMarathi,
    this.descriptionHindi,
    this.descriptionMarathi,
  });

  factory LoshuPlane.fromMap(Map<String, dynamic> map) {
    return LoshuPlane(
      gridPosition: map['grid_position'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      titleHindi: map['title_hindi'] as String?,
      titleMarathi: map['title_marathi'] as String?,
      descriptionHindi: map['description_hindi'] as String?,
      descriptionMarathi: map['description_marathi'] as String?,
    );
  }

  String getTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return titleHindi ?? title;
      case AppLanguage.marathi:
        return titleMarathi ?? title;
      case AppLanguage.english:
        return title;
    }
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHindi ?? description;
      case AppLanguage.marathi:
        return descriptionMarathi ?? description;
      case AppLanguage.english:
        return description;
    }
  }
}

class NumberOccurrenceDetail {
  final int number;
  final int occurrence;
  final String description;
  final String? descriptionHindi;
  final String? descriptionMarathi;

  NumberOccurrenceDetail({
    required this.number,
    required this.occurrence,
    required this.description,
    this.descriptionHindi,
    this.descriptionMarathi,
  });

  factory NumberOccurrenceDetail.fromMap(Map<String, dynamic> map) {
    return NumberOccurrenceDetail(
      number: map['number'] as int,
      occurrence: map['occurrence'] as int,
      description: map['description'] as String,
      descriptionHindi: map['description_hindi'] as String?,
      descriptionMarathi: map['description_marathi'] as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHindi ?? description;
      case AppLanguage.marathi:
        return descriptionMarathi ?? description;
      case AppLanguage.english:
        return description;
    }
  }
}

class MissingNumberTell {
  final int missingNumber;
  final String description;
  final String? descriptionHindi;
  final String? descriptionMarathi;

  MissingNumberTell({
    required this.missingNumber,
    required this.description,
    this.descriptionHindi,
    this.descriptionMarathi,
  });

  factory MissingNumberTell.fromMap(Map<String, dynamic> map) {
    return MissingNumberTell(
      missingNumber: map['missing_number'] as int,
      description: map['description'] as String,
      descriptionHindi: map['description_hindi'] as String?,
      descriptionMarathi: map['description_marathi'] as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHindi ?? description;
      case AppLanguage.marathi:
        return descriptionMarathi ?? description;
      case AppLanguage.english:
        return description;
    }
  }
}

class StaticTestimonial {
  final int id;
  final String personName;
  final String description;
  final String image;
  final bool isActive;
  final String? descriptionHindi;
  final String? descriptionMarathi;

  StaticTestimonial({
    required this.id,
    required this.personName,
    required this.description,
    required this.image,
    required this.isActive,
    this.descriptionHindi,
    this.descriptionMarathi,
  });

  factory StaticTestimonial.fromMap(Map<String, dynamic> map) {
    return StaticTestimonial(
      id: map['id'] as int,
      personName: map['person_name'] as String,
      description: map['description'] as String,
      image: map['image'] as String,
      isActive: map['is_active'] as bool? ?? true,
      descriptionHindi: map['description_hindi'] as String?,
      descriptionMarathi: map['description_marathi'] as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHindi ?? description;
      case AppLanguage.marathi:
        return descriptionMarathi ?? description;
      case AppLanguage.english:
        return description;
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
      descriptionHi: (map['description_hi'] ?? map['description_hindi']) as String?,
      descriptionMr: (map['description_mr'] ?? map['description_marathi']) as String?,
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
      includedNumbers: (map['included_numbers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      descriptionEn: map['description_en'] as String? ?? map['description'] as String? ?? map['get_stock_market_info'] as String? ?? '',
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
  final List<String> unluckyColors;
  final List<int> luckyNumbers;
  final List<String> luckyColors;
  final List<String> luckyDays;
  final List<int> numbersForRemedy;
  final List<int> numbersNotForRemedy;

  RemedyValues({
    required this.unluckyNumbers,
    required this.unluckyColors,
    required this.luckyNumbers,
    required this.luckyColors,
    required this.luckyDays,
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
      unluckyColors: stringList('unlucky_colors'),
      luckyNumbers: intList('lucky_numbers'),
      luckyColors: stringList('lucky_colors'),
      luckyDays: stringList('lucky_days'),
      numbersForRemedy: intList('numbers_for_remedy'),
      numbersNotForRemedy: intList('numbers_not_for_remedy'),
    );
  }
}

class MissingNumberRemedy {
  final int missingNumber;
  final String description;
  final String? descriptionHindi;
  final String? descriptionMarathi;

  MissingNumberRemedy({
    required this.missingNumber,
    required this.description,
    this.descriptionHindi,
    this.descriptionMarathi,
  });

  factory MissingNumberRemedy.fromMap(Map<String, dynamic> map) {
    return MissingNumberRemedy(
      missingNumber: (map['missing_number'] as num).toInt(),
      description: map['description'] as String,
      descriptionHindi: map['description_hindi'] as String?,
      descriptionMarathi: map['description_marathi'] as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHindi ?? description;
      case AppLanguage.marathi:
        return descriptionMarathi ?? description;
      case AppLanguage.english:
        return description;
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
  final String description;
  final String? descriptionHindi;
  final String? descriptionMarathi;

  PinnacleData({
    required this.lifePeriodRange,
    required this.pinnacleno,
    required this.lifeperiod,
    required this.description,
    this.descriptionHindi,
    this.descriptionMarathi,
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
      description: map['description'] as String,
      descriptionHindi: map['description_hindi'] as String?,
      descriptionMarathi: map['description_marathi'] as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHindi ?? description;
      case AppLanguage.marathi:
        return descriptionMarathi ?? description;
      case AppLanguage.english:
        return description;
    }
  }
}

class LifePathData {
  final int lifePathNumber;
  final String description;
  final String? descriptionHindi;
  final String? descriptionMarathi;

  LifePathData({
    required this.lifePathNumber,
    required this.description,
    this.descriptionHindi,
    this.descriptionMarathi,
  });

  factory LifePathData.fromMap(Map<String, dynamic> map) {
    return LifePathData(
      lifePathNumber: map['life_path_number'] as int,
      description: map['description'] as String,
      descriptionHindi: map['description_hindi'] as String?,
      descriptionMarathi: map['description_marathi'] as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHindi ?? description;
      case AppLanguage.marathi:
        return descriptionMarathi ?? description;
      case AppLanguage.english:
        return description;
    }
  }
}

class CareerData {
  final int lifePathNumber;
  final String careerDescription;
  final String? careerDescriptionHindi;
  final String? careerDescriptionMarathi;

  CareerData({
    required this.lifePathNumber,
    required this.careerDescription,
    this.careerDescriptionHindi,
    this.careerDescriptionMarathi,
  });

  factory CareerData.fromMap(Map<String, dynamic> map) {
    return CareerData(
      lifePathNumber: map['life_path_number'] as int,
      careerDescription: map['career_description'] as String,
      careerDescriptionHindi: map['career_description_hindi'] as String?,
      careerDescriptionMarathi: map['career_description_marathi'] as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return careerDescriptionHindi ?? careerDescription;
      case AppLanguage.marathi:
        return careerDescriptionMarathi ?? careerDescription;
      case AppLanguage.english:
        return careerDescription;
    }
  }
}

class BoostingPersonalityData {
  final int personalityNumber;
  final String boostingDescription;
  final String? boostingDescriptionHindi;
  final String? boostingDescriptionMarathi;

  BoostingPersonalityData({
    required this.personalityNumber,
    required this.boostingDescription,
    this.boostingDescriptionHindi,
    this.boostingDescriptionMarathi,
  });

  factory BoostingPersonalityData.fromMap(Map<String, dynamic> map) {
    return BoostingPersonalityData(
      personalityNumber: map['personality_number'] as int,
      boostingDescription: map['boosting_description'] as String,
      boostingDescriptionHindi: map['boosting_description_hindi'] as String?,
      boostingDescriptionMarathi:
          map['boosting_description_marathi'] as String?,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return boostingDescriptionHindi ?? boostingDescription;
      case AppLanguage.marathi:
        return boostingDescriptionMarathi ?? boostingDescription;
      case AppLanguage.english:
        return boostingDescription;
    }
  }
}

class CombinationData {
  final int personalityNumber;
  final int lifePathNumber;
  final String description;
  final String? descriptionHindi;
  final String? descriptionMarathi;
  final String example;

  CombinationData({
    required this.personalityNumber,
    required this.lifePathNumber,
    required this.description,
    this.descriptionHindi,
    this.descriptionMarathi,
    required this.example,
  });

  factory CombinationData.fromMap(Map<String, dynamic> map) {
    return CombinationData(
      personalityNumber: map['personality_number'] as int,
      lifePathNumber: map['life_path_number'] as int,
      description: map['description'] as String,
      descriptionHindi: map['description_hindi'] as String?,
      descriptionMarathi: map['description_marathi'] as String?,
      example: map['example'] as String,
    );
  }

  String getDescription(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return descriptionHindi ?? description;
      case AppLanguage.marathi:
        return descriptionMarathi ?? description;
      case AppLanguage.english:
        return description;
    }
  }
}

