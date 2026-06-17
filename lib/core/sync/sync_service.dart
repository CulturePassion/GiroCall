import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/call_log/providers/call_log_notifier.dart';
import '../../features/contacts/providers/contacts_notifier.dart';
import '../../features/notifications/providers/settings_repository_provider.dart';

/// Refreshes Supabase-backed data across iOS, Android, and web.
class SyncService {
  const SyncService();

  Future<void> refreshAll(WidgetRef ref) async {
    await Future.wait([
      ref.read(contactsNotifierProvider.notifier).loadContacts(),
      ref.read(callLogNotifierProvider.notifier).loadLogs(),
    ]);
    ref.invalidate(userSettingsProvider);
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return const SyncService();
});
