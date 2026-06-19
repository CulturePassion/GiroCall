import 'dart:convert';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

import '../../../shared/models/user_profile.dart';

Future<void> shareProfileVcardFile(
  UserProfile profile,
  String vcard,
) async {
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
