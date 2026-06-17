import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:girocall/core/utils/weighting_utils.dart';
import 'package:girocall/shared/models/contact.dart';

void main() {
  group('computeWheelWeights', () {
    test('returns empty list for empty contacts', () {
      expect(computeWheelWeights([]), isEmpty);
    });

    test('boosts weight for never-called contacts', () {
      final contacts = [
        const Contact(userId: 'u1', name: 'Alice', phone: '111'),
      ];
      expect(computeWheelWeights(contacts), [1.5]);
    });

    test('increases weight for overdue contacts', () {
      final contacts = [
        Contact(
          userId: 'u1',
          name: 'Alice',
          phone: '111',
          targetFrequencyDays: 30,
          lastCalledAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
        Contact(
          userId: 'u1',
          name: 'Bob',
          phone: '222',
          targetFrequencyDays: 30,
          lastCalledAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];

      final weights = computeWheelWeights(contacts);
      expect(weights[0], greaterThan(weights[1]));
    });
  });

  group('selectWeightedIndex', () {
    test('selects only index when one weight exists', () {
      expect(selectWeightedIndex([1.0]), 0);
    });

    test('selects higher index when weight dominates', () {
      final random = Random(42);
      // Weight 0 is 99, weight 1 is 1. Almost always selects 0.
      var zeroCount = 0;
      for (var i = 0; i < 100; i++) {
        if (selectWeightedIndex([99.0, 1.0], random: random) == 0) {
          zeroCount++;
        }
      }
      expect(zeroCount, greaterThan(80));
    });

    test('throws on empty weights', () {
      expect(() => selectWeightedIndex([]), throwsAssertionError);
    });
  });
}
