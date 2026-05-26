import 'package:flutter/material.dart';

import '../../core/constants/app_palette.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppPalette.black,
      colorScheme: const ColorScheme.dark(
        primary: AppPalette.orange,
        secondary: AppPalette.softOrange,
        surface: AppPalette.panel,
        error: AppPalette.danger,
      ),
      textTheme: base.textTheme
          .apply(
            fontFamily: 'Inter',
            bodyColor: AppPalette.cream,
            displayColor: AppPalette.cream,
          )
          .copyWith(
            headlineLarge: base.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: AppPalette.cream,
            ),
            titleLarge: base.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: AppPalette.cream,
            ),
            bodyMedium: base.textTheme.bodyMedium?.copyWith(
              color: AppPalette.mutedCream,
              height: 1.35,
            ),
          ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.panelLight.withOpacity(0.82),
        hintStyle: const TextStyle(color: AppPalette.mutedCream),
        labelStyle: const TextStyle(color: AppPalette.mutedCream),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppPalette.orange, width: 1.4),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppPalette.deepCopper,
        selectedColor: AppPalette.orange,
        labelStyle: const TextStyle(color: AppPalette.cream, fontWeight: FontWeight.w700),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.orange,
          foregroundColor: AppPalette.cream,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppPalette.orange,
        foregroundColor: AppPalette.cream,
        elevation: 0,
      ),
      dividerColor: AppPalette.cream.withOpacity(0.08),
    );
  }
}
