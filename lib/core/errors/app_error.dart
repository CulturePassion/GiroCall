/// Categories used to pick UI treatment and recovery actions.
enum AppErrorCategory {
  network,
  auth,
  permission,
  validation,
  notFound,
  conflict,
  server,
  platformUnsupported,
  unknown,
}

/// Normalized, user-safe application error.
class AppError implements Exception {
  final AppErrorCategory category;
  final String userMessage;
  final String? debugMessage;
  final bool isRetryable;
  final Object? cause;

  const AppError({
    required this.category,
    required this.userMessage,
    this.debugMessage,
    this.isRetryable = false,
    this.cause,
  });

  bool get isAuth => category == AppErrorCategory.auth;

  @override
  String toString() => userMessage;
}
