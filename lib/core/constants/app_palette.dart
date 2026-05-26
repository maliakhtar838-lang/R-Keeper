import 'package:flutter/material.dart';

/// Warm, cinematic palette extracted from the supplied reference image:
/// black/brown depth, copper-orange controls, muted sand highlights, and cream text.
class AppPalette {
  AppPalette._();

  static const Color black = Color(0xFF070403);
  static const Color espresso = Color(0xFF130B07);
  static const Color burntBrown = Color(0xFF341407);
  static const Color deepCopper = Color(0xFF7B2E12);
  static const Color copper = Color(0xFFA84A1B);
  static const Color orange = Color(0xFFD77A35);
  static const Color softOrange = Color(0xFFE0A06F);
  static const Color sand = Color(0xFFD9B99C);
  static const Color cream = Color(0xFFFFF6EA);
  static const Color mutedCream = Color(0xFFCDBAA8);
  static const Color panel = Color(0xFF1A0F0A);
  static const Color panelLight = Color(0xFF26140C);
  static const Color danger = Color(0xFFE35A4F);
  static const Color success = Color(0xFF9BC46D);
  static const Color blueGrey = Color(0xFF7E8994);

  static const List<Color> backgroundGradient = [black, espresso, burntBrown];

  static const List<int> cardPaletteValues = [
    0xFFA84A1B,
    0xFF7B2E12,
    0xFFB86435,
    0xFFE0A06F,
    0xFF5B2713,
    0xFF2B1A12,
    0xFF7E8994,
    0xFF9A6B4F,
  ];

  static List<Color> get cardPalette => cardPaletteValues.map(Color.new).toList(growable: false);
}
