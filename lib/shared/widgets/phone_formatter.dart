/// Lightweight phone number normalizer.
///
/// Keeps only digits and an optional leading +. Does not validate format —
/// the dialer handles that.
class PhoneFormatter {
  const PhoneFormatter._();

  static String normalize(String raw) {
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final char = raw[i];
      if (RegExp(r'\d').hasMatch(char)) {
        buffer.write(char);
      } else if (i == 0 && char == '+') {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  static bool looksValid(String phone) {
    final normalized = normalize(phone);
    return normalized.length >= 7;
  }
}
