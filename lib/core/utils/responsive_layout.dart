import 'package:flutter/material.dart';

import '../design/spacing.dart';

/// Breakpoints and max-widths for mobile-first + web-friendly layouts.
abstract class ResponsiveLayout {
  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 900;
  static const double wideBreakpoint = 1200;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopBreakpoint;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wideBreakpoint;

  /// Auth / narrow forms — optimal ~400–480px on web.
  static double formMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= wideBreakpoint) return 440;
    if (width >= desktopBreakpoint) return 460;
    if (width >= tabletBreakpoint) return 480;
    return width;
  }

  /// Compact phones and narrow mobile-browser widths.
  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 360;

  /// Use icon-only bottom nav labels on tighter mobile/tablet widths.
  static bool useCompactBottomNav(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width < desktopBreakpoint && width < 720;
  }

  /// Standard content pages (lists, settings).
  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= wideBreakpoint) return 960;
    if (width >= desktopBreakpoint) return 840;
    if (width >= tabletBreakpoint) return 720;
    return width;
  }

  /// Horizontal padding that scales with viewport.
  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= wideBreakpoint) return AppSpacing.lg;
    if (width >= desktopBreakpoint) return AppSpacing.md;
    if (width >= tabletBreakpoint) return AppSpacing.sm;
    return AppSpacing.xs;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    final h = horizontalPadding(context);
    return EdgeInsets.symmetric(horizontal: h, vertical: AppSpacing.xs);
  }
}
