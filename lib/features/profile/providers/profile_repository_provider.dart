import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase_provider.dart';
import '../../../shared/models/user_profile.dart';

class ProfileRepository {
  final SupabaseClient _client;

  const ProfileRepository(this._client);

  String? get userId => _client.auth.currentUser?.id;

  Future<UserProfile?> fetchOwnProfile() async {
    final userId = this.userId;
    if (userId == null) return null;

    final response = await _client
        .from('user_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  Future<UserProfile> ensureProfile() async {
    final userId = this.userId;
    if (userId == null) throw Exception('User not authenticated');

    final existing = await fetchOwnProfile();
    if (existing != null) return existing;

    final email = _client.auth.currentUser?.email ?? '';
    final slug = _generateSlug(email, userId);

    final payload = {
      'user_id': userId,
      'slug': slug,
      'display_name':
          email.isNotEmpty ? email.split('@').first : 'GiroCall User',
      if (email.isNotEmpty) 'email': email,
      'is_public': false,
    };

    final response =
        await _client.from('user_profiles').insert(payload).select().single();

    return UserProfile.fromJson(response);
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    final userId = this.userId;
    if (userId == null) throw Exception('User not authenticated');

    _validateProfile(profile);

    final response = await _client
        .from('user_profiles')
        .update(profile.toUpdateJson())
        .eq('user_id', userId)
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

  Future<UserProfile?> fetchPublicProfile(String slug) async {
    final response = await _client
        .from('user_profiles')
        .select()
        .eq('slug', slug)
        .eq('is_public', true)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  Future<bool> isSlugAvailable(String slug, {String? excludeUserId}) async {
    final query =
        _client.from('user_profiles').select('user_id').eq('slug', slug);
    final rows = await query;
    for (final row in rows as List) {
      final ownerId = row['user_id'] as String;
      if (excludeUserId == null || ownerId != excludeUserId) return false;
    }
    return true;
  }

  void _validateProfile(UserProfile profile) {
    final name = profile.displayName.trim();
    if (name.isEmpty) {
      throw ArgumentError('Display name is required');
    }
    final slug = profile.slug.trim().toLowerCase();
    if (!RegExp(r'^[a-z0-9][a-z0-9-]{2,29}$').hasMatch(slug)) {
      throw ArgumentError(
        'Username must be 3–30 characters: lowercase letters, numbers, hyphens.',
      );
    }
  }

  String _generateSlug(String email, String userId) {
    var base = email.split('@').first.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9]'),
          '-',
        );
    if (base.length < 3) {
      base = 'user-${userId.substring(0, 8)}';
    }
    return base;
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProfileRepository(client);
});
