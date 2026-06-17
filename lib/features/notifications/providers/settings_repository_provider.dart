import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase_provider.dart';
import '../../../shared/models/user_settings.dart';

/// Repository for user settings.
class SettingsRepository {
  final SupabaseClient _client;

  const SettingsRepository(this._client);

  String? get userId => _client.auth.currentUser?.id;

  String? get _userId => userId;

  Future<UserSettings?> fetchSettings() async {
    final userId = _userId;
    if (userId == null) return null;

    final response = await _client
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserSettings.fromJson(response);
  }

  Future<UserSettings> upsertSettings(UserSettings settings) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    final payload = settings.copyWith(userId: userId).toJson();
    final response =
        await _client.from('user_settings').upsert(payload).select().single();

    return UserSettings.fromJson(response);
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SettingsRepository(client);
});

/// Cached user settings for stats and notification screens.
final userSettingsProvider = FutureProvider<UserSettings?>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.fetchSettings();
});
