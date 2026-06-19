import 'package:flutter_test/flutter_test.dart';
import 'package:girocall/features/auth/models/sign_up_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('isDuplicateSignupUser', () {
    test('returns false when identities are present', () {
      final user = User.fromJson({
        'id': 'user-1',
        'aud': 'authenticated',
        'created_at': '2026-01-01T00:00:00Z',
        'identities': [
          {
            'id': 'identity-1',
            'user_id': 'user-1',
            'identity_id': 'identity-1',
            'provider': 'email',
            'created_at': '2026-01-01T00:00:00Z',
            'last_sign_in_at': '2026-01-01T00:00:00Z',
          },
        ],
      });

      expect(isDuplicateSignupUser(user), isFalse);
    });

    test('returns true when identities are empty', () {
      final user = User.fromJson({
        'id': 'user-1',
        'aud': 'authenticated',
        'created_at': '2026-01-01T00:00:00Z',
        'identities': [],
      });

      expect(isDuplicateSignupUser(user), isTrue);
    });

    test('returns false when user is null', () {
      expect(isDuplicateSignupUser(null), isFalse);
    });
  });
}
