import 'package:flutter_test/flutter_test.dart';
import 'package:girocall/shared/models/contact.dart';

void main() {
  group('Contact', () {
    test('daysSinceLastCall is null when never called', () {
      const contact = Contact(userId: 'u1', name: 'Alice', phone: '111');
      expect(contact.daysSinceLastCall, isNull);
      expect(contact.isOverdue, isTrue);
    });

    test('isOverdue when days since last call exceeds frequency', () {
      final contact = Contact(
        userId: 'u1',
        name: 'Alice',
        phone: '111',
        targetFrequencyDays: 7,
        lastCalledAt: DateTime.now().subtract(const Duration(days: 10)),
      );
      expect(contact.isOverdue, isTrue);
    });

    test('copyWith updates fields', () {
      const contact = Contact(userId: 'u1', name: 'Alice', phone: '111');
      final updated = contact.copyWith(name: 'Alice Smith');
      expect(updated.name, 'Alice Smith');
      expect(updated.phone, '111');
    });

    test('serializes and deserializes', () {
      final contact = Contact(
        id: 'c1',
        userId: 'u1',
        name: 'Alice',
        phone: '111',
        targetFrequencyDays: 14,
        lastCalledAt: DateTime(2026, 6, 1),
      );
      final json = contact.toJson();
      final restored = Contact.fromJson(json);
      expect(restored.name, contact.name);
      expect(restored.targetFrequencyDays, 14);
    });
  });
}
