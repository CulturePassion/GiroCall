import 'package:flutter_contacts/flutter_contacts.dart' as device;
import 'package:permission_handler/permission_handler.dart';

import '../../../shared/models/contact.dart';
import '../../../shared/widgets/phone_formatter.dart';

bool get supportsDeviceContactSync => true;

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

Future<List<Contact>> pullDeviceContacts({required String userId}) async {
  await _ensurePermission();

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

Future<void> pushContactToDevice(Contact contact) async {
  if (!contact.syncToDevice) return;
  await _ensurePermission(write: true);

  if (contact.deviceNativeId != null) {
    final existing = await device.FlutterContacts.get(
      contact.deviceNativeId!,
      properties: _properties,
    );
    if (existing != null) {
      await device.FlutterContacts.update(_applyToDevice(existing, contact));
      return;
    }
  }

  await device.FlutterContacts.create(_buildDeviceContact(contact));
}

Future<int> syncContactsBidirectional({
  required String userId,
  required List<Contact> existing,
}) async {
  final pulled = await pullDeviceContacts(userId: userId);
  final byPhone = {
    for (final c in existing) PhoneFormatter.normalize(c.phone): c,
  };
  final byNativeId = {
    for (final c in existing)
      if (c.deviceNativeId != null) c.deviceNativeId!: c,
  };

  var pushed = 0;
  for (final remote in pulled) {
    final phoneKey = PhoneFormatter.normalize(remote.phone);
    final local = byNativeId[remote.deviceNativeId] ?? byPhone[phoneKey];
    if (local != null && local.syncToDevice) {
      final newer = _pickNewer(local, remote);
      if (newer == local && local.deviceNativeId == null) {
        await pushContactToDevice(
          local.copyWith(deviceNativeId: remote.deviceNativeId),
        );
        pushed++;
      }
    }
  }

  for (final local in existing) {
    if (local.syncToDevice &&
        local.lastDeviceSyncAt == null &&
        local.deviceNativeId == null) {
      await pushContactToDevice(local);
      pushed++;
    }
  }

  return pulled.length + pushed;
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

device.Contact _buildDeviceContact(Contact contact) {
  return device.Contact(
    name: _buildName(contact),
    phones: _buildPhones(contact),
    emails: _buildEmails(contact),
    organizations: _buildOrganizations(contact),
    websites: _buildWebsites(contact),
    notes: _buildNotes(contact),
    events: _buildEvents(contact),
    addresses: _buildAddresses(contact),
  );
}

device.Contact _applyToDevice(device.Contact dc, Contact contact) {
  return dc.copyWith(
    name: _buildName(contact),
    phones: _buildPhones(contact),
    emails: _buildEmails(contact),
    organizations: _buildOrganizations(contact),
    websites: _buildWebsites(contact),
    notes: _buildNotes(contact),
    events: _buildEvents(contact),
    addresses: _buildAddresses(contact),
  );
}

device.Name _buildName(Contact contact) {
  final parts = contact.name.split(' ');
  return device.Name(
    first: contact.firstName ?? (parts.isNotEmpty ? parts.first : contact.name),
    last: contact.lastName ??
        (parts.length > 1 ? parts.sublist(1).join(' ') : null),
  );
}

List<device.Phone> _buildPhones(Contact contact) {
  final phones = <device.Phone>[
    device.Phone(number: contact.phone),
  ];
  if (contact.secondaryPhone?.isNotEmpty == true) {
    phones.add(
      device.Phone(
        number: contact.secondaryPhone!,
        label: const device.Label(device.PhoneLabel.work),
      ),
    );
  }
  return phones;
}

List<device.Email> _buildEmails(Contact contact) {
  if (contact.email?.isNotEmpty != true) return const [];
  return [device.Email(address: contact.email!)];
}

List<device.Organization> _buildOrganizations(Contact contact) {
  if (contact.company?.isNotEmpty != true &&
      contact.jobTitle?.isNotEmpty != true) {
    return const [];
  }
  return [
    device.Organization(
      name: contact.company,
      jobTitle: contact.jobTitle,
    ),
  ];
}

List<device.Website> _buildWebsites(Contact contact) {
  if (contact.website?.isNotEmpty != true) return const [];
  return [device.Website(url: contact.website!)];
}

List<device.Note> _buildNotes(Contact contact) {
  if (contact.notes?.isNotEmpty != true) return const [];
  return [device.Note(note: contact.notes!)];
}

List<device.Event> _buildEvents(Contact contact) {
  final birthday = contact.birthday;
  if (birthday == null) return const [];
  return [
    device.Event(
      year: birthday.year,
      month: birthday.month,
      day: birthday.day,
      label: const device.Label(device.EventLabel.birthday),
    ),
  ];
}

List<device.Address> _buildAddresses(Contact contact) {
  if (contact.addressLine1?.isNotEmpty != true &&
      contact.city?.isNotEmpty != true) {
    return const [];
  }
  return [
    device.Address(
      street: contact.addressLine1,
      city: contact.city,
      state: contact.state,
      postalCode: contact.postalCode,
      country: contact.country,
    ),
  ];
}

Contact _pickNewer(Contact local, Contact remote) {
  final localSync = local.lastDeviceSyncAt;
  final remoteSync = remote.lastDeviceSyncAt;
  if (localSync == null) return remote;
  if (remoteSync == null) return local;
  return remoteSync.isAfter(localSync) ? remote : local;
}

Future<void> _ensurePermission({bool write = false}) async {
  final read = await Permission.contacts.request();
  if (!read.isGranted) {
    throw Exception(
      'Contacts permission is required. Enable it in Settings, then try again.',
    );
  }
  if (write && !read.isGranted) {
    throw Exception(
      'Write contacts permission is required to sync back to your phone.',
    );
  }
}
