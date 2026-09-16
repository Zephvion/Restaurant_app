import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds the global [ThemeData] for the app.
///
/// Typography: Quicksand for large display headings (the rounded, geometric
/// look in the Figma titles like "Welcome Back!" and "Verify OTP!") and
/// Poppins for body text and buttons.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    final textTheme = _buildTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      primaryColor: AppColors.copper,
      splashColor: Colors.white10,
      highlightColor: Colors.white10,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.copper,
        secondary: AppColors.accentRed,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: null,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    // Display / heading font.
    final display = GoogleFonts.quicksandTextTheme(base);
    // Body font.
    final body = GoogleFonts.poppinsTextTheme(base);

    return base.copyWith(
      // Big screen titles ("Welcome Back!", "Verify OTP!", onboarding titles).
      displaySmall: display.displaySmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 30,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 28,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 24,
      ),
      titleLarge: display.titleLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      // Body text.
      bodyLarge: body.bodyLarge?.copyWith(
        color: AppColors.textPrimary,
        fontSize: 15,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        fontSize: 14,
        height: 1.4,
      ),
      bodySmall: body.bodySmall?.copyWith(
        color: AppColors.textSecondary,
        fontSize: 12,
      ),
      // Buttons — uppercase, letter-spaced (LOGIN, SIGN IN).
      labelLarge: body.labelLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 15,
        letterSpacing: 1.5,
      ),
    );
  }
}
