import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_supabase_order_app_mobile/core/providers/localization_provider.dart';

import '../../purchase_orders/providers/purchase_order_providers.dart';

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

final cartStatusProvider = Provider<String?>((ref) {
  final birthdate = ref.watch(birthdateProvider);
  if (birthdate == null) return null;

  final formattedDate = DateFormat('dd-MMM-yyyy').format(birthdate);
  final ordersAsync = ref.watch(purchaseOrdersStreamProvider);

  return ordersAsync.when(
    data: (orders) {
      final match = orders.firstWhereOrNull(
        (o) =>
            o.userComment == formattedDate &&
            o.status?.toLowerCase() == 'confirmed',
      );
      return match?.status;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

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
      case '4': loShuGrid[0][0] += '4'; break;
      case '9': loShuGrid[0][1] += '9'; break;
      case '2': loShuGrid[0][2] += '2'; break;
      case '3': loShuGrid[1][0] += '3'; break;
      case '5': loShuGrid[1][1] += '5'; break;
      case '7': loShuGrid[1][2] += '7'; break;
      case '8': loShuGrid[2][0] += '8'; break;
      case '1': loShuGrid[2][1] += '1'; break;
      case '6': loShuGrid[2][2] += '6'; break;
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
