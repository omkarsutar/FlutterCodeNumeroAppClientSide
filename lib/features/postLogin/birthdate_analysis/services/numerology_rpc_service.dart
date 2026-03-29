import 'package:supabase_flutter/supabase_flutter.dart';

class NumerologyRpcService {
  final SupabaseClient _client;

  NumerologyRpcService(this._client);

  Future<List<Map<String, dynamic>>> fetchList(
    String functionName, {
    required String birthdateId,
  }) async {
    final response = await _client.rpc(
      functionName,
      params: {'birthdate_id': birthdateId},
    );

    if (response == null) return [];
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    if (response is Map<String, dynamic>) {
      return [response];
    }
    return [];
  }

  Future<dynamic> fetchScalar(
    String functionName, {
    required String birthdateId,
  }) async {
    return _client.rpc(
      functionName,
      params: {'birthdate_id': birthdateId},
    );
  }
}
