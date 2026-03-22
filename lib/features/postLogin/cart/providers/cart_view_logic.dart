import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProcessedCartData {
  final String totalAmount;
  final String totalProfit;
  final int itemCount;
  final bool isEmpty;

  ProcessedCartData({
    required this.totalAmount,
    required this.totalProfit,
    required this.itemCount,
    required this.isEmpty,
  });
}

final cartViewLogicProvider = Provider.autoDispose<ProcessedCartData>((ref) {
  return ProcessedCartData(
    totalAmount: '0',
    totalProfit: '0.00',
    itemCount: 0,
    isEmpty: true,
  );
});
