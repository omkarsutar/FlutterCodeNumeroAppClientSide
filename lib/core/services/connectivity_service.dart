import 'package:async/async.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../interfaces/connectivity_service_interface.dart';

/// Implementation of [IConnectivityService] using the `connectivity_plus` package.
class ConnectivityServiceImpl implements IConnectivityService {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  @override
  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged
      .map((results) => !results.contains(ConnectivityResult.none));
}

/// Streams the current connectivity status as a boolean (true = online).
/// Emits immediately with the current state, then on every change.
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  // Use the name 'ref' to watch the provider from core_providers.dart
  // Note: Since this file is exported by the barrel, it should be fine.
  // However, specifically for this provider, we might need a direct import
  // if circular dependency occurs.
  final service =
      ConnectivityServiceImpl(); // Fallback to local instance if needed

  final connectivityChanges = service.onConnectivityChanged;
  final periodicChecks = Stream.periodic(
    const Duration(seconds: 3),
  ).asyncMap((_) => service.isOnline());
  final initialCheck = Stream.fromFuture(service.isOnline());

  return StreamGroup.merge<bool>([
    initialCheck,
    connectivityChanges,
    periodicChecks,
  ]).distinct();
});
