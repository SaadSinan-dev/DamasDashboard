import 'package:flutter/material.dart';

/// Raw brand swatches.
///
/// This is the only file in the project allowed to contain literal hex colors.
/// Everything else consumes either the active [ColorScheme] or the app's
/// semantic color extension, so light and dark stay in sync and contrast stays
/// auditable in one place.
abstract final class AppPalette {
  // Emerald — brand hue.
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color emerald300 = Color(0xFF6EE7B7);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color emerald800 = Color(0xFF065F46);
  static const Color emerald900 = Color(0xFF064E3B);
  static const Color emerald950 = Color(0xFF022C22);

  /// Used for shadows and scrims, where a true black is wanted rather than a
  /// tinted neutral.
  static const Color black = Colors.black;

  // Neutrals, very slightly green-tinted so they sit naturally beside the brand.
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF7FAF9);
  static const Color neutral100 = Color(0xFFEFF3F1);
  static const Color neutral200 = Color(0xFFE2E8E5);
  static const Color neutral300 = Color(0xFFCBD5D0);
  static const Color neutral500 = Color(0xFF6B7C75);
  static const Color neutral600 = Color(0xFF53625C);
  static const Color neutral700 = Color(0xFF3A4844);
  static const Color neutral800 = Color(0xFF1F2B27);
  static const Color neutral900 = Color(0xFF12201A);
  static const Color neutral950 = Color(0xFF071A13);

  // Elevation ramp for dark mode. Material 3 conveys elevation with tinted
  // surfaces rather than shadows, so dark elevation needs its own ramp.
  static const Color darkSurfaceLowest = Color(0xFF041009);
  static const Color darkSurface = Color(0xFF071A13);
  static const Color darkSurfaceLow = Color(0xFF0A2018);
  static const Color darkSurfaceContainer = Color(0xFF0D251C);
  static const Color darkSurfaceHigh = Color(0xFF123028);
  static const Color darkSurfaceHighest = Color(0xFF173A30);
  static const Color darkOutline = Color(0xFF2F463D);
  static const Color darkOutlineVariant = Color(0xFF1D3028);

  // Status hues.
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red300 = Color(0xFFFCA5A5);
  static const Color red900 = Color(0xFF7F1D1D);

  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber900 = Color(0xFF78350F);
}
