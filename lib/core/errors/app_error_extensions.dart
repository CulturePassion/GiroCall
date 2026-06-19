import 'app_error.dart';
import 'app_error_mapper.dart';

extension AppErrorMapping on Object {
  AppError toAppError({bool supabaseConfigured = true}) {
    return mapError(
      this,
      context: AppErrorContext(supabaseConfigured: supabaseConfigured),
    );
  }
}
