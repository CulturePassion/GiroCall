import 'package:flutter/material.dart';

import '../design/colors.dart';
import 'app_error.dart';
import 'app_error_mapper.dart';

/// Consistent SnackBars for errors, success, and info.
abstract final class AppMessenger {
  static void showError(BuildContext context, Object error) {
    final appError = mapError(error);
    _show(
      context,
      message: appError.userMessage,
      backgroundColor: AppColors.error,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.main,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message: message);
  }

  static void showAppError(BuildContext context, AppError error) {
    _show(
      context,
      message: error.userMessage,
      backgroundColor: AppColors.error,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }
}
