import 'package:connectivity_plus/connectivity_plus.dart';

/// True when at least one active network interface is available.
bool isOnlineFromResults(List<ConnectivityResult> results) {
  if (results.isEmpty) return false;
  return !results.every((r) => r == ConnectivityResult.none);
}
