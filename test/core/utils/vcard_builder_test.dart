import 'package:flutter_test/flutter_test.dart';
import 'package:girocall/core/utils/vcard_builder.dart';
import 'package:girocall/shared/models/user_profile.dart';

void main() {
  test('VCardBuilder includes core profile fields', () {
    const profile = UserProfile(
      userId: 'u1',
      slug: 'jane-doe',
      displayName: 'Jane Doe',
      title: 'Founder',
      company: 'GiroCall',
      phone: '+15551234567',
      email: 'jane@example.com',
      isPublic: true,
    );

    final vcard = VCardBuilder.fromProfile(profile);

    expect(vcard, contains('FN:Jane Doe'));
    expect(vcard, contains('TITLE:Founder'));
    expect(vcard, contains('ORG:GiroCall'));
    expect(vcard, contains('TEL;TYPE=CELL:+15551234567'));
    expect(vcard, contains('EMAIL;TYPE=INTERNET:jane@example.com'));
    expect(
        vcard, contains('URL;TYPE=GIROCALL:https://girocall.com/me/jane-doe'));
    expect(vcard, contains('UID:girocall-jane-doe@girocall.com'));
    expect(vcard, contains('BEGIN:VCARD'));
    expect(vcard, contains('END:VCARD'));
  });
}
