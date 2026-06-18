import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvatarUploadService {
  final SupabaseClient _client;

  const AvatarUploadService(this._client);

  static const String bucket = 'avatars';
  static const int maxBytes = 5 * 1024 * 1024;

  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Sign in to upload a profile photo.');
    }
    if (bytes.length > maxBytes) {
      throw Exception('Image must be 5 MB or smaller.');
    }

    final ext = _extensionForMime(mimeType);
    final path = '$userId/avatar-${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: mimeType,
            upsert: true,
          ),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  String _extensionForMime(String mime) {
    switch (mime) {
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/gif':
        return 'gif';
      default:
        return 'jpg';
    }
  }
}
