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
  final String? qualities;
  final String? weaknesses;
  final String? youShould;
  final String? description;

  PersonalityData({
    required this.personalityNumber,
    this.bornOn,
    this.lord,
    this.qualities,
    this.weaknesses,
    this.youShould,
    this.description,
  });

  factory PersonalityData.fromMap(Map<String, dynamic> map) {
    return PersonalityData(
      personalityNumber: map['personality_number'] as int,
      bornOn: map['born_on'] as String?,
      lord: map['lord'] as String?,
      qualities: map['qualities'] as String?,
      weaknesses: map['weaknesses'] as String?,
      youShould: map['you_should'] as String?,
      description: map['description'] as String?,
    );
  }
}

class LoshuPlane {
  final String gridPosition;
  final String title;
  final String description;

  LoshuPlane({
    required this.gridPosition,
    required this.title,
    required this.description,
  });

  factory LoshuPlane.fromMap(Map<String, dynamic> map) {
    return LoshuPlane(
      gridPosition: map['grid_position'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
    );
  }
}

class NumberOccurrenceDetail {
  final int number;
  final int occurrence;
  final String description;

  NumberOccurrenceDetail({
    required this.number,
    required this.occurrence,
    required this.description,
  });

  factory NumberOccurrenceDetail.fromMap(Map<String, dynamic> map) {
    return NumberOccurrenceDetail(
      number: map['number'] as int,
      occurrence: map['occurrence'] as int,
      description: map['description'] as String,
    );
  }
}

class MissingNumberTell {
  final int missingNumber;
  final String description;

  MissingNumberTell({
    required this.missingNumber,
    required this.description,
  });

  factory MissingNumberTell.fromMap(Map<String, dynamic> map) {
    return MissingNumberTell(
      missingNumber: map['missing_number'] as int,
      description: map['description'] as String,
    );
  }
}

class StaticTestimonial {
  final int id;
  final String personName;
  final String description;
  final String image;
  final bool isActive;

  StaticTestimonial({
    required this.id,
    required this.personName,
    required this.description,
    required this.image,
    required this.isActive,
  });

  factory StaticTestimonial.fromMap(Map<String, dynamic> map) {
    return StaticTestimonial(
      id: map['id'] as int,
      personName: map['person_name'] as String,
      description: map['description'] as String,
      image: map['image'] as String,
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}

class ImportantPoint {
  final List<String> includedNumbers;
  final String description;

  ImportantPoint({
    required this.includedNumbers,
    required this.description,
  });

  factory ImportantPoint.fromMap(Map<String, dynamic> map) {
    return ImportantPoint(
      includedNumbers: (map['included_numbers'] as List<dynamic>)
          .map((item) => item.toString())
          .toList(),
      description: map['description'] as String,
    );
  }
}

class StockMarketInfo {
  final String insight;

  StockMarketInfo({required this.insight});

  factory StockMarketInfo.fromMap(Map<String, dynamic> map) {
    return StockMarketInfo(
      insight: map['get_stock_market_info'] as String,
    );
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
    List<String> stringList(String key) =>
        (map[key] as List<dynamic>? ?? [])
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

class PinnacleData {
  final String lifePeriodRange;
  final int pinnacleno;
  final int lifeperiod;
  final String description;

  PinnacleData({
    required this.lifePeriodRange,
    required this.pinnacleno,
    required this.lifeperiod,
    required this.description,
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
    );
  }
}

class LifePathData {
  final int lifePathNumber;
  final String description;

  LifePathData({required this.lifePathNumber, required this.description});

  factory LifePathData.fromMap(Map<String, dynamic> map) {
    return LifePathData(
      lifePathNumber: map['life_path_number'] as int,
      description: map['description'] as String,
    );
  }
}

class CareerData {
  final int lifePathNumber;
  final String careerDescription;

  CareerData({required this.lifePathNumber, required this.careerDescription});

  factory CareerData.fromMap(Map<String, dynamic> map) {
    return CareerData(
      lifePathNumber: map['life_path_number'] as int,
      careerDescription: map['career_description'] as String,
    );
  }
}

class BoostingPersonalityData {
  final int personalityNumber;
  final String boostingDescription;

  BoostingPersonalityData({
    required this.personalityNumber,
    required this.boostingDescription,
  });

  factory BoostingPersonalityData.fromMap(Map<String, dynamic> map) {
    return BoostingPersonalityData(
      personalityNumber: map['personality_number'] as int,
      boostingDescription: map['boosting_description'] as String,
    );
  }
}

class CombinationData {
  final int personalityNumber;
  final int lifePathNumber;
  final String description;
  final String example;

  CombinationData({
    required this.personalityNumber,
    required this.lifePathNumber,
    required this.description,
    required this.example,
  });

  factory CombinationData.fromMap(Map<String, dynamic> map) {
    return CombinationData(
      personalityNumber: map['personality_number'] as int,
      lifePathNumber: map['life_path_number'] as int,
      description: map['description'] as String,
      example: map['example'] as String,
    );
  }
}
