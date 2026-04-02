/// Interface for the connectivity service.
/// Decouples the application from the underlying connectivity library.
abstract class IConnectivityService {
  /// Returns true if the device has an active internet connection.
  Future<bool> isOnline();

  /// A stream that emits the current connectivity status.
  Stream<bool> get onConnectivityChanged;
}
