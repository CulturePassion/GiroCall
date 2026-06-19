import 'package:flutter/foundation.dart';

import 'error_reporter.dart';

/// Installs global Flutter/Dart error handlers.
abstract final class ErrorHooks {
  static void install() {
    FlutterError.onError = (details) {
      ErrorReporter.log(
        details.exception,
        details.stack,
        'FlutterError',
      );
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      ErrorReporter.log(error, stack, 'PlatformDispatcher');
      return true;
    };
  }
}
