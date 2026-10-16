import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Renders a luxurious atmospheric ambient color wash behind page content,
/// dynamically tinted based on the colour chosen for the top bar button navigation.
///
/// Features:
/// - Base deep theme background (`AppColors.background`).
/// - Upper vertical ambient mesh gradient that softly cascades down from the top bar.
/// - Top-center radial bloom that illuminates the space behind the top navigation header.
class ThemedPageBackground extends StatelessWidget {
  const ThemedPageBackground({
    super.key,
    required this.accentColor,
    required this.child,
    this.ambientHeight = 340,
    this.intensity = 0.18,
  });

  /// The active section's chosen accent color (e.g. Coral Crimson, Golden Amber,
  /// Warm Gold, Emerald Mint, Royal Amethyst).
  final Color accentColor;

  /// The inner page content/body.
  final Widget child;

  /// Height of the vertical gradient ambient wash.
  final double ambientHeight;

  /// Base opacity multiplier for the ambient glow.
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Deep Base Canvas ───────────────────────────────────────────
        Container(color: AppColors.background),

        // ── Cascading Vertical Ambient Color Mesh ──────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: ambientHeight,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accentColor.withValues(alpha: intensity * 1.15),
                    accentColor.withValues(alpha: intensity * 0.55),
                    accentColor.withValues(alpha: intensity * 0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.35, 0.70, 1.0],
                ),
              ),
            ),
          ),
        ),

        // ── Top Radial Ambient Bloom ───────────────────────────────────
        Positioned(
          top: -60,
          left: -40,
          right: -40,
          height: 240,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.6),
                  radius: 1.1,
                  colors: [
                    accentColor.withValues(alpha: intensity * 0.95),
                    accentColor.withValues(alpha: intensity * 0.30),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
        ),

        // ── Page Content ───────────────────────────────────────────────
        child,
      ],
    );
  }
}

