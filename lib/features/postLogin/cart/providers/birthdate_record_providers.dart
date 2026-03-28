import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:flutter_supabase_order_app_mobile/core/providers/core_providers.dart';
import 'package:flutter_supabase_order_app_mobile/core/providers/localization_provider.dart';
import 'package:flutter_supabase_order_app_mobile/features/postLogin/birthdate_analysis/model/birthdate_model.dart';

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
        debugPrint('[BirthdateRecords] Raw birthdates data count: ${data.length}');
        return data.map((map) {
          try {
            return ModelBirthdate.fromMap(map);
          } catch (e, stack) {
            debugPrint(
              '[BirthdateRecords] Error mapping birthdate: $e\n$stack\nData: $map',
            );
            rethrow;
          }
        }).toList();
      });
});

final currentBirthdateProvider = Provider<ModelBirthdate?>((ref) {
  final birthdate = ref.watch(birthdateProvider);
  if (birthdate == null) return null;

  final formattedDate = DateFormat('yyyy-MM-dd').format(birthdate);
  final birthdatesAsync = ref.watch(birthdatesStreamProvider);

  return birthdatesAsync.when(
    data: (records) => records.firstWhereOrNull(
      (record) => DateFormat('yyyy-MM-dd').format(record.birthdate) == formattedDate,
    ),
    loading: () => null,
    error: (_, __) => null,
  );
});

final currentBirthdateRecordProvider = Provider<Map<String, dynamic>?>((ref) {
  final record = ref.watch(currentBirthdateProvider);
  return record?.toMap();
});

final cartStatusProvider = Provider<String?>((ref) {
  return ref.watch(currentBirthdateProvider)?.status;
});

final unpaidOrdersProvider = Provider<List<ModelBirthdate>>((ref) {
  final birthdatesAsync = ref.watch(birthdatesStreamProvider);
  return birthdatesAsync.when(
    data: (list) => list.where((b) => b.status.toLowerCase() == 'pending').toList(),
    loading: () => [],
    error: (e, stack) {
      debugPrint('[BirthdateRecords] Error fetching birthdates: $e\n$stack');
      return [];
    },
  );
});

final ageProvider = Provider<String?>((ref) {
  final birthdate = ref.watch(birthdateProvider);
  if (birthdate == null) return null;

  final l10n = ref.watch(l10nProvider);
  final components = _calculateAgeComponents(birthdate);

  final yLabel = l10n['years'] ?? 'years';
  final mLabel = l10n['months'] ?? 'months';
  final dLabel = l10n['days'] ?? 'days';

  return '${components['years']} $yLabel ${components['months']} $mLabel ${components['days']} $dLabel';
});

final ageComponentsProvider = Provider<Map<String, int>?>((ref) {
  final birthdate = ref.watch(birthdateProvider);
  if (birthdate == null) return null;
  return _calculateAgeComponents(birthdate);
});

Map<String, int> _calculateAgeComponents(DateTime birthdate) {
  final now = DateTime.now();
  int years = now.year - birthdate.year;
  int months = now.month - birthdate.month;
  int days = now.day - birthdate.day;

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
}
