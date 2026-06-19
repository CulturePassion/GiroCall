import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/errors/error_reporter.dart';
import '../core/sync/sync_service.dart';
import '../features/notifications/providers/fcm_provider.dart';
import '../features/notifications/providers/notification_provider.dart';
import '../features/notifications/providers/settings_repository_provider.dart';

bool _firebaseInitialized = false;

/// Initializes platform services and restores persisted user preferences.
Future<void> bootstrapApp(WidgetRef ref) async {
  final notificationService = ref.read(notificationServiceProvider);
  await notificationService.initialize();

  if (Supabase.instance.client.auth.currentSession != null) {
    await _restoreUserPreferences(ref);
    await _initializeFirebaseMessaging(ref);
  }
}

/// Syncs cloud data and restores preferences after sign-in.
Future<void> onUserSignedIn(WidgetRef ref) async {
  await ref.read(syncServiceProvider).refreshAll(ref);
  await _restoreUserPreferences(ref);
  await _initializeFirebaseMessaging(ref);
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

/// Initializes Firebase + FCM when running on a mobile device with config present.
Future<void> _initializeFirebaseMessaging(WidgetRef ref) async {
  if (kIsWeb) return;

  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return;

  try {
    if (!_firebaseInitialized) {
      await Firebase.initializeApp();
      _firebaseInitialized = true;
    }
    await ref.read(fcmServiceProvider).initialize();
  } catch (e, st) {
    // Firebase config files are optional until mobile push is set up.
    ErrorReporter.log(e, st, 'FirebaseMessaging');
  }
}
