import 'package:flutter/material.dart';

/// Type system for the app.
///
/// Latin text pairs two faces: Oswald (condensed, high-impact) for display and
/// headline roles, RobotoCondensed for body and label roles — Oswald is too
/// narrow to read comfortably below ~18px. Arabic uses Almarai for every role
/// and a taller line height, because Arabic ascenders and descenders clip at
/// the leading that suits Latin text.
abstract final class AppTypography {
  static const String latinDisplay = 'Oswald';
  static const String latinBody = 'RobotoCondensed';
  static const String arabic = 'Almarai';

  /// Font family for headline/display roles in [locale].
  static String displayFamilyFor(Locale locale) =>
      _isArabic(locale) ? arabic : latinDisplay;

  /// Font family for body/label roles in [locale].
  static String bodyFamilyFor(Locale locale) =>
      _isArabic(locale) ? arabic : latinBody;

  static bool _isArabic(Locale locale) => locale.languageCode == 'ar';

  /// Builds the full Material 3 [TextTheme] for [locale].
  static TextTheme textThemeFor(Locale locale) {
    final bool arabicLocale = _isArabic(locale);
    final String display = displayFamilyFor(locale);
    final String body = bodyFamilyFor(locale);

    // Arabic needs more leading; Latin display type is set tight on purpose.
    final double displayHeight = arabicLocale ? 1.45 : 1.12;
    final double titleHeight = arabicLocale ? 1.5 : 1.25;
    final double bodyHeight = arabicLocale ? 1.65 : 1.45;

    // Oswald is already condensed, so extra tracking keeps it from feeling
    // cramped. Almarai is naturally open and needs none.
    final double displayTracking = arabicLocale ? 0 : 0.4;

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: display,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: displayHeight,
        letterSpacing: displayTracking,
      ),
      displayMedium: TextStyle(
        fontFamily: display,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: displayHeight,
        letterSpacing: displayTracking,
      ),
      displaySmall: TextStyle(
        fontFamily: display,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: displayHeight,
        letterSpacing: displayTracking,
      ),
      headlineLarge: TextStyle(
        fontFamily: display,
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: titleHeight,
      ),
      headlineMedium: TextStyle(
        fontFamily: display,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: titleHeight,
      ),
      headlineSmall: TextStyle(
        fontFamily: display,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: titleHeight,
      ),
      titleLarge: TextStyle(
        fontFamily: display,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: titleHeight,
      ),
      titleMedium: TextStyle(
        fontFamily: body,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: titleHeight,
      ),
      titleSmall: TextStyle(
        fontFamily: body,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: titleHeight,
      ),
      bodyLarge: TextStyle(
        fontFamily: body,
        fontSize: 16,
        height: bodyHeight,
      ),
      bodyMedium: TextStyle(
        fontFamily: body,
        fontSize: 14,
        height: bodyHeight,
      ),
      bodySmall: TextStyle(
        fontFamily: body,
        fontSize: 12,
        height: bodyHeight,
      ),
      labelLarge: TextStyle(
        fontFamily: body,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      labelMedium: TextStyle(
        fontFamily: body,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      labelSmall: TextStyle(
        fontFamily: body,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.8,
      ),
    );
  }
}
