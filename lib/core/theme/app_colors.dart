import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color brand = Color(0xFF5B4BFF);
  static const Color brandDark = Color(0xFF3F31C9);
  static const Color brandLight = Color(0xFF8A7BFF);

  static const Color background = Color(0xFFF4F5FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEFF0F8);

  static const Color textPrimary = Color(0xFF14152B);
  static const Color textSecondary = Color(0xFF6B6E86);
  static const Color textMuted = Color(0xFF9A9DB5);
  static const Color border = Color(0xFFE7E8F2);

  static const Color credit = Color(0xFF1FB57A);
  static const Color debit = Color(0xFFF0454B);
  static const Color info = Color(0xFF3B82F6);
  static const Color warning = Color(0xFFF2A33A);

  static const LinearGradient balanceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B4BFF), Color(0xFF7B5CFF), Color(0xFF9D7BFF)],
  );

  static Color serviceColor(String serviceName) {
    switch (serviceName.toUpperCase()) {
      case 'ISM':
        return brand;
      case 'WOYAFAL':
        return warning;
      default:
        return info;
    }
  }
}
