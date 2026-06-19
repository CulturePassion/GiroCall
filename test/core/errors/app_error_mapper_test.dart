import 'package:flutter_test/flutter_test.dart';
import 'package:girocall/core/errors/app_error.dart';
import 'package:girocall/core/errors/app_error_mapper.dart';

void main() {
  group('mapError', () {
    test('maps network failures as retryable', () {
      final error = mapError(Exception('Failed to fetch'));
      expect(error.category, AppErrorCategory.network);
      expect(error.isRetryable, isTrue);
    });

    test('maps unconfigured supabase', () {
      final error = mapError(
        Exception('anything'),
        context: const AppErrorContext(supabaseConfigured: false),
      );
      expect(error.userMessage, contains('Supabase is not configured'));
    });

    test('maps duplicate contacts as conflict', () {
      final error = mapError(Exception('duplicate key value'));
      expect(error.category, AppErrorCategory.conflict);
    });

    test('returns AppError unchanged', () {
      const original = AppError(
        category: AppErrorCategory.validation,
        userMessage: 'Name is required.',
      );
      expect(mapError(original), same(original));
    });
  });
}
