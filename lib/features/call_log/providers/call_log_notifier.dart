import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../shared/models/call_log.dart';
import '../../contacts/providers/contact_repository_provider.dart';
import 'call_log_provider.dart';

/// Manages call log state with Supabase realtime sync.
class CallLogNotifier extends StateNotifier<AsyncValue<List<CallLog>>> {
  final CallLogRepository _repository;
  final Ref _ref;

  CallLogNotifier(this._repository, this._ref)
      : super(const AsyncValue.loading());

  void setLogs(List<CallLog> logs) {
    state = AsyncValue.data(logs);
  }

  void setError(Object error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }

  Future<void> loadLogs() async {
    if (_repository.userId == null) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final logs = await _repository.fetchLogs();
      state = AsyncValue.data(logs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addLog(CallLog log) async {
    try {
      final created = await _repository.addLog(log);
      state = AsyncValue.data([created, ...state.value ?? []]);

      final contactRepo = _ref.read(contactRepositoryProvider);
      final contact = await contactRepo.getContact(log.contactId);
      if (contact != null) {
        await contactRepo.updateContact(
          contact.copyWith(lastCalledAt: log.calledAt),
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final callLogNotifierProvider =
    StateNotifierProvider<CallLogNotifier, AsyncValue<List<CallLog>>>((ref) {
  final repo = ref.watch(callLogRepositoryProvider);
  final notifier = CallLogNotifier(repo, ref);

  if (repo.userId != null) {
    unawaited(notifier.loadLogs());
  } else {
    notifier.setLogs([]);
  }

  final subscription = repo.watchLogs().listen(
        notifier.setLogs,
        onError: notifier.setError,
      );
  ref.onDispose(subscription.cancel);

  return notifier;
});
