import 'dart:math';

import '../../shared/models/contact.dart';

/// Computes a weight for each contact based on how overdue they are for a call.
///
/// Weight = max(daysSinceLastCall / targetFrequencyDays, 0.1)
/// Contacts that have never been called get a boosted weight so they appear
/// frequently on the wheel.
List<double> computeWheelWeights(List<Contact> contacts) {
  if (contacts.isEmpty) return [];

  return contacts.map((contact) {
    final daysSince = contact.daysSinceLastCall;
    final frequency = contact.targetFrequencyDays;

    if (daysSince == null) {
      // Never called — give a strong but not absolute weight.
      return 1.5;
    }

    final ratio = daysSince / frequency;
    return max(ratio, 0.1);
  }).toList();
}

/// Selects a contact index using weighted random sampling.
///
/// [random] is provided so callers can inject a deterministic value in tests.
int selectWeightedIndex(List<double> weights, {Random? random}) {
  assert(weights.isNotEmpty, 'Weights must not be empty');
  assert(weights.every((w) => w >= 0), 'Weights must be non-negative');

  final total = weights.reduce((a, b) => a + b);
  final rng = random ?? Random();
  var pivot = rng.nextDouble() * total;

  for (var i = 0; i < weights.length; i++) {
    pivot -= weights[i];
    if (pivot <= 0) return i;
  }

  return weights.length - 1;
}
