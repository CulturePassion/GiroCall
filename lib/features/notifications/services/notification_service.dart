import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/constants.dart';

/// Schedules and cancels daily reminder notifications.
///
/// Note: On web this is a no-op because local notifications are not supported.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  NotificationService(this._plugin);

  /// Local scheduled notifications are only available on iOS and Android.
  bool get supportsLocalNotifications => !kIsWeb;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      ),
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        Constants.reminderChannelId,
        Constants.reminderChannelName,
        description: Constants.reminderChannelDescription,
        importance: Importance.high,
      ),
    );
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted =
        await androidPlugin?.requestNotificationsPermission() ?? true;

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    return androidGranted && iosGranted;
  }

  /// Schedules a daily reminder at the provided local time.
  Future<void> scheduleDailyReminder(DateTime time) async {
    if (kIsWeb) return;
    await cancelDailyReminder();

    final scheduled = _nextOccurrence(time);

    await _plugin.zonedSchedule(
      id: 0,
      title: "Who's it going to be today?",
      body: 'Spin the Giro and reconnect with someone.',
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          Constants.reminderChannelId,
          Constants.reminderChannelName,
          channelDescription: Constants.reminderChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() async {
    if (kIsWeb) return;
    await _plugin.cancel(id: 0);
  }

  /// Returns the next occurrence of [time] in the local timezone.
  tz.TZDateTime _nextOccurrence(DateTime time) {
    final location = tz.local;
    final now = tz.TZDateTime.now(location);
    var scheduled = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
