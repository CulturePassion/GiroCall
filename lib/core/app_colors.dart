import 'package:flutter/material.dart';

/// GiroCall brand colors. Use these exact hex values throughout the app.
abstract class AppColors {
  // Brand (shared across themes)
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color accentCoral = Color(0xFFF97316);
  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);

  // Light theme
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color navBarBackground = Color(0xFFFFFFFF);

  // Dark theme
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkDivider = Color(0xFF334155);
  static const Color darkNavBarBackground = Color(0xFF1E293B);

  static Color onSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color onSurfaceVariant(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;
}
