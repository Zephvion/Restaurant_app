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
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool isActive = enabled && !isLoading && onPressed != null;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: Material(
        color: isActive ? AppColors.surface : AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.field),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.field),
          onTap: isActive ? onPressed : null,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textPrimary,
                    ),
                  )
                : Text(
                    label.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isActive
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}
