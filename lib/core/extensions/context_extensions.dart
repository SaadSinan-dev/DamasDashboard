import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_dimens.dart';
import '../theme/app_semantic_colors.dart';

/// Screen size classes the layout responds to.
enum ScreenSize { compact, medium, expanded }

/// Shorthands for the three lookups that otherwise appear in every build method.
///
/// These read better at call sites (`context.l10n.reportsTitle`) and, more
/// importantly, keep `Theme.of(context).extension<AppSemanticColors>()!` from
/// being repeated — and mis-typed — across dozens of widgets.
extension BuildContextX on BuildContext {
  AppL10n get l10n => AppL10n.of(this);

  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get textStyles => Theme.of(this).textTheme;

  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppSemanticColors.dark
          : AppSemanticColors.light);

  /// Current size class, derived from the shortest side so a phone in landscape
  /// is still treated as a phone.
  ScreenSize get screenSize {
    final double width = MediaQuery.sizeOf(this).width;
    if (width >= AppBreakpoints.desktop) return ScreenSize.expanded;
    if (width >= AppBreakpoints.tablet) return ScreenSize.medium;
    return ScreenSize.compact;
  }

  bool get isCompact => screenSize == ScreenSize.compact;

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
