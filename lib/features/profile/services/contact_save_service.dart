import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/user_profile.dart';
import 'contact_save_service_mobile.dart'
    if (dart.library.html) 'contact_save_service_web.dart' as impl;

/// Saves or shares a digital business card as a vCard contact file.
class ContactSaveService {
  const ContactSaveService();

  Future<void> saveProfileContact(UserProfile profile) async {
    final savedToDevice = await impl.saveProfileContactToDevice(profile);
    if (!savedToDevice) {
      await impl.shareProfileVcard(profile);
    }
  }
}

final contactSaveServiceProvider = Provider<ContactSaveService>(
  (ref) => const ContactSaveService(),
);