/// Spacing scale. Every gap and inset in the app is one of these steps, which
/// is what keeps vertical rhythm consistent across screens built at different
/// times by different people.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Corner radii.
abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

/// Motion durations. Kept short: this is a data tool, not a showcase.
abstract final class AppDurations {
  static const Duration instant = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 600);
}

/// Layout breakpoints, expressed as the minimum width of each class.
abstract final class AppBreakpoints {
  static const double tablet = 720;
  static const double desktop = 1100;

  /// Content wider than this becomes hard to scan, so pages centre themselves.
  static const double maxContentWidth = 1180;

  /// Minimum tap target, per WCAG 2.5.5 / Material accessibility guidance.
  static const double minTapTarget = 48;
}
