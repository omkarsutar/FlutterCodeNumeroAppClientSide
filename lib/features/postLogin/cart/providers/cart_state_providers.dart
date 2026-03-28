import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final selectedOrdersProvider = StateProvider<Set<String>>((ref) => {});
