import 'package:supabase_flutter/supabase_flutter.dart';

/// Outcome of a Supabase email/password sign-up attempt.
class SignUpResult {
  final User user;
  final bool needsEmailConfirmation;

  const SignUpResult({
    required this.user,
    required this.needsEmailConfirmation,
  });
}

/// Supabase returns an empty identities list for duplicate sign-ups when
/// email confirmations are enabled (anti-enumeration behavior).
bool isDuplicateSignupUser(User? user) {
  final identities = user?.identities;
  return identities != null && identities.isEmpty;
}
