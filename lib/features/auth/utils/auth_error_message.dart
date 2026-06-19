import '../../../core/errors/app_error_mapper.dart';

/// Maps low-level Supabase auth errors to user-facing copy.
String authErrorMessage(Object error, {required bool supabaseConfigured}) {
  return mapError(
    error,
    context: AppErrorContext(supabaseConfigured: supabaseConfigured),
  ).userMessage;
}
