import 'package:flutter_test/flutter_test.dart';
import 'package:girocall/features/wheel/providers/wheel_provider.dart';

void main() {
  group('WheelState', () {
    test('default state is not spinning with no selection', () {
      const state = WheelState();
      expect(state.isSpinning, isFalse);
      expect(state.selectedIndex, isNull);
      expect(state.rotation, 0);
      expect(state.selectedContact, isNull);
    });

    test('copyWith updates values', () {
      const state = WheelState();
      final updated = state.copyWith(
        isSpinning: true,
        rotation: 360,
        selectedIndex: 2,
      );
      expect(updated.isSpinning, isTrue);
      expect(updated.rotation, 360);
      expect(updated.selectedIndex, 2);
    });
  });
}
