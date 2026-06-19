/// App-wide constants.
abstract class Constants {
  static const String appName = 'GiroCall';
  static const String tagline = 'Spin the Giro. Make the Call. Stay Connected.';

  // Supabase
  static const String supabaseUrlKey = 'SUPABASE_URL';
  static const String supabaseAnonKey = 'SUPABASE_ANON_KEY';

  // Sentry (optional — leave empty to disable)
  static const String sentryDsnKey = 'SENTRY_DSN';
  static const String sentryDsn = String.fromEnvironment(
    sentryDsnKey,
    defaultValue: '',
  );

  // Notification channel
  static const String reminderChannelId = 'girocall_daily_reminder';
  static const String reminderChannelName = 'Daily Call Reminders';
  static const String reminderChannelDescription =
      'Reminds you to spin the wheel and reconnect with people.';

  // Defaults
  static const int defaultTargetFrequencyDays = 30;
  static const int defaultDailyCallGoal = 2;
  static const int minStarRating = 1;
  static const int maxStarRating = 5;

  // Wheel
  static const int minWheelSlices = 2;
  static const int maxWheelSlices = 12;

  // Digital card / link-in-bio
  static const String appBaseUrlKey = 'APP_BASE_URL';
  static const String appBaseUrl = String.fromEnvironment(
    appBaseUrlKey,
    defaultValue: 'https://girocall.com',
  );

  /// Optional fixed redirect for Supabase auth emails during local web dev.
  /// Must match a URL in Supabase Auth → URL Configuration allow-list.
  static const String webAuthRedirectUrlKey = 'WEB_AUTH_REDIRECT_URL';
  static const String webAuthRedirectUrl = String.fromEnvironment(
    webAuthRedirectUrlKey,
    defaultValue: '',
  );
}
