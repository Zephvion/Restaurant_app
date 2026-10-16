import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The full-width pill button used across the auth screens
/// ("LOGIN", "SIGN IN"). Dark grey fill, white letter-spaced label.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final bool isActive = enabled && !isLoading && onPressed != null;
    final baseBg = backgroundColor ?? AppColors.surface;
    final textColor = foregroundColor ?? AppColors.textPrimary;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: Material(
        color: isActive ? baseBg : baseBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.field),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.field),
          onTap: isActive ? onPressed : null,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: textColor,
                    ),
                  )
                : Text(
                    label.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isActive
                              ? textColor
                              : textColor.withOpacity(0.5),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}
