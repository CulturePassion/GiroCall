import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/errors/app_error_mapper.dart';
import '../../../core/errors/error_reporter.dart';
import '../../../shared/models/user_profile.dart';
import 'profile_repository_provider.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadProfile() async {
    if (_repository.userId == null) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final profile = await _repository.ensureProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<UserProfile> saveProfile(UserProfile profile) async {
    try {
      final saved = await _repository.updateProfile(profile);
      state = AsyncValue.data(saved);
      return saved;
    } catch (e, st) {
      ErrorReporter.log(e, st, 'saveProfile');
      rethrowAsAppError(e, st);
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  final notifier = ProfileNotifier(repo);
  if (repo.userId != null) {
    notifier.loadProfile();
  } else {
    notifier.clear();
  }
  return notifier;
});

final publicProfileProvider =
    FutureProvider.family<UserProfile?, String>((ref, slug) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchPublicProfile(slug);
});
