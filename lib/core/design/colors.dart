import 'package:flutter/material.dart';

/// GiroCall brand palette — vibrant, warm, modern and energetic.
/// All primary colors as specified for the current brand refresh.
abstract class AppColors {
  // === Brand Primary Colors (official) ===
  static const Color vibrantGreen = Color(0xFF1EB05B);
  static const Color tealDarkGreen = Color(0xFF377464);
  static const Color brightOrange = Color(0xFFF06A36);
  static const Color goldenYellowOrange = Color(0xFFF8A72F);
  static const Color softBluePurple = Color(0xFF90A2D2);
  static const Color pinkMagenta = Color(0xFFDA7CAD);

  // Semantic brand aliases (used throughout the app)
  static const Color main = vibrantGreen;
  static const Color primary = vibrantGreen;
  static const Color orange = brightOrange;
  static const Color accent = brightOrange;
  static const Color secondaryBlue = softBluePurple;

  // Additional brand accents derived from primaries
  static const Color goldenYellow = goldenYellowOrange;
  static const Color softPink = pinkMagenta;
  static const Color premiumPurple = softBluePurple;
  static const Color mintGreen = vibrantGreen;

  // Supporting / legacy mapped (kept for compatibility)
  static const Color warmBlue = softBluePurple;
  static const Color softLavender = softBluePurple;
  static const Color roseGold = pinkMagenta;
  static const Color warmGray = Color(0xFF94A3B8);
  static const Color deepPurple = tealDarkGreen;
  static const Color royalBlue = softBluePurple;
  static const Color darkBlue = tealDarkGreen;
  static const Color cadmiumOrange = brightOrange;
  static const Color persianBlue = tealDarkGreen;

  // Refined soft tints for cards, backgrounds, chips (modern & subtle)
  static const Color softGreen = Color(0xFFE6F6EC);
  static const Color softTeal = Color(0xFFE1EAE7);
  static const Color softOrange = Color(0xFFFFEDE6);
  static const Color softGold = Color(0xFFFFF4E3);
  static const Color softBlue = Color(0xFFE9ECF5);
  static const Color softPurple = Color(0xFFEBE9F3);
  static const Color softPinkTint = Color(0xFFF9E8F0);

  // Neutrals (refined for modern light/dark)
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color error = Color(0xFFEF4444);
  static const Color success = vibrantGreen;

  // Semantic shortcuts (for easy migration / legacy)
  static const Color primaryTeal = vibrantGreen;
  static const Color accentCoral = brightOrange;

  // Light theme surfaces (clean modern)
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

  // Hero / gradient screens — energetic modern using brand colors
  static const Color heroGradientStart = vibrantGreen;
  static const Color heroGradientMid = goldenYellowOrange;
  static const Color heroGradientEnd = brightOrange;

  static const Color darkHeroGradientStart = Color(0xFF0C2118);
  static const Color darkHeroGradientMid = Color(0xFF1A2F29);
  static const Color darkHeroGradientEnd = Color(0xFF2C211C);

  /// Wheel slice palette — vibrant, balanced cycle using the 6 brand colors.
  /// Provides modern, energetic and harmonious slices.
  static const List<Color> wheelSliceColors = [
    vibrantGreen,
    brightOrange,
    goldenYellowOrange,
    pinkMagenta,
    softBluePurple,
    tealDarkGreen,
    Color(0xFF2E9F52), // vibrant green variant
    Color(0xFFE85E2B), // bright orange variant
    Color(0xFFE89C2E), // golden variant
    Color(0xFFC56A9E), // pink variant
    softBluePurple,
    tealDarkGreen,
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
