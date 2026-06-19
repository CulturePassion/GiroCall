import '../errors/app_error_mapper.dart';

/// Maps Supabase and app errors to user-friendly messages.
String supabaseErrorMessage(Object error) => mapError(error).userMessage;
