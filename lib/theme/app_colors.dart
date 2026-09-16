import 'package:flutter/material.dart';

/// Central color palette for the PARAGON app, derived from the Figma designs.
///
/// The app uses a near-black dark theme with a copper logo accent and a
/// vivid red used for links and the thin bottom accent bar.
class AppColors {
  AppColors._();

  /// Page background — near black.
  static const Color background = Color(0xFF0E0E11);

  /// Slightly lifted background used for large panels.
  static const Color backgroundElevated = Color(0xFF141418);

  /// Fill for input fields and buttons (dark grey pills).
  static const Color surface = Color(0xFF1E1E24);

  /// A touch lighter — used for pressed states / secondary fills.
  static const Color surfaceLight = Color(0xFF2A2A32);

  /// Card image label bar gradient (maroon → transparent).
  static const Color maroon = Color(0xFF4A0F10);

  /// Copper / bronze — the PARAGON logo color.
  static const Color copper = Color(0xFFC6863E);

  /// Vivid red — links ("Sign Up", "Login") and the bottom accent bar.
  static const Color accentRed = Color(0xFFE5372B);

  /// Primary text — off white.
  static const Color textPrimary = Color(0xFFF4F4F5);

  /// Secondary / muted text.
  static const Color textSecondary = Color(0xFF9A9AA3);

  /// Placeholder / hint text inside inputs.
  static const Color hint = Color(0xFF7C7C85);

  /// Subtle borders.
  static const Color border = Color(0xFF2E2E36);
}

/// Shared spacing scale (keeps padding consistent across screens).
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Standard horizontal screen padding used throughout the app.
  static const double screenPadding = 24;
}

/// Shared corner radii.
class AppRadius {
  AppRadius._();

  static const double field = 30; // pill inputs / buttons
  static const double card = 22; // service cards & onboarding images
  static const double otpBox = 16;
}
