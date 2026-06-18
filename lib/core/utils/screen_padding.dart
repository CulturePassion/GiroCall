import 'package:flutter/material.dart';

import '../design/spacing.dart';
import 'responsive_layout.dart';

/// Responsive padding on 8px grid.
class ScreenPadding {
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

  static double bottomNavClearance(BuildContext context) =>
      88 + MediaQuery.paddingOf(context).bottom + AppSpacing.xs;
}
