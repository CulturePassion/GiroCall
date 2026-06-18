/// Shared visual tokens — radii, durations, touch targets.
abstract class AppTokens {
  static const double minTouchTarget = 48;
  static const double sidebarWidth = 280;
  static const double navBarHeight = 72;

  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 32;

  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 400);
  static const Duration animationSlow = Duration(milliseconds: 600);
  static const Duration wheelSpin = Duration(seconds: 3);
}
