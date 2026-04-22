import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/core_providers.dart';

final notificationControllerProvider =
    StateNotifierProvider.autoDispose<NotificationController, AsyncValue<void>>(
      (ref) {
        final supabase = ref.watch(supabaseClientProvider);
        return NotificationController(supabase);
      },
    );

class NotificationController extends StateNotifier<AsyncValue<void>> {
  final SupabaseClient _supabase;

  NotificationController(this._supabase) : super(const AsyncData(null));

  Future<bool> sendNotification({
    required List<String> userIds,
    required String title,
    required String body,
    bool sendToAll = false,
  }) async {
    state = const AsyncLoading();
    try {
      // Calling Supabase Edge Function 'push-service'
      // The body contains userIds (empty if sendToAll is true), title, and body
      await _supabase.functions.invoke(
        'push-service',
        body: {
          'userIds': sendToAll ? [] : userIds,
          'title': title,
          'body': body,
          'sendToAll': sendToAll,
        },
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
