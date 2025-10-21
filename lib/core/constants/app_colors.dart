import 'package:flutter/material.dart';

// App Colors
class AppColors {
  // Primary Colors (Netflix-inspired)
  static const Color primary = Color(0xFFE50914); // Netflix Red
  static const Color primaryDark = Color(0xFFB20710);
  static const Color primaryLight = Color(0xFFF40612);

  // Background Colors (Dark Theme)
  static const Color background = Color(0xFF121212);
  static const Color backgroundLight = Color(0xFF1E1E1E);
  static const Color backgroundCard = Color(0xFF2A2A2A);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF808080);

  // Accent Colors
  static const Color accent = Color(0xFF0071EB); // Blue
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color error = Color(0xFFF44336); // Red

  // Subtitle Colors
  static const Color subtitleEnglish = Color(0xFFFFFFFF);
  static const Color subtitleVietnamese = Color(0xFFFFEB3B);

  // Rating Color
  static const Color rating = Color(0xFFFFC107);

  // Overlay & Shadows
  static const Color overlay = Color(0x80000000);
  static const Color shadow = Color(0x40000000);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [backgroundCard, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
