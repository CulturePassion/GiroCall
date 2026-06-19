import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'spacing.dart';
import 'tokens.dart';

/// GiroCall Premium Playful Material 3 design system.
class AppTheme {
  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        background: AppColors.background,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        divider: AppColors.divider,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        onSurfaceVariant: AppColors.darkTextSecondary,
        divider: AppColors.darkDivider,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color divider,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.vibrantGreen,
      onPrimary: Colors.white,
      secondary: AppColors.brightOrange,
      onSecondary: Colors.white,
      tertiary: AppColors.pinkMagenta,
      onTertiary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest:
          isDark ? AppColors.darkSurface : AppColors.grey100,
      onSurfaceVariant: onSurfaceVariant,
    );

    final textTheme = _textTheme(onSurface, onSurfaceVariant);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      dividerColor: divider,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.vibrantGreen,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 8,
        backgroundColor: surface,
        indicatorColor: AppColors.vibrantGreen,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.vibrantGreen : onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.vibrantGreen : onSurfaceVariant,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brightOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.brightOrange.withValues(alpha: 0.28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.md,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white : AppColors.vibrantGreen,
          side: BorderSide(
            color: isDark ? AppColors.softBluePurple : AppColors.vibrantGreen,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.md,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF374151) : AppColors.grey100,
        labelStyle: TextStyle(
          color: onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.vibrantGreen,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: onSurfaceVariant.withValues(alpha: 0.85),
          fontSize: 16,
        ),
        prefixIconColor: onSurfaceVariant,
        suffixIconColor: onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.grey300,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.grey300,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.vibrantGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.vibrantGreen,
        selectionColor: AppColors.vibrantGreen.withValues(alpha: 0.25),
        selectionHandleColor: AppColors.vibrantGreen,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        color: surface,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          side: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.grey200,
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.vibrantGreen,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.brightOrange,
        foregroundColor: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        elevation: 24,
      ),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: primary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primary,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: primary,
          letterSpacing: -0.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: primary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: secondary,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: secondary,
          height: 1.3,
        ),
      );
}
