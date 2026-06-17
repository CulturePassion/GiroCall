/// Maps Supabase and app errors to user-friendly messages.
String supabaseErrorMessage(Object error) {
  final message = error.toString().toLowerCase();

  if (message.contains('failed to fetch') ||
      message.contains('network') ||
      message.contains('socket')) {
    return 'Could not reach the server. Check your connection and try again.';
  }

  if (message.contains('invalid login credentials') ||
      message.contains('invalid_credentials')) {
    return 'Email or password is incorrect.';
  }

  if (message.contains('user already registered') ||
      message.contains('already registered')) {
    return 'An account with this email already exists.';
  }

  if (message.contains('email not confirmed')) {
    return 'Please confirm your email before signing in.';
  }

  if (message.contains('permission.contacts') ||
      message.contains('not supported on web') ||
      message.contains('unsupported operation')) {
    return 'Phone contact import is not available on web. Add contacts manually — they sync to all your devices.';
  }

  if (message.contains('permission denied') ||
      message.contains('contacts permission')) {
    return 'Contacts permission was denied. Enable it in Settings or add contacts manually.';
  }

  if (message.contains('row-level security') ||
      message.contains('rls') ||
      message.contains('42501')) {
    return 'You do not have permission to perform this action.';
  }

  if (message.contains('duplicate') || message.contains('unique')) {
    return 'This contact already exists.';
  }

  if (message.contains('jwt') || message.contains('session')) {
    return 'Your session expired. Please sign in again.';
  }

  return 'Something went wrong. Please try again.';
}
