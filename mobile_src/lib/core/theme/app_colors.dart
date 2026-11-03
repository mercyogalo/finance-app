import 'package:flutter/material.dart';

/// Every color in the app. Do not declare [Color] values anywhere else.
abstract final class AppColors {
  static const Color primary = Color(0xFF0E9F6E);
  static const Color primaryDark = Color(0xFF057A55);
  static const Color primaryTint = Color(0xFFE6F6EF);
  static const Color accent = Color(0xFFFFB020);
  static const Color accentTint = Color(0xFFFFF4DB);
  static const Color background = Color(0xFFF7FAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F1F18);
  static const Color textSecondary = Color(0xFF5B6B63);
  static const Color border = Color(0xFFE3EAE6);
  static const Color error = Color(0xFFDC2626);
  static const Color shadow = Color(0x1A0F1F18);
  static const Color scrim = Color(0x990F1F18);
  static const Color transparent = Color(0x00000000);

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: shadow, blurRadius: 18, offset: Offset(0, 8)),
  ];
}
