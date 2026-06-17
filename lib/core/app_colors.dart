import 'package:flutter/material.dart';

/// GiroCall palette — 60-30-10 rule from brand tile artwork.
///
/// 60% dominant: [paletteCream] surfaces & backgrounds
/// 30% secondary: [paletteTeal] navigation, cards, structure
/// 10% accent:    [paletteCoral] + [paletteGold] CTAs & highlights
abstract class AppColors {
  // Palette (reference: Downloads tile artwork)
  static const Color paletteCoral = Color(0xFFE07A5F);
  static const Color paletteCoralDeep = Color(0xFFC96A52);
  static const Color paletteTeal = Color(0xFF2D6A6A);
  static const Color paletteTealLight = Color(0xFF5BA3A3);
  static const Color paletteTealMuted = Color(0xFF3D8B8B);
  static const Color paletteGold = Color(0xFFD4A84B);
  static const Color paletteGoldDeep = Color(0xFFC99B3A);
  static const Color paletteMint = Color(0xFFA8D4D4);
  static const Color paletteMintSoft = Color(0xFFD4EBEB);
  static const Color paletteSage = Color(0xFF6B7B6E);
  static const Color paletteCream = Color(0xFFF5F0EA);
  static const Color paletteCreamDeep = Color(0xFFEDE6DC);

  // Semantic aliases
  static const Color primaryTeal = paletteTeal;
  static const Color accentCoral = paletteCoral;
  static const Color accentGold = paletteGold;
  static const Color secondaryBlue = paletteTealLight;

  static const Color error = Color(0xFFDC4E4E);
  static const Color success = Color(0xFF3D9A6A);

  // Light theme (60-30-10)
  static const Color background = paletteCream;
  static const Color surface = Color(0xFFFFFFF5);
  static const Color surfaceVariant = paletteMintSoft;
  static const Color textPrimary = Color(0xFF1E3333);
  static const Color textSecondary = Color(0xFF4A5E5E);
  static const Color divider = Color(0xFFD4E0E0);
  static const Color navBarBackground = Color(0xE6FFFFFF);

  // Dark theme
  static const Color darkBackground = Color(0xFF1A2E2E);
  static const Color darkSurface = Color(0xFF243D3D);
  static const Color darkSurfaceVariant = Color(0xFF2F4F4F);
  static const Color darkTextPrimary = Color(0xFFF5F0EA);
  static const Color darkTextSecondary = Color(0xFFA8C4C4);
  static const Color darkDivider = Color(0xFF3D5C5C);
  static const Color darkNavBarBackground = Color(0xCC243D3D);

  /// Wheel slice palette — cycles tile colors from brand artwork.
  static const List<Color> wheelSliceColors = [
    paletteCoral,
    paletteTealMuted,
    paletteGold,
    paletteMint,
    paletteSage,
    paletteTealLight,
    paletteCoralDeep,
    paletteGoldDeep,
  ];

  static Color onSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color onSurfaceVariant(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
