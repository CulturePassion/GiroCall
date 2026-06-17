import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_bootstrap.dart';
import 'sync/sync_service.dart';
import '../features/notifications/providers/notification_provider.dart';
import '../features/notifications/providers/settings_repository_provider.dart';

/// Initializes platform services and restores persisted user preferences.
Future<void> bootstrapApp(WidgetRef ref) async {
  final notificationService = ref.read(notificationServiceProvider);
  await notificationService.initialize();

  if (Supabase.instance.client.auth.currentSession != null) {
    await _restoreUserPreferences(ref);
    await initializeFirebaseMessaging(ref);
  }
}

/// Syncs cloud data and restores preferences after sign-in.
Future<void> onUserSignedIn(WidgetRef ref) async {
  await ref.read(syncServiceProvider).refreshAll(ref);
  await _restoreUserPreferences(ref);
  await initializeFirebaseMessaging(ref);
}

Future<void> _restoreUserPreferences(WidgetRef ref) async {
  final notificationService = ref.read(notificationServiceProvider);
  final settings = await ref.read(settingsRepositoryProvider).fetchSettings();
  ref.invalidate(userSettingsProvider);

  final reminderTime = settings?.dailyReminderTime;
  if (reminderTime != null && notificationService.supportsLocalNotifications) {
    await notificationService.scheduleDailyReminder(reminderTime);
  }
}
