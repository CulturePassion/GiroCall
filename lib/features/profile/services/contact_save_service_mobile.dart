import 'package:flutter_contacts/flutter_contacts.dart' as device;

import '../../../core/utils/card_url.dart';
import '../../../core/utils/vcard_builder.dart';
import '../../../shared/models/user_profile.dart';
import 'contact_save_service_share.dart';

Future<bool> saveProfileContactToDevice(UserProfile profile) async {
  final status = await device.FlutterContacts.permissions.request(
    device.PermissionType.readWrite,
  );
  if (status != device.PermissionStatus.granted &&
      status != device.PermissionStatus.limited) {
    return false;
  }

  final parts = profile.displayName.trim().split(RegExp(r'\s+'));
  final first = parts.isNotEmpty ? parts.first : profile.displayName;
  final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';

  final contact = device.Contact(
    name: device.Name(first: first, last: last),
    phones: [
      if (profile.phone != null && profile.phone!.isNotEmpty)
        device.Phone(number: profile.phone!),
    ],
    emails: [
      if (profile.email != null && profile.email!.isNotEmpty)
        device.Email(address: profile.email!),
    ],
    organizations: [
      if ((profile.company != null && profile.company!.isNotEmpty) ||
          (profile.title != null && profile.title!.isNotEmpty))
        device.Organization(
          name: profile.company,
          jobTitle: profile.title,
        ),
    ],
    notes: [
      if (profile.bio != null && profile.bio!.isNotEmpty)
        device.Note(note: profile.bio!),
      device.Note(note: 'GiroCall: ${CardUrl.publicCardUrl(profile.slug)}'),
    ],
    websites: [
      if (profile.website != null && profile.website!.isNotEmpty)
        device.Website(url: profile.website!),
      device.Website(url: CardUrl.publicCardUrl(profile.slug)),
    ],
  );

  await device.FlutterContacts.create(contact);
  return true;
}

Future<void> shareProfileVcard(UserProfile profile) {
  return shareProfileVcardFile(
    profile,
    VCardBuilder.fromProfile(
      profile,
      cardUrl: CardUrl.publicCardUrl(profile.slug),
    ),
  );
}