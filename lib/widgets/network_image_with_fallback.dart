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
  });

  final String url;
  final BoxFit fit;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _Placeholder(icon: fallbackIcon, showSpinner: false);
        },
      );
    }

    return Image.network(
      url,
      fit: fit,
      gaplessPlayback: true,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _Placeholder(icon: fallbackIcon, showSpinner: true);
      },
      errorBuilder: (context, error, stackTrace) {
        return _Placeholder(icon: fallbackIcon, showSpinner: false);
      },
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, required this.showSpinner});

  final IconData icon;
  final bool showSpinner;

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
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white38),
                ),
              )
            : Icon(icon, color: AppColors.textSecondary, size: 28),
      ),
    );
  }
}
