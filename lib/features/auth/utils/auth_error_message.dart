/// Maps low-level Supabase auth errors to user-facing copy.
String authErrorMessage(Object error, {required bool supabaseConfigured}) {
  if (!supabaseConfigured) {
    return 'Supabase is not configured. Copy .env.example to .env, '
        'add your project URL and anon key, then run: make run';
  }

  final message = error.toString();

  if (message.contains('Failed to fetch') ||
      message.contains('dummy.supabase.co')) {
    return 'Could not reach Supabase. Check your URL and network connection.';
  }

  if (message.contains('User already registered')) {
    return 'An account with this email already exists. Try signing in.';
  }

  if (message.contains('Invalid login credentials')) {
    return 'Incorrect email or password.';
  }

  if (message.contains('Password should be at least')) {
    return 'Password must be at least 6 characters.';
  }

  return message;
}
