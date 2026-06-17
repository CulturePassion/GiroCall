import 'package:flutter_test/flutter_test.dart';
import 'package:girocall/shared/models/contact_tag.dart';

void main() {
  test('ContactTag.fromValue parses known tags', () {
    expect(ContactTag.fromValue('friends'), ContactTag.friends);
    expect(ContactTag.fromValue('business'), ContactTag.business);
    expect(ContactTag.fromValue('unknown'), isNull);
    expect(ContactTag.fromValue(null), isNull);
  });
}
