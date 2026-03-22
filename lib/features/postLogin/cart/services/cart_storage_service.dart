import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class CartStorageService {
  static const String _pendingOrderKey = 'pending_order';

  Future<void> clearPendingOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingOrderKey);
      debugPrint('[CartStorageService] Cleared pending order.');
    } catch (e) {
      debugPrint('[CartStorageService] Error clearing pending order: $e');
    }
  }
}
