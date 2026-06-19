import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_error.dart';

/// Context for tailoring mapped messages.
class AppErrorContext {
  final bool supabaseConfigured;

  const AppErrorContext({this.supabaseConfigured = true});
}

/// Maps any thrown value to a consistent [AppError].
AppError mapError(
  Object error, {
  AppErrorContext context = const AppErrorContext(),
}) {
  if (error is AppError) return error;

  if (error is AuthException) {
    return _mapAuthException(error, context);
  }

  if (error is PostgrestException) {
    return _mapPostgrestException(error);
  }

  if (error is UnsupportedError) {
    return AppError(
      category: AppErrorCategory.platformUnsupported,
      userMessage: error.message ??
          'This feature is not available on this device. Try the mobile app '
              'or add information manually.',
      debugMessage: error.toString(),
      cause: error,
    );
  }

  return _mapStringHeuristics(error, context);
}

AppError _mapAuthException(AuthException error, AppErrorContext context) {
  if (!context.supabaseConfigured) {
    return const AppError(
      category: AppErrorCategory.server,
      userMessage: 'Supabase is not configured. Copy .env.example to .env, '
          'add your project URL and anon key, then run: make run',
      isRetryable: false,
    );
  }

  final code = error.code?.toLowerCase() ?? '';
  final message = error.message.toLowerCase();

  if (message.contains('invalid login credentials') ||
      code.contains('invalid_credentials')) {
    return const AppError(
      category: AppErrorCategory.auth,
      userMessage: 'Incorrect email or password.',
      cause: null,
    );
  }

  if (message.contains('user already registered') ||
      code.contains('user_already_exists')) {
    return const AppError(
      category: AppErrorCategory.conflict,
      userMessage: 'An account with this email already exists. Try signing in.',
    );
  }

  if (message.contains('password should be at least')) {
    return const AppError(
      category: AppErrorCategory.validation,
      userMessage: 'Password must be at least 6 characters.',
    );
  }

  if (message.contains('email not confirmed')) {
    return const AppError(
      category: AppErrorCategory.auth,
      userMessage: 'Please confirm your email before signing in.',
    );
  }

  if (message.contains('invalid api key')) {
    return const AppError(
      category: AppErrorCategory.server,
      userMessage: 'Invalid Supabase API key. Open your project dashboard → '
          'Project Settings → API, copy the anon key into .env as '
          'SUPABASE_ANON_KEY, then restart with: make run',
    );
  }

  if (message.contains('jwt') || message.contains('session')) {
    return const AppError(
      category: AppErrorCategory.auth,
      userMessage: 'Your session expired. Please sign in again.',
      isRetryable: false,
    );
  }

  return AppError(
    category: AppErrorCategory.unknown,
    userMessage: error.message,
    debugMessage: error.toString(),
    cause: error,
  );
}

AppError _mapPostgrestException(PostgrestException error) {
  final message = error.message.toLowerCase();
  final code = error.code?.toLowerCase() ?? '';

  if (code == '42501' ||
      message.contains('row-level security') ||
      message.contains('permission denied')) {
    return const AppError(
      category: AppErrorCategory.auth,
      userMessage: 'You do not have permission to perform this action.',
    );
  }

  if (message.contains('duplicate') ||
      message.contains('unique') ||
      code.contains('23505')) {
    return const AppError(
      category: AppErrorCategory.conflict,
      userMessage: 'This contact already exists.',
    );
  }

  if (code == 'PGRST116' || message.contains('0 rows')) {
    return const AppError(
      category: AppErrorCategory.notFound,
      userMessage: 'We could not find what you were looking for.',
    );
  }

  return AppError(
    category: AppErrorCategory.server,
    userMessage: 'Something went wrong on our end. Please try again.',
    debugMessage: error.toString(),
    isRetryable: true,
    cause: error,
  );
}

AppError _mapStringHeuristics(Object error, AppErrorContext context) {
  if (!context.supabaseConfigured) {
    return const AppError(
      category: AppErrorCategory.server,
      userMessage: 'Supabase is not configured. Copy .env.example to .env, '
          'add your project URL and anon key, then run: make run',
    );
  }

  final message = error.toString().toLowerCase();

  if (message.contains('failed to fetch') ||
      message.contains('dummy.supabase.co') ||
      message.contains('network') ||
      message.contains('socket') ||
      message.contains('connection')) {
    return const AppError(
      category: AppErrorCategory.network,
      userMessage: 'Could not reach GiroCall right now. Check your connection '
          'and try again.',
      isRetryable: true,
    );
  }

  if (message.contains('invalid login credentials') ||
      message.contains('invalid_credentials')) {
    return const AppError(
      category: AppErrorCategory.auth,
      userMessage: 'Email or password is incorrect.',
    );
  }

  if (message.contains('user already registered') ||
      message.contains('already registered')) {
    return const AppError(
      category: AppErrorCategory.conflict,
      userMessage: 'An account with this email already exists.',
    );
  }

  if (message.contains('email not confirmed')) {
    return const AppError(
      category: AppErrorCategory.auth,
      userMessage: 'Please confirm your email before signing in.',
    );
  }

  if (message.contains('permission.contacts') ||
      message.contains('not supported on web') ||
      message.contains('unsupported operation') ||
      message.contains('device contact import is not supported')) {
    return const AppError(
      category: AppErrorCategory.platformUnsupported,
      userMessage: 'Phone contact import is not available on web. Add contacts '
          'manually — they sync to all your devices.',
    );
  }

  if (message.contains('permission denied') ||
      message.contains('contacts permission')) {
    return const AppError(
      category: AppErrorCategory.permission,
      userMessage:
          'Contacts permission was denied. Enable it in Settings or add '
          'contacts manually.',
    );
  }

  if (message.contains('row-level security') ||
      message.contains('rls') ||
      message.contains('42501')) {
    return const AppError(
      category: AppErrorCategory.auth,
      userMessage: 'You do not have permission to perform this action.',
    );
  }

  if (message.contains('duplicate') || message.contains('unique')) {
    return const AppError(
      category: AppErrorCategory.conflict,
      userMessage: 'This contact already exists.',
    );
  }

  if (message.contains('jwt') ||
      message.contains('session expired') ||
      message.contains('not authenticated')) {
    return const AppError(
      category: AppErrorCategory.auth,
      userMessage: 'Your session expired. Please sign in again.',
    );
  }

  if (message.contains('not found') ||
      message.contains('no contacts with valid phone')) {
    return AppError(
      category: AppErrorCategory.notFound,
      userMessage: error.toString().replaceFirst('Exception: ', ''),
      debugMessage: error.toString(),
      cause: error,
    );
  }

  return AppError(
    category: AppErrorCategory.unknown,
    userMessage: 'Something went wrong. Please try again.',
    debugMessage: error.toString(),
    isRetryable: true,
    cause: error,
  );
}

/// Logs and rethrows as [AppError] — for notifier mutations.
Never rethrowAsAppError(Object error, StackTrace stackTrace) {
  throw mapError(error);
}
