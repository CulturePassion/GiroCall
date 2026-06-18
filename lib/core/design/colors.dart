import 'package:flutter/material.dart';

/// GiroCall brand palette — warm, kind, playful, and premium.
abstract class AppColors {
  // Brand (AGENTS.md canonical)
  static const Color main = Color(0xFF0D9488);
  static const Color orange = Color(0xFFF97316);
  static const Color secondaryBlue = Color(0xFF3B82F6);

  // Playful accents
  static const Color premiumPurple = Color(0xFF8B5CF6);
  static const Color warmBlue = Color(0xFF60A5FA);
  static const Color softPink = Color(0xFFFF9CB3);
  static const Color goldenYellow = Color(0xFFFFD93D);
  static const Color softLavender = Color(0xFFC4B5FD);
  static const Color mintGreen = Color(0xFF6EE7B7);
  static const Color roseGold = Color(0xFFFBCFE8);
  static const Color warmGray = Color(0xFF94A3B8);

  // Supporting accents
  static const Color deepPurple = Color(0xFF4C1D95);
  static const Color royalBlue = Color(0xFF2563EB);
  static const Color darkBlue = Color(0xFF1E3A8A);
  static const Color cadmiumOrange = Color(0xFFFF9500);
  static const Color persianBlue = Color(0xFF082F49);

  // Soft tints
  static const Color softBlue = Color(0xFFE0F2FE);
  static const Color softOrange = Color(0xFFFFF7ED);
  static const Color softTeal = Color(0xFFCCFBF1);
  static const Color softPurple = Color(0xFFEDE9FE);
  static const Color softPinkTint = Color(0xFFFFF1F2);

  // Neutrals
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);

  // Semantic shortcuts (widely used across features)
  static const Color primaryTeal = main;
  static const Color accentCoral = orange;

  // Light theme surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color navBarBackground = Colors.white;

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkDivider = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkNavBarBackground = Color(0xFF1E293B);

  // Hero / gradient screens
  static const Color heroGradientStart = Color(0xFF0D9488);
  static const Color heroGradientMid = Color(0xFF2DD4BF);
  static const Color heroGradientEnd = Color(0xFFF97316);

  /// Wheel slice palette — rainbow spectrum from brand wheel art.
  static const List<Color> wheelSliceColors = [
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFFFB8C00),
    Color(0xFFFDD835),
    Color(0xFF43A047),
    Color(0xFF8E24AA),
    Color(0xFF00ACC1),
    Color(0xFFD81B60),
    Color(0xFF0D9488),
    Color(0xFF5E35B1),
    Color(0xFFFF7043),
    Color(0xFF26A69A),
  ];

  static Color onSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color onSurfaceVariant(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color pageBackground(BuildContext context) =>
      isDark(context) ? darkBackground : background;

  static Color cardSurface(BuildContext context) =>
      isDark(context) ? darkSurface : surface;

  static Color textMuted(BuildContext context) =>
      isDark(context) ? darkTextSecondary : textSecondary;
}