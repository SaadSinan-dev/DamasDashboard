import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 🌑 Surface / Background
  static const Color surface = Color.fromARGB(255, 57, 91, 81);
  static const Color surfaceDark = Color(0xFF051F17);
  static const Color surfaceLight = Color(0xFF0B2A20);

  // 💚 Primary Accent (Green System)
  static const Color primary = Color.fromARGB(255, 151, 234, 206);
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF34D399);

  // 🧱 Borders / Dividers
  static const Color border = Color(0xFF1E293B);
  static const Color borderLight = Color(0xFF334155);

  // ⚪ Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted = Colors.white54;

  // 🧊 Cards
  static const Color card = Color(0xFF0B2A20);
  static const Color cardElevated = Color(0xFF102E24);

  // 🌈 Gradients (🔥 أهم جزء للـ Dashboard look)

  /// Main background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFF051F17),
      Color(0xFF0B2A20),
      Color(0xFF1B4332),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Primary green gradient (buttons, highlights)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF10B981),
      Color(0xFF34D399),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Card gradient (premium UI effect)
  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xFF0B2A20),
      Color(0xFF102E24),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Glow effect (for icons / accents)
  static const RadialGradient glow = RadialGradient(
    colors: [
      Color(0x3310B981),
      Colors.transparent,
    ],
    radius: 0.8,
  );
}