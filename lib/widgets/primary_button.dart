import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The full-width pill button used across the app
/// ("LOGIN", "SIGN IN", "ORDER FROM NEAREST RESTAURANT").
/// Automatically scales down text to prevent overflows on compact mobile screens.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.uppercase = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final bool isActive = enabled && !isLoading && onPressed != null;
    final baseBg = backgroundColor ?? AppColors.surface;
    final textColor = foregroundColor ?? AppColors.textPrimary;
    final displayText = uppercase ? label.toUpperCase() : label;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: isActive ? baseBg : baseBg.withValues(alpha: 0.5),
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
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              size: 18,
                              color: isActive
                                  ? textColor
                                  : textColor.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            displayText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: isActive
                                      ? textColor
                                      : textColor.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  letterSpacing: uppercase ? 1.0 : 0.3,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
