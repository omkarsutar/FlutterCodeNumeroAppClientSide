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
