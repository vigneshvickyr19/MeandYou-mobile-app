import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const primary = Color(0xFFE48B59);
  static const secondary = Color(0xFFF16F25);

  // Basic colors
  static const black = Color(0xFF020000);
  static const white = Color(0xFFFFFFFF);

  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFF44336);
  static const warning = Color(0xFFFFC107);
  static const info = Color(0xFF2196F3);

  static const greyLight = Color(0xFFE0E0E0); // if needed
  static const greyDark = Color(0xFF6B6B6B); // border and icon

  // Neumorphic Nav Colors
  static const navInactive = Color(0xFF8A6A55);
  static const navActiveGradientStart = Color(0xFFFF8A3D);
  static const navActiveGradientEnd = Color(0xFFFF6A00);
  static const navBg = Color(0xFF121212);
  static const navItemBg = Color(0xFF1E1E1E);

  static final darkOverlay = const Color.fromARGB(
    255,
    43,
    42,
    42,
  ).withValues(alpha: 0.9);
}
