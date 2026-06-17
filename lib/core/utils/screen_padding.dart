import 'package:flutter/material.dart';

/// Responsive horizontal padding for mobile-first layouts.
class ScreenPadding {
  static EdgeInsets horizontal(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= 600 ? 32.0 : 20.0;
    return EdgeInsets.symmetric(horizontal: horizontal);
  }

  static EdgeInsets all(BuildContext context) {
    final h = horizontal(context).horizontal;
    return EdgeInsets.all(h);
  }

  static double bottomNavClearance(BuildContext context) =>
      kBottomNavigationBarHeight + MediaQuery.paddingOf(context).bottom + 16;
}
