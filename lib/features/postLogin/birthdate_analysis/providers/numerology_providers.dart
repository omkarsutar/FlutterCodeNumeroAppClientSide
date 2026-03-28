import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_supabase_order_app_mobile/features/postLogin/birthdate_analysis/model/numerology_models.dart';
import 'package:flutter_supabase_order_app_mobile/features/postLogin/birthdate_analysis/services/numerology_calculator.dart';
import 'package:flutter_supabase_order_app_mobile/features/postLogin/cart/providers/birthdate_record_providers.dart';

final numerologyCalculatorProvider = Provider<NumerologyCalculator>((ref) {
  return NumerologyCalculator();
});

final numerologyProvider = Provider<NumerologyState>((ref) {
  final birthdate = ref.watch(birthdateProvider);
  if (birthdate == null) return NumerologyState();

  return ref.watch(numerologyCalculatorProvider).calculate(birthdate);
});
