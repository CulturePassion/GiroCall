/// 8px grid spacing tokens (HIG + Material Design 3).
abstract class AppSpacing {
  static const double unit = 8;

  static const double xxs = unit; // 8
  static const double xs = unit * 2; // 16
  static const double sm = unit * 3; // 24
  static const double md = unit * 4; // 32
  static const double lg = unit * 5; // 40
  static const double xl = unit * 6; // 48
  static const double xxl = unit * 8; // 64

  /// Minimum interactive touch target (Apple HIG + Material).
  static const double minTouchTarget = 44;

  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 32;
}
