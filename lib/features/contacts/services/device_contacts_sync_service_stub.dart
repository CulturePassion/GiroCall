import '../../../shared/models/contact.dart';

bool get supportsDeviceContactSync => false;

Future<List<Contact>> pullDeviceContacts({required String userId}) async {
  throw UnsupportedError(
      'Device contact sync is not available on this platform.');
}

Future<void> pushContactToDevice(Contact contact) async {}

Future<int> syncContactsBidirectional({
  required String userId,
  required List<Contact> existing,
}) async {
  return 0;
}
