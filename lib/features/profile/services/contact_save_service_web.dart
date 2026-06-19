// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import '../../../core/utils/card_url.dart';
import '../../../core/utils/vcard_builder.dart';
import '../../../shared/models/user_profile.dart';

Future<bool> saveProfileContactToDevice(UserProfile profile) async {
  return false;
}

Future<void> shareProfileVcard(UserProfile profile) async {
  final vcard = VCardBuilder.fromProfile(
    profile,
    cardUrl: CardUrl.publicCardUrl(profile.slug),
  );
  final filename = '${profile.slug}.vcf';
  final bytes = html.Blob([vcard], 'text/vcard');
  final url = html.Url.createObjectUrlFromBlob(bytes);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
