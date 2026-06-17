import 'package:flutter/foundation.dart';

/// Whether the current platform can import from the device address book.
///
/// Web never supports [Permission.contacts] — use manual add + cloud sync instead.
bool get supportsDeviceContactImport => !kIsWeb;
