import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Garden Isometric Palette)
  static const Color primary = Color(
    0xFF4A86C5,
  ); // Azul Profundo (Texto y Casa)
  static const Color primaryHover = Color(0xFF3B6E9F);
  static const Color primarySoft = Color(0xFFE3F2FD);

  static const Color secondary = Color(
    0xFFA3D9A5,
  ); // Verde Menta/Salvia (Vegetación)
  static const Color secondaryHover = Color(0xFF8BBD8D);
  static const Color secondarySoft = Color(0xFFF1F8F1);

  static const Color accent = Color(
    0xFFFFD700,
  ); // Amarillo Brillante (Corazón y Sensores)
  static const Color info = Color(0xFF87CEEB); // Azul Celeste (Icono Logo)
  static const Color water = Color(0xFF5AC8FA); // Cian Suave (Agua)
  static const Color earth = Color(0xFFC08253); // Marrón Arcilla (Suelo)

  // Layout Colors (Clean / Natural)
  static const Color background = Color(0xFFF5F7FA); // Light Grey-Blue tint
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5F7FA), Color.fromARGB(255, 211, 221, 239)],
    stops: [0.1, .9],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A86C5), Color(0xFF87CEEB)],
  );

  static const Color surface = Color(0xFFFFFFFF); // White for cards
  static const Color border = Color(0xFFD1D9E6);
  static const Color shadow = Color(0xFF9EA7B8);

  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF5D6D7E);
  static const Color textMuted = Color(0xFF95A5A6);

  // Sensor States / Utility
  static const Color positive = Color(0xFF27AE60);
  static const Color positiveSoft = Color(0xFFEAFAF1);

  static const Color negative = Color(0xFFE74C3C);
  static const Color negativeSoft = Color(0xFFFDEDEC);

  static const Color warning = Color(0xFFF1C40F);
  static const Color warningSoft = Color(0xFFFEF9E7);

  // Compatibility helpers
  static Color glassBackground = Colors.white.withValues(alpha: 0.8);
  static Color glassShadow = const Color(0xFF9EA7B8).withValues(alpha: 0.2);
}
