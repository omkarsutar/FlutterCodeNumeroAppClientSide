import '../model/numerology_models.dart';

class NumerologyCalculator {
  NumerologyState calculate(DateTime birthdate) {
    final digits = _birthdateDigits(birthdate);

    final a = int.parse(digits[0]);
    final b = int.parse(digits[1]);
    final c = int.parse(digits[2]);
    final d = int.parse(digits[3]);
    final e = int.parse(digits[4]);
    final f = int.parse(digits[5]);
    final g = int.parse(digits[6]);
    final h = int.parse(digits[7]);

    final personality = _calcOneDigit(a + b);
    final lifePath = _calcOneDigit(a + b + c + d + e + f + g + h);
    final pinnacle1 = _calcOneDigit(a + b + c + d);
    final pinnacle2 = _calcOneDigit(a + b + e + f + g + h);
    final pinnacle3 = _calcOneDigit(pinnacle1 + pinnacle2);
    final pinnacle4 = _calcOneDigit(c + d + e + f + g + h);
    final pinnacleBase = 36 - lifePath;

    final loShuSource = <String>[
      ...digits.where((digit) => int.parse(digit) > 0),
      personality.toString(),
      lifePath.toString(),
    ];

    final loShuGrid = List.generate(3, (_) => List.generate(3, (_) => ''));
    for (final numStr in loShuSource) {
      switch (numStr) {
        case '4':
          loShuGrid[0][0] += '4';
          break;
        case '9':
          loShuGrid[0][1] += '9';
          break;
        case '2':
          loShuGrid[0][2] += '2';
          break;
        case '3':
          loShuGrid[1][0] += '3';
          break;
        case '5':
          loShuGrid[1][1] += '5';
          break;
        case '7':
          loShuGrid[1][2] += '7';
          break;
        case '8':
          loShuGrid[2][0] += '8';
          break;
        case '1':
          loShuGrid[2][1] += '1';
          break;
        case '6':
          loShuGrid[2][2] += '6';
          break;
      }
    }

    final presentSet = loShuSource.map(int.parse).toSet();
    final fullSet = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    final absentNumbers = fullSet.difference(presentSet).toList()..sort();
    final numberOccurrences = <int, int>{
      for (final number in fullSet)
        number: loShuSource.where((entry) => int.parse(entry) == number).length,
    };

    return NumerologyState(
      personality: personality,
      lifePath: lifePath,
      pinnacle1: pinnacle1,
      pinnacle2: pinnacle2,
      pinnacle3: pinnacle3,
      pinnacle4: pinnacle4,
      pinnacleBase: pinnacleBase,
      loShuGrid: loShuGrid,
      absentNumbers: absentNumbers,
      numberOccurrences: numberOccurrences,
    );
  }

  List<String> _birthdateDigits(DateTime birthdate) {
    final day = birthdate.day.toString().padLeft(2, '0');
    final month = birthdate.month.toString().padLeft(2, '0');
    final year = birthdate.year.toString().padLeft(4, '0');
    return '$day$month$year'.split('');
  }

  int _calcOneDigit(int value) {
    if (value >= 1 && value <= 9) return value;

    final sum = value
        .toString()
        .split('')
        .fold<int>(0, (total, digit) => total + int.parse(digit));
    return _calcOneDigit(sum);
  }
}
