import 'package:flutter_contacts/flutter_contacts.dart' as device;
import 'package:permission_handler/permission_handler.dart';

import '../../../shared/models/contact.dart';
import '../../../shared/widgets/phone_formatter.dart';

bool get supportsDeviceContactImport => true;

final _properties = {
  device.ContactProperty.name,
  device.ContactProperty.phone,
  device.ContactProperty.email,
  device.ContactProperty.address,
  device.ContactProperty.organization,
  device.ContactProperty.website,
  device.ContactProperty.note,
  device.ContactProperty.event,
};

Future<List<Contact>> importDeviceContacts({required String userId}) async {
  final status = await Permission.contacts.request();
  if (!status.isGranted) {
    throw Exception(
      'Contacts permission is required. Enable it in Settings, then try again.',
    );
  }

  final deviceContacts = await device.FlutterContacts.getAll(
    properties: _properties,
  );

  final contacts = <Contact>[];
  for (final dc in deviceContacts) {
    final mapped = _mapFromDevice(dc, userId: userId);
    if (mapped != null) contacts.add(mapped);
  }

  return contacts;
}

Contact? _mapFromDevice(device.Contact dc, {required String userId}) {
  final phone = dc.phones.firstOrNull?.number;
  if (phone == null || phone.isEmpty) return null;

  final normalized = PhoneFormatter.normalize(phone);
  if (!PhoneFormatter.looksValid(normalized)) return null;

  final first = dc.name?.first?.trim() ?? '';
  final last = dc.name?.last?.trim() ?? '';
  final org = dc.organizations.firstOrNull;
  final address = dc.addresses.firstOrNull;
  final birthdayEvent = dc.events
      .where((e) => e.label.label == device.EventLabel.birthday)
      .firstOrNull;

  return Contact(
    userId: userId,
    name: Contact.buildDisplayName(
      firstName: first.isEmpty ? null : first,
      lastName: last.isEmpty ? null : last,
      fallback: dc.displayName,
    ),
    phone: normalized,
    firstName: first.isEmpty ? null : first,
    lastName: last.isEmpty ? null : last,
    email: dc.emails.firstOrNull?.address,
    company: org?.name,
    jobTitle: org?.jobTitle,
    birthday: birthdayEvent != null
        ? DateTime(
            birthdayEvent.year ?? 1900,
            birthdayEvent.month,
            birthdayEvent.day,
          )
        : null,
    secondaryPhone: dc.phones.length > 1
        ? PhoneFormatter.normalize(dc.phones[1].number)
        : null,
    website: dc.websites.firstOrNull?.url,
    notes: dc.notes.firstOrNull?.note,
    addressLine1: address?.street,
    city: address?.city,
    state: address?.state,
    postalCode: address?.postalCode,
    country: address?.country,
    deviceNativeId: dc.id,
    syncToDevice: true,
    lastDeviceSyncAt: DateTime.now(),
  );
}