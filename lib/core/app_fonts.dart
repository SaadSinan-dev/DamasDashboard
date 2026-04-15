import 'package:flutter/widgets.dart';

class AppFonts {
  static const String english = 'Oswald';
  static const String arabic = 'Almarai';

  /// Returns the raw font family name
  static String getFont(Locale locale) {
    return locale.languageCode == 'ar' ? arabic : english;
  }

  /// Senior Level: Returns a base TextStyle with the correct font family.
  /// This ensures that line height and letter spacing are optimized 
  /// for the specific language.
  static TextStyle getTextStyle(Locale locale, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    final bool isArabic = locale.languageCode == 'ar';
    
    return TextStyle(
      fontFamily: isArabic ? arabic : english,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      // Oswald often needs a bit more spacing, Almarai needs less.
      letterSpacing: letterSpacing ?? (isArabic ? 0.0 : 0.5),
      // Arabic fonts often require a slightly higher line height to prevent clipping
      height: isArabic ? 1.5 : 1.2,
    );
  }
}