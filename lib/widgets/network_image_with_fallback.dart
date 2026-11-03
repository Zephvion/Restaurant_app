import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// An image wrapper that loads local assets (if url starts with 'assets/')
/// or [Image.network] with graceful fallbacks.
class NetworkImageWithFallback extends StatelessWidget {
  const NetworkImageWithFallback({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.restaurant_menu,
    this.fallbackIconSize = 28,
    this.showSpinner = true,
    this.filterQuality = FilterQuality.medium,
  });

  final String url;
  final BoxFit fit;
  final IconData fallbackIcon;
  final double fallbackIconSize;
  final bool showSpinner;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: fit,
        filterQuality: filterQuality,
        errorBuilder: (context, error, stackTrace) {
          return _Placeholder(
            icon: fallbackIcon,
            iconSize: fallbackIconSize,
            showSpinner: false,
          );
        },
      );
    }

    return Image.network(
      url,
      fit: fit,
      filterQuality: filterQuality,
      gaplessPlayback: true,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _Placeholder(
          icon: fallbackIcon,
          iconSize: fallbackIconSize,
          showSpinner: showSpinner,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _Placeholder(
          icon: fallbackIcon,
          iconSize: fallbackIconSize,
          showSpinner: false,
        );
      },
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.icon,
    required this.showSpinner,
    this.iconSize = 28,
  });

  final IconData icon;
  final bool showSpinner;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceLight, AppColors.surface],
        ),
      ),
      child: Center(
        child: showSpinner
            ? SizedBox(
                width: (iconSize * 0.8).clamp(14.0, 22.0),
                height: (iconSize * 0.8).clamp(14.0, 22.0),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white38),
                ),
              )
            : Icon(icon, color: AppColors.textSecondary, size: iconSize),
      ),
    );
  }
}
