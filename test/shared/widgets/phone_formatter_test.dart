import 'package:flutter_test/flutter_test.dart';
import 'package:girocall/shared/widgets/phone_formatter.dart';

void main() {
  group('PhoneFormatter', () {
    test('normalizes phone with formatting characters', () {
      expect(PhoneFormatter.normalize('(555) 123-4567'), '5551234567');
    });

    test('preserves leading plus', () {
      expect(PhoneFormatter.normalize('+1 (555) 123-4567'), '+15551234567');
    });

    test('rejects too-short numbers', () {
      expect(PhoneFormatter.looksValid('123'), isFalse);
    });

    test('accepts valid numbers', () {
      expect(PhoneFormatter.looksValid('5551234567'), isTrue);
    });
  });
}
