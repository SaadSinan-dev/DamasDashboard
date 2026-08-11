import 'package:flutter/material.dart';

import 'app_dimens.dart';
import 'app_palette.dart';
import 'app_semantic_colors.dart';
import 'app_typography.dart';

/// Assembles the light and dark [ThemeData] from the design tokens.
///
/// Themes are built per-locale because the type system swaps font families and
/// line heights between Latin and Arabic. Component themes are configured here
/// once so that screens can use stock Material widgets and still look on-brand
/// without restyling anything locally.
abstract final class AppTheme {
  static ThemeData light(Locale locale) =>
      _build(_lightScheme, AppSemanticColors.light, locale);

  static ThemeData dark(Locale locale) =>
      _build(_darkScheme, AppSemanticColors.dark, locale);

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppPalette.emerald700,
    onPrimary: AppPalette.neutral0,
    primaryContainer: AppPalette.emerald100,
    onPrimaryContainer: AppPalette.emerald900,
    secondary: AppPalette.emerald600,
    onSecondary: AppPalette.neutral0,
    secondaryContainer: AppPalette.emerald50,
    onSecondaryContainer: AppPalette.emerald800,
    tertiary: AppPalette.neutral700,
    onTertiary: AppPalette.neutral0,
    tertiaryContainer: AppPalette.neutral100,
    onTertiaryContainer: AppPalette.neutral900,
    error: AppPalette.red600,
    onError: AppPalette.neutral0,
    errorContainer: AppPalette.red100,
    onErrorContainer: AppPalette.red900,
    surface: AppPalette.neutral0,
    onSurface: AppPalette.neutral900,
    onSurfaceVariant: AppPalette.neutral600,
    surfaceContainerLowest: AppPalette.neutral0,
    surfaceContainerLow: AppPalette.neutral50,
    surfaceContainer: AppPalette.neutral50,
    surfaceContainerHigh: AppPalette.neutral100,
    surfaceContainerHighest: AppPalette.neutral100,
    outline: AppPalette.neutral300,
    outlineVariant: AppPalette.neutral200,
    inverseSurface: AppPalette.neutral900,
    onInverseSurface: AppPalette.neutral50,
    inversePrimary: AppPalette.emerald300,
    shadow: AppPalette.black,
    scrim: AppPalette.black,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppPalette.emerald400,
    onPrimary: AppPalette.emerald950,
    primaryContainer: AppPalette.emerald800,
    onPrimaryContainer: AppPalette.emerald100,
    secondary: AppPalette.emerald300,
    onSecondary: AppPalette.emerald950,
    secondaryContainer: AppPalette.emerald900,
    onSecondaryContainer: AppPalette.emerald100,
    tertiary: AppPalette.neutral300,
    onTertiary: AppPalette.neutral900,
    tertiaryContainer: AppPalette.neutral800,
    onTertiaryContainer: AppPalette.neutral100,
    error: AppPalette.red300,
    onError: AppPalette.red900,
    errorContainer: AppPalette.red900,
    onErrorContainer: AppPalette.red100,
    surface: AppPalette.darkSurface,
    onSurface: AppPalette.neutral100,
    onSurfaceVariant: AppPalette.neutral300,
    surfaceContainerLowest: AppPalette.darkSurfaceLowest,
    surfaceContainerLow: AppPalette.darkSurfaceLow,
    surfaceContainer: AppPalette.darkSurfaceContainer,
    surfaceContainerHigh: AppPalette.darkSurfaceHigh,
    surfaceContainerHighest: AppPalette.darkSurfaceHighest,
    outline: AppPalette.darkOutline,
    outlineVariant: AppPalette.darkOutlineVariant,
    inverseSurface: AppPalette.neutral100,
    onInverseSurface: AppPalette.neutral900,
    inversePrimary: AppPalette.emerald700,
    shadow: AppPalette.black,
    scrim: AppPalette.black,
  );

  static ThemeData _build(
    ColorScheme scheme,
    AppSemanticColors semantic,
    Locale locale,
  ) {
    final TextTheme textTheme = AppTypography.textThemeFor(locale);
    final bool isDark = scheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? scheme.surface
          : AppPalette.neutral50, // Page ground sits below cards.
      textTheme: textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      extensions: <ThemeExtension<dynamic>>[semantic],
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          letterSpacing: 1.2,
        ),
        shape: Border(
          bottom: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.horizontal(
            end: Radius.circular(AppRadii.xl),
          ),
        ),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurface,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: textTheme.titleSmall?.copyWith(color: scheme.onSurface),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppBreakpoints.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppBreakpoints.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, AppBreakpoints.minTapTarget),
          textStyle: textTheme.labelLarge,
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(AppBreakpoints.minTapTarget),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHigh,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onInverseSurface,
        ),
      ),
    );
  }
}
