import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'app_error_mapper.dart';

/// Central logging for errors — hook Sentry/Crashlytics here later.
abstract final class ErrorReporter {
  static final Logger _log = Logger('GiroCall');

  static void log(
    Object error, [
    StackTrace? stackTrace,
    String? context,
  ]) {
    final appError = mapError(error);
    final prefix = context == null ? '' : '[$context] ';

    if (kDebugMode) {
      debugPrint(
        '${prefix}ERROR ${appError.category.name}: '
        '${appError.debugMessage ?? appError.userMessage}',
      );
      if (stackTrace != null) {
        debugPrintStack(stackTrace: stackTrace, label: prefix);
      }
    }

    _log.warning(
      '$prefix${appError.category.name}: ${appError.debugMessage ?? error}',
      error,
      stackTrace,
    );
  }
}
