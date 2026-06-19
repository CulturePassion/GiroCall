import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:girocall/core/network/connectivity_status.dart';

void main() {
  group('isOnlineFromResults', () {
    test('returns false when all results are none', () {
      expect(
        isOnlineFromResults([ConnectivityResult.none]),
        isFalse,
      );
    });

    test('returns false for empty list', () {
      expect(isOnlineFromResults([]), isFalse);
    });

    test('returns true when wifi is available', () {
      expect(
        isOnlineFromResults([ConnectivityResult.wifi]),
        isTrue,
      );
    });

    test('returns true when any interface is connected', () {
      expect(
        isOnlineFromResults([
          ConnectivityResult.none,
          ConnectivityResult.mobile,
        ]),
        isTrue,
      );
    });
  });
}
