import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase_provider.dart';

/// Repository for storing FCM tokens per user/device.
class FcmTokenRepository {
  final SupabaseClient _client;

  const FcmTokenRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  Future<void> saveToken(String token, {String platform = 'unknown'}) async {
    final userId = _userId;
    if (userId == null) return;

    await _client.from('fcm_tokens').upsert({
      'user_id': userId,
      'token': token,
      'platform': platform,
    });
  }

  Future<void> deleteToken(String token) async {
    await _client.from('fcm_tokens').delete().eq('token', token);
  }
}

final fcmTokenRepositoryProvider = Provider<FcmTokenRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return FcmTokenRepository(client);
});
