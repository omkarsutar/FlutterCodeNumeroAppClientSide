import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_supabase_order_app_mobile/core/providers/core_providers.dart';
import 'package:flutter_supabase_order_app_mobile/features/postLogin/birthdate_analysis/model/numerology_models.dart';
import 'package:flutter_supabase_order_app_mobile/features/postLogin/birthdate_analysis/services/numerology_rpc_service.dart';
import 'package:flutter_supabase_order_app_mobile/features/postLogin/cart/providers/birthdate_record_providers.dart';

final numerologyRpcServiceProvider = Provider<NumerologyRpcService>((ref) {
  return NumerologyRpcService(ref.watch(supabaseClientProvider));
});

final activeBirthdateIdProvider = Provider<String?>((ref) {
  final record = ref.watch(currentBirthdateProvider);
  final status = ref.watch(cartStatusProvider);
  if (record == null || status == null) return null;
  return record.id;
});

final personalityDataProvider = FutureProvider<PersonalityData?>((ref) async {
  final birthdateId = ref.watch(activeBirthdateIdProvider);
  if (birthdateId == null) return null;

  final response = await ref
      .watch(numerologyRpcServiceProvider)
      .fetchList('get_personality_data', birthdateId: birthdateId);
  if (response.isEmpty) return null;
  return PersonalityData.fromMap(response.first);
});

final loshuPlanesProvider = FutureProvider<List<LoshuPlane>>((ref) async {
  final birthdateId = ref.watch(activeBirthdateIdProvider);
  if (birthdateId == null) return [];

  final response = await ref
      .watch(numerologyRpcServiceProvider)
      .fetchList('get_loshu_planes', birthdateId: birthdateId);
  return response.map(LoshuPlane.fromMap).toList();
});

final numberOccurrenceDetailsProvider =
    FutureProvider<List<NumberOccurrenceDetail>>((ref) async {
      final birthdateId = ref.watch(activeBirthdateIdProvider);
      if (birthdateId == null) return [];

      final response = await ref
          .watch(numerologyRpcServiceProvider)
          .fetchList(
            'get_number_occurrence_details',
            birthdateId: birthdateId,
          );
      return response.map(NumberOccurrenceDetail.fromMap).toList();
    });

Future<List<PinnacleData>> _fetchPinnacleData(
  Ref ref,
  String functionName,
) async {
  final birthdateId = ref.watch(activeBirthdateIdProvider);
  if (birthdateId == null) return [];

  final response = await ref
      .watch(numerologyRpcServiceProvider)
      .fetchList(functionName, birthdateId: birthdateId);
  return response.map(PinnacleData.fromMap).toList();
}

final pinnacleData1Provider = FutureProvider<List<PinnacleData>>((ref) {
  return _fetchPinnacleData(ref, 'get_pinnacle_data_for_lifeperiod1');
});

final pinnacleData2Provider = FutureProvider<List<PinnacleData>>((ref) {
  return _fetchPinnacleData(ref, 'get_pinnacle_data_for_lifeperiod2');
});

final pinnacleData3Provider = FutureProvider<List<PinnacleData>>((ref) {
  return _fetchPinnacleData(ref, 'get_pinnacle_data_for_lifeperiod3');
});

final pinnacleData4Provider = FutureProvider<List<PinnacleData>>((ref) {
  return _fetchPinnacleData(ref, 'get_pinnacle_data_for_lifeperiod4');
});

final lifePathNumberDataProvider = FutureProvider<List<LifePathData>>((
  ref,
) async {
  final birthdateId = ref.watch(activeBirthdateIdProvider);
  if (birthdateId == null) return [];

  final response = await ref
      .watch(numerologyRpcServiceProvider)
      .fetchList('get_life_path_number_data', birthdateId: birthdateId);
  return response.map(LifePathData.fromMap).toList();
});

final careerDataProvider = FutureProvider<List<CareerData>>((ref) async {
  final birthdateId = ref.watch(activeBirthdateIdProvider);
  if (birthdateId == null) return [];

  final response = await ref
      .watch(numerologyRpcServiceProvider)
      .fetchList('get_career_by_destiny', birthdateId: birthdateId);
  return response.map(CareerData.fromMap).toList();
});

final boostingPersonalityDataProvider =
    FutureProvider<List<BoostingPersonalityData>>((ref) async {
      final birthdateId = ref.watch(activeBirthdateIdProvider);
      if (birthdateId == null) return [];

      final response = await ref
          .watch(numerologyRpcServiceProvider)
          .fetchList(
            'get_boosting_personality_data',
            birthdateId: birthdateId,
          );
      return response.map(BoostingPersonalityData.fromMap).toList();
    });

final combinationDataProvider = FutureProvider<List<CombinationData>>((
  ref,
) async {
  final birthdateId = ref.watch(activeBirthdateIdProvider);
  if (birthdateId == null) return [];

  final response = await ref
      .watch(numerologyRpcServiceProvider)
      .fetchList(
        'get_combination_personality_lifepath',
        birthdateId: birthdateId,
      );
  return response.map(CombinationData.fromMap).toList();
});
