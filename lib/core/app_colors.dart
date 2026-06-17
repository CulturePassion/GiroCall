import 'package:flutter/material.dart';

/// GiroCall palette — blue & orange brand system.
///
/// Main: [#00ADEF] · 60% light surfaces · 30% blues · 10% oranges
abstract class AppColors {
  // Primary
  static const Color main = Color(0xFF00ADEF);

  // Blues
  static const Color blue = Color(0xFF0088CC);
  static const Color pureBlue = Color(0xFF0000FF);
  static const Color persianBlue = Color(0xFF1A37B8);
  static const Color royalBlue = Color(0xFF2563EB);

  // Oranges
  static const Color orange = Color(0xFFFF5733);
  static const Color pureOrange = Color(0xFFFFA500);
  static const Color cadmiumOrange = Color(0xFFF7882E);
  static const Color sunsetOrange = Color(0xFFFE6B35);

  // Tints & shades (derived from main)
  static const Color mainLight = Color(0xFF5CC8F5);
  static const Color mainSoft = Color(0xFFB3E5FA);
  static const Color mainPale = Color(0xFFE8F7FD);
  static const Color mainDeep = Color(0xFF0088CC);

  // Semantic aliases (kept for existing call sites)
  static const Color primaryTeal = main;
  static const Color accentCoral = orange;
  static const Color accentGold = pureOrange;
  static const Color secondaryBlue = blue;

  // Legacy palette names → new colors
  static const Color paletteCoral = orange;
  static const Color paletteCoralDeep = sunsetOrange;
  static const Color paletteTeal = main;
  static const Color paletteTealLight = mainLight;
  static const Color paletteTealMuted = blue;
  static const Color paletteGold = cadmiumOrange;
  static const Color paletteGoldDeep = pureOrange;
  static const Color paletteMint = mainSoft;
  static const Color paletteMintSoft = mainPale;
  static const Color paletteSage = royalBlue;
  static const Color paletteCream = mainPale;
  static const Color paletteCreamDeep = Color(0xFFD6EEF9);

  static const Color error = Color(0xFFDC4E4E);
  static const Color success = Color(0xFF22A06B);

  // Light theme (60-30-10)
  static const Color background = mainPale;
  static const Color surface = Color(0xFFFAFEFF);
  static const Color surfaceVariant = mainSoft;
  static const Color textPrimary = Color(0xFF0A2540);
  static const Color textSecondary = Color(0xFF3D5A73);
  static const Color divider = Color(0xFFC5E4F3);
  static const Color navBarBackground = Color(0xE6FFFFFF);

  // Dark theme
  static const Color darkBackground = Color(0xFF0A1628);
  static const Color darkSurface = Color(0xFF122240);
  static const Color darkSurfaceVariant = Color(0xFF1A3050);
  static const Color darkTextPrimary = Color(0xFFF0FAFE);
  static const Color darkTextSecondary = Color(0xFF8ECAE6);
  static const Color darkDivider = Color(0xFF2A4A6E);
  static const Color darkNavBarBackground = Color(0xCC122240);

  /// Wheel slice palette — alternates blues and oranges.
  static const List<Color> wheelSliceColors = [
    main,
    orange,
    blue,
    sunsetOrange,
    royalBlue,
    cadmiumOrange,
    persianBlue,
    pureOrange,
    mainLight,
    pureBlue,
  ];

  static Color onSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color onSurfaceVariant(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
