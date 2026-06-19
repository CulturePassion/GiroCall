import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity_status.dart';

/// Live online/offline status from device connectivity.
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  yield isOnlineFromResults(await connectivity.checkConnectivity());

  await for (final results in connectivity.onConnectivityChanged) {
    yield isOnlineFromResults(results);
  }
});
