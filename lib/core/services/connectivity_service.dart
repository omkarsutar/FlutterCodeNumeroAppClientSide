import 'package:async/async.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../interfaces/connectivity_service_interface.dart';

/// Implementation of [IConnectivityService] using the `connectivity_plus` package.
class ConnectivityServiceImpl implements IConnectivityService {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<bool> isOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.isEmpty) return true; // Default to online if no result yet
      return !results.contains(ConnectivityResult.none);
    } catch (e) {
      // If the platform channel fails (common on some web/desktop setups), 
      // assume online to avoid annoying the user with false offline errors.
      return true; 
    }
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
    const Duration(seconds: 5),
  ).asyncMap((_) => service.isOnline());
  
  // Delay the initial check slightly (500ms) to allow the platform to stabilize
  // on startup (common issue on Web/Chrome).
  final initialCheck = Stream.fromFuture(
    Future.delayed(const Duration(milliseconds: 500), () => service.isOnline()),
  );

  return StreamGroup.merge<bool>([
    initialCheck,
    connectivityChanges,
    periodicChecks,
  ]).distinct();
});
