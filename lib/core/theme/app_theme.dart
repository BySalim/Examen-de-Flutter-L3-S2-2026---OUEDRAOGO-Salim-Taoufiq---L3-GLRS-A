import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = _buildTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brand,
        secondary: AppColors.brandLight,
        surface: AppColors.surface,
        error: AppColors.debit,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.brand, width: 1.6),
        errorBorder: _border(AppColors.debit),
        focusedErrorBorder: _border(AppColors.debit, width: 1.6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1.2}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    final heading = GoogleFonts.poppinsTextTheme(base);
    final body = GoogleFonts.interTextTheme(base);
    return base.copyWith(
      displaySmall: heading.displaySmall?.copyWith(
          fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineMedium: heading.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineSmall: heading.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      titleLarge: heading.titleLarge?.copyWith(
          fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleMedium: body.titleMedium?.copyWith(
          fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyLarge: body.bodyLarge?.copyWith(color: AppColors.textPrimary),
      bodyMedium: body.bodyMedium?.copyWith(color: AppColors.textSecondary),
      bodySmall: body.bodySmall?.copyWith(color: AppColors.textMuted),
      labelLarge: body.labelLarge?.copyWith(
          fontWeight: FontWeight.w600, letterSpacing: 0.2),
    );
  }
}
