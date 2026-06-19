import 'package:flutter_test/flutter_test.dart';
import 'package:girocall/core/utils/auth_redirect.dart';

void main() {
  test('authRedirectUrl falls back to app base URL when unset', () {
    expect(authRedirectUrl(), 'https://girocall.com');
  });
}
