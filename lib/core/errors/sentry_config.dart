import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../constants.dart';

/// Whether Sentry is configured via compile-time [Constants.sentryDsn].
bool get isSentryEnabled => Constants.sentryDsn.isNotEmpty;

/// Applies shared Sentry options for GiroCall.
void configureSentryOptions(SentryFlutterOptions options) {
  // Empty DSN disables sending — sentry 8.x removed the `enabled` setter.
  options.dsn = isSentryEnabled ? Constants.sentryDsn : '';
  options.environment = kReleaseMode ? 'production' : 'development';
  options.tracesSampleRate = kReleaseMode ? 0.2 : 1.0;
  options.attachScreenshot = false;
  options.sendDefaultPii = false;
  options.beforeSend = (event, hint) {
    if (kDebugMode && !isSentryEnabled) return null;
    return event;
  };
}

/// Tags the current Sentry scope with a signed-in user id (hashed externally).
Future<void> setSentryUser(String? userId) async {
  if (!isSentryEnabled) return;

  await Sentry.configureScope((scope) {
    if (userId == null || userId.isEmpty) {
      scope.setUser(null);
      return;
    }
    scope.setUser(SentryUser(id: userId));
  });
}
