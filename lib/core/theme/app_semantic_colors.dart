import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Colors that carry meaning but have no home in Material's [ColorScheme]:
/// trend direction, warning state, and chart rendering.
///
/// Exposed as a [ThemeExtension] so widgets read them from the active theme
/// (`Theme.of(context).extension<AppSemanticColors>()`) and automatically get
/// the right values in light and dark mode.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.positive,
    required this.onPositiveContainer,
    required this.positiveContainer,
    required this.negative,
    required this.onNegativeContainer,
    required this.negativeContainer,
    required this.warning,
    required this.onWarningContainer,
    required this.warningContainer,
    required this.chartLine,
    required this.chartAreaTop,
    required this.chartAreaBottom,
    required this.chartGrid,
  });

  /// Upward trends, completed states, positive deltas.
  final Color positive;
  final Color onPositiveContainer;
  final Color positiveContainer;

  /// Downward trends and destructive emphasis.
  final Color negative;
  final Color onNegativeContainer;
  final Color negativeContainer;

  /// In-progress / attention-needed states.
  final Color warning;
  final Color onWarningContainer;
  final Color warningContainer;

  final Color chartLine;
  final Color chartAreaTop;
  final Color chartAreaBottom;
  final Color chartGrid;

  static const AppSemanticColors light = AppSemanticColors(
    positive: AppPalette.emerald700,
    onPositiveContainer: AppPalette.emerald900,
    positiveContainer: AppPalette.emerald50,
    negative: AppPalette.red600,
    onNegativeContainer: AppPalette.red900,
    negativeContainer: AppPalette.red100,
    warning: AppPalette.amber700,
    onWarningContainer: AppPalette.amber900,
    warningContainer: AppPalette.amber100,
    chartLine: AppPalette.emerald600,
    chartAreaTop: Color(0x3310B981),
    chartAreaBottom: Color(0x0010B981),
    chartGrid: AppPalette.neutral200,
  );

  static const AppSemanticColors dark = AppSemanticColors(
    positive: AppPalette.emerald400,
    onPositiveContainer: AppPalette.emerald200,
    positiveContainer: Color(0x2634D399),
    negative: AppPalette.red500,
    onNegativeContainer: AppPalette.red300,
    negativeContainer: Color(0x26EF4444),
    warning: AppPalette.amber500,
    onWarningContainer: AppPalette.amber300,
    warningContainer: Color(0x26F59E0B),
    chartLine: AppPalette.emerald400,
    chartAreaTop: Color(0x4034D399),
    chartAreaBottom: Color(0x0034D399),
    chartGrid: Color(0xFF1D3A30),
  );

  @override
  AppSemanticColors copyWith({
    Color? positive,
    Color? onPositiveContainer,
    Color? positiveContainer,
    Color? negative,
    Color? onNegativeContainer,
    Color? negativeContainer,
    Color? warning,
    Color? onWarningContainer,
    Color? warningContainer,
    Color? chartLine,
    Color? chartAreaTop,
    Color? chartAreaBottom,
    Color? chartGrid,
  }) {
    return AppSemanticColors(
      positive: positive ?? this.positive,
      onPositiveContainer: onPositiveContainer ?? this.onPositiveContainer,
      positiveContainer: positiveContainer ?? this.positiveContainer,
      negative: negative ?? this.negative,
      onNegativeContainer: onNegativeContainer ?? this.onNegativeContainer,
      negativeContainer: negativeContainer ?? this.negativeContainer,
      warning: warning ?? this.warning,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      warningContainer: warningContainer ?? this.warningContainer,
      chartLine: chartLine ?? this.chartLine,
      chartAreaTop: chartAreaTop ?? this.chartAreaTop,
      chartAreaBottom: chartAreaBottom ?? this.chartAreaBottom,
      chartGrid: chartGrid ?? this.chartGrid,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      positive: Color.lerp(positive, other.positive, t)!,
      onPositiveContainer:
          Color.lerp(onPositiveContainer, other.onPositiveContainer, t)!,
      positiveContainer:
          Color.lerp(positiveContainer, other.positiveContainer, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      onNegativeContainer:
          Color.lerp(onNegativeContainer, other.onNegativeContainer, t)!,
      negativeContainer:
          Color.lerp(negativeContainer, other.negativeContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      chartLine: Color.lerp(chartLine, other.chartLine, t)!,
      chartAreaTop: Color.lerp(chartAreaTop, other.chartAreaTop, t)!,
      chartAreaBottom: Color.lerp(chartAreaBottom, other.chartAreaBottom, t)!,
      chartGrid: Color.lerp(chartGrid, other.chartGrid, t)!,
    );
  }
}
