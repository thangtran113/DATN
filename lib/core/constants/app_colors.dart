import 'package:flutter/material.dart';

/// Màu sắc ứng dụng
class AppColors {
  /// Màu chính (từ logo - hiện đại & tươi mới)
  static const Color primary = Color(0xFF8FDADB); // Cyan/Turquoise
  static const Color primaryDark = Color(0xFF234199); // Xanh dương đậm
  static const Color primaryLight = Color(0xFF90DADC); // Cyan nhạt

  /// Màu nền (theme xanh navy tối)
  static const Color background = Color(0xFF0A1929); // Navy đậm
  static const Color backgroundLight = Color(0xFF1A2F47); // Xanh xám vừa
  static const Color backgroundCard = Color(0xFF1A2F47); // Xanh xám vừa

  /// Màu chữ
  static const Color textPrimary = Color(0xFFF1F5F9); // Xám trắng nhạt
  static const Color textSecondary = Color(0xFFBDC9D6); // Xám xanh
  static const Color textTertiary = Color(0xFF8A9BAE); // Xanh xám vừa

  /// Màu nhấn
  static const Color accent = Color(0xFF90DADC); // Cyan sáng
  static const Color success = Color(0xFF4CAF50); // Xanh lá
  static const Color warning = Color(0xFFFFA726); // Cam
  static const Color error = Color(0xFFEF5350); // Đỏ

  /// Màu phụ đề
  static const Color subtitleEnglish = Color(0xFFFFFFFF);
  static const Color subtitleVietnamese = Color(0xFFFFD54F); // Vàng

  /// Màu đánh giá
  static const Color rating = Color(0xFFFFB300);

  /// Overlay & Shadow
  static const Color overlay = Color(0x80000000);
  static const Color shadow = Color(0x40000000);

  /// Gradient
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
