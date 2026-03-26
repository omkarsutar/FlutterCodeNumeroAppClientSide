import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_supabase_order_app_mobile/core/providers/localization_provider.dart';

import 'package:flutter_supabase_order_app_mobile/core/providers/core_providers.dart';
import '../../birthdate_analysis/model/birthdate_model.dart';

class CartState {
  final bool isLoading;
  final String? error;
  final bool isPromptAcknowledged;

  CartState({
    this.isLoading = false,
    this.error,
    this.isPromptAcknowledged = false,
  });

  CartState copyWith({
    bool? isLoading,
    String? error,
    bool? isPromptAcknowledged,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isPromptAcknowledged: isPromptAcknowledged ?? this.isPromptAcknowledged,
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    return CartState();
  }

  void markPromptAsAcknowledged() {
    state = state.copyWith(isPromptAcknowledged: true);
  }

  void clearCart() {
    state = state.copyWith(isPromptAcknowledged: false);
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});

final birthdateProvider = StateProvider<DateTime?>((ref) => null);

final birthdatesStreamProvider = StreamProvider<List<ModelBirthdate>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return Stream.value([]);

  return client
      .from('birthdates')
      .stream(primaryKey: ['id'])
      .eq('user_id', user.id)
      .map((data) {
        debugPrint('[Providers] Raw birthdates data count: ${data.length}');
        return data.map((map) {
          try {
            return ModelBirthdate.fromMap(map);
          } catch (e, stack) {
            debugPrint(
              '[Providers] Error mapping birthdate: $e\n$stack\nData: $map',
            );
            rethrow;
          }
        }).toList();
      });
});

final cartStatusProvider = Provider<String?>((ref) {
  final birthdate = ref.watch(birthdateProvider);
  if (birthdate == null) return null;

  final formattedDate = DateFormat('yyyy-MM-dd').format(birthdate);
  final birthdatesAsync = ref.watch(birthdatesStreamProvider);

  return birthdatesAsync.when(
    data: (list) {
      final match = list.firstWhereOrNull(
        (b) => DateFormat('yyyy-MM-dd').format(b.birthdate) == formattedDate,
      );
      return match?.status;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

final unpaidOrdersProvider = Provider<List<ModelBirthdate>>((ref) {
  final birthdatesAsync = ref.watch(birthdatesStreamProvider);
  return birthdatesAsync.when(
    data: (list) {
      debugPrint(
        '[Providers] UnpaidOrders data received: ${list.length} items',
      );
      return list.where((b) => b.status.toLowerCase() == 'pending').toList();
    },
    loading: () => [],
    error: (e, stack) {
      debugPrint('[Providers] Error fetching birthdates: $e\n$stack');
      return [];
    },
  );
});

final selectedOrdersProvider = StateProvider<Set<String>>((ref) => {});

final ageProvider = Provider<String?>((ref) {
  final birthdate = ref.watch(birthdateProvider);
  if (birthdate == null) return null;

  final l10n = ref.watch(l10nProvider);

  final now = DateTime.now();
  int years = now.year - birthdate.year;
  int months = now.month - birthdate.month;
  int days = now.day - birthdate.day;

  // Adjust for month/day difference
  if (days < 0) {
    months--;
    final prevMonth = DateTime(now.year, now.month, 0);
    days += prevMonth.day;
  }
  if (months < 0) {
    years--;
    months += 12;
  }

  final yLabel = l10n['years'] ?? 'years';
  final mLabel = l10n['months'] ?? 'months';
  final dLabel = l10n['days'] ?? 'days';

  return "$years $yLabel $months $mLabel $days $dLabel";
});

final ageComponentsProvider = Provider<Map<String, int>?>((ref) {
  final birthdate = ref.watch(birthdateProvider);
  if (birthdate == null) return null;

  final now = DateTime.now();
  int years = now.year - birthdate.year;
  int months = now.month - birthdate.month;
  int days = now.day - birthdate.day;

  // Adjust for month/day difference
  if (days < 0) {
    months--;
    final prevMonth = DateTime(now.year, now.month, 0);
    days += prevMonth.day;
  }
  if (months < 0) {
    years--;
    months += 12;
  }

  return {'years': years, 'months': months, 'days': days};
});

final birthdateDigitsProvider = Provider<List<String>?>((ref) {
  final birthdate = ref.watch(birthdateProvider);
  if (birthdate == null) return null;

  final day = birthdate.day.toString().padLeft(2, '0');
  final month = birthdate.month.toString().padLeft(2, '0');
  final year = birthdate.year.toString().padLeft(4, '0');

  final fullString = "$day$month$year";
  return fullString.split('');
});

int calcOnedigit(int val) {
  if (val < 1 || val > 9) {
    final s = val.toString();
    int sum = 0;
    for (int i = 0; i < s.length; i++) {
      sum += int.parse(s[i]);
    }
    return calcOnedigit(sum);
  }
  return val;
}

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

final currentBirthdateRecordProvider = StreamProvider<Map<String, dynamic>?>((
  ref,
) {
  final birthdate = ref.watch(birthdateProvider);
  if (birthdate == null) return Stream.value(null);

  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return Stream.value(null);

  final formattedDate = DateFormat('yyyy-MM-dd').format(birthdate);

  return client
      .from('birthdates')
      .stream(primaryKey: ['id'])
      .eq('user_id', user.id)
      .map((data) {
        final matches = data
            .where((item) => item['birthdate'] == formattedDate)
            .toList();
        return matches.isNotEmpty ? matches.first : null;
      });
});

final personalityDataProvider = FutureProvider<PersonalityData?>((ref) async {
  final recordAsync = ref.watch(currentBirthdateRecordProvider);
  final record = recordAsync.valueOrNull;
  if (record == null) return null;

  final birthdateId = record['id'] as String;
  final status = ref.watch(cartStatusProvider);

  // Fetch if saved (status is not null)
  if (status == null) return null;

  final response = await ref
      .read(supabaseClientProvider)
      .rpc('get_personality_data', params: {'birthdate_id': birthdateId});

  if (response == null || (response as List).isEmpty) return null;

  return PersonalityData.fromMap(response[0]);
});

final loshuPlanesProvider = FutureProvider<List<LoshuPlane>>((ref) async {
  final recordAsync = ref.watch(currentBirthdateRecordProvider);
  final record = recordAsync.valueOrNull;
  if (record == null) return [];

  final birthdateId = record['id'] as String;
  final status = ref.watch(cartStatusProvider);

  // Fetch only if status is not null (saved)
  if (status == null) return [];

  final response = await ref
      .read(supabaseClientProvider)
      .rpc('get_loshu_planes', params: {'birthdate_id': birthdateId});

  if (response == null || (response as List).isEmpty) return [];

  return response
      .map((item) => LoshuPlane.fromMap(item as Map<String, dynamic>))
      .toList();
});

final numberOccurrenceDetailsProvider =
    FutureProvider<List<NumberOccurrenceDetail>>((ref) async {
      final recordAsync = ref.watch(currentBirthdateRecordProvider);
      final record = recordAsync.valueOrNull;
      if (record == null) return [];

      final birthdateId = record['id'] as String;
      final status = ref.watch(cartStatusProvider);

      // Fetch only if status is not null (saved)
      if (status == null) return [];

      final response = await ref
          .read(supabaseClientProvider)
          .rpc(
            'get_number_occurrence_details',
            params: {'birthdate_id': birthdateId},
          );

      if (response == null || (response as List).isEmpty) return [];

      return response
          .map(
            (item) =>
                NumberOccurrenceDetail.fromMap(item as Map<String, dynamic>),
          )
          .toList();
    });

final numerologyProvider = Provider<NumerologyState>((ref) {
  final digits = ref.watch(birthdateDigitsProvider);
  if (digits == null || digits.length < 8) return NumerologyState();

  final a = int.parse(digits[0]);
  final b = int.parse(digits[1]);
  final c = int.parse(digits[2]);
  final d = int.parse(digits[3]);
  final e = int.parse(digits[4]);
  final f = int.parse(digits[5]);
  final g = int.parse(digits[6]);
  final h = int.parse(digits[7]);

  final personality = calcOnedigit(a + b);
  final lifePath = calcOnedigit(a + b + c + d + e + f + g + h);
  final pinnacle1 = calcOnedigit(a + b + c + d);
  final pinnacle2 = calcOnedigit(a + b + e + f + g + h);
  final pinnacle3 = calcOnedigit(pinnacle1 + pinnacle2);
  final pinnacle4 = calcOnedigit(c + d + e + f + g + h);
  final pinnacleBase = 36 - lifePath;

  // Lo Shu Grid Logic
  final arr1 = <String>[];
  for (final d in digits) {
    if (int.parse(d) > 0) arr1.add(d);
  }
  arr1.add(personality.toString());
  arr1.add(lifePath.toString());

  final loShuGrid = List.generate(3, (_) => List.generate(3, (_) => ""));

  for (final numStr in arr1) {
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

  // Absent Numbers Logic
  final presentSet = arr1.map((e) => int.parse(e)).toSet();
  final fullSet = {1, 2, 3, 4, 5, 6, 7, 8, 9};
  final absentNumbers = fullSet.difference(presentSet).toList()..sort();

  // Number Occurrences Logic
  final numberOccurrences = <int, int>{};
  for (final num in fullSet) {
    numberOccurrences[num] = arr1.where((e) => int.parse(e) == num).length;
  }

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
});
