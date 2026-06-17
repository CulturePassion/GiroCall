import '../../../shared/models/contact.dart';

/// Device contact import is not available on web.
Future<List<Contact>> importDeviceContacts({required String userId}) async {
  throw UnsupportedError(
    'Device contact import is not supported on web. '
    'Add contacts manually — they sync across all your devices.',
  );
}

bool get supportsDeviceContactImport => false;
