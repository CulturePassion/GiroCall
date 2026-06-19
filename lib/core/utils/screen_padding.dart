import 'package:flutter/material.dart';

import '../design/spacing.dart';
import '../design/tokens.dart';
import 'responsive_layout.dart';

/// Responsive padding on 8px grid.
class ScreenPadding {
  static bool usesBottomNav(BuildContext context) =>
      !ResponsiveLayout.isDesktop(context);

  static EdgeInsets horizontal(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: ResponsiveLayout.horizontalPadding(context),
    );
  }

  static EdgeInsets all(BuildContext context) {
    final h = ResponsiveLayout.horizontalPadding(context);
    return EdgeInsets.symmetric(horizontal: h, vertical: AppSpacing.xs);
  }

  static EdgeInsets contactsPane(BuildContext context) {
    final h = ResponsiveLayout.horizontalPadding(context);
    return EdgeInsets.fromLTRB(h, AppSpacing.xs, h, AppSpacing.sm);
  }

  static double bottomNavClearance(BuildContext context) {
    if (!usesBottomNav(context)) {
      return MediaQuery.paddingOf(context).bottom + AppSpacing.sm;
    }
    return AppTokens.navBarHeight +
        MediaQuery.paddingOf(context).bottom +
        AppSpacing.sm;
  }

  /// Extra space when a FAB sits above the bottom nav.
  static double fabClearance(BuildContext context) =>
      bottomNavClearance(context) + AppTokens.minTouchTarget + AppSpacing.sm;

  /// Bottom inset for scrollable shell tab content.
  static EdgeInsets scrollBottom(BuildContext context,
      {bool includeFab = false}) {
    final bottom =
        includeFab ? fabClearance(context) : bottomNavClearance(context);
    return EdgeInsets.only(bottom: bottom);
  }
}
