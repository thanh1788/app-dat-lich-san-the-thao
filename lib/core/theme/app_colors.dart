import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF00C853); // Emerald Green
  static const Color primaryDark = Color(0xFF009624);
  static const Color primaryLight = Color(0xFFE8F8EE);
  static const Color secondary = Color(0xFF00B4D8); // Cyan Accent

  // Semantic & Status
  static const Color available = Color(0xFFE8F8EE); // Nền slot trống
  static const Color availableBorder = Color(0xFF00C853);
  static const Color selected = Color(0xFF00C853); // Đang chọn
  static const Color booked = Color(0xFFE5E7EB); // Đã đặt (Disabled)
  static const Color bookedText = Color(0xFF9CA3AF);
  static const Color peakHour = Color(0xFFFF9800); // Giờ vàng
  static const Color peakHourLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFE53935);
  static const Color star = Color(0xFFFFB300);

  // Neutrals & Surfaces (Light Mode)
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE9ECEF);
  static const Color divider = Color(0xFFF1F3F5);

  // Typography
  static const Color textPrimary = Color(0xFF191C1E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Shadows
  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.25),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];
}
