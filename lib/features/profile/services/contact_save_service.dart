import 'dart:convert';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

import '../../../core/utils/vcard_builder.dart';
import '../../../shared/models/user_profile.dart';

/// Shares or saves a digital business card as a vCard contact file.
class ContactSaveService {
  const ContactSaveService();

  Future<void> saveProfileContact(UserProfile profile) async {
    final vcard = VCardBuilder.fromProfile(profile);
    final filename = '${profile.slug}.vcf';

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(utf8.encode(vcard)),
            name: filename,
            mimeType: 'text/vcard',
          ),
        ],
        subject: profile.displayName,
        text: 'Save ${profile.displayName} to your contacts',
      ),
    );
  }
}

final contactSaveServiceProvider = const ContactSaveService();
