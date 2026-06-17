import 'package:flutter/material.dart';

import '../app_spacing.dart';

/// Responsive padding on 8px grid.
class ScreenPadding {
  static EdgeInsets horizontal(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= 600 ? AppSpacing.md : AppSpacing.xs;
    return EdgeInsets.symmetric(horizontal: horizontal);
  }

  static EdgeInsets all(BuildContext context) {
    final h = horizontal(context).horizontal;
    return EdgeInsets.all(h);
  }

  static double bottomNavClearance(BuildContext context) =>
      88 + MediaQuery.paddingOf(context).bottom + AppSpacing.xs;
}
