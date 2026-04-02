import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_supabase_order_app_mobile/core/services/connectivity_service.dart';
import 'package:flutter_supabase_order_app_mobile/core/interfaces/connectivity_service_interface.dart';

void main() {
  group('ConnectivityServiceImpl Tests', () {
    late IConnectivityService connectivityService;

    setUp(() {
      connectivityService = ConnectivityServiceImpl();
    });

    test('isOnline returns a boolean', () async {
      final result = await connectivityService.isOnline();
      expect(result, isA<bool>());
    });

    test('onConnectivityChanged is a stream of booleans', () {
      expect(connectivityService.onConnectivityChanged, isA<Stream<bool>>());
    });
  });
}
