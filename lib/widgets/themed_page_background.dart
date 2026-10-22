import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/mode_theme.dart';

/// Renders a luxurious atmospheric ambient color wash behind page content,
/// dynamically tinted based on the colour/theme chosen for the top bar button navigation.
///
/// Features:
/// - Base deep theme background (`AppColors.background`).
/// - Upper vertical ambient mesh gradient that softly cascades down from the top bar.
/// - Top-center radial bloom that illuminates the space behind the top navigation header.
class ThemedPageBackground extends StatelessWidget {
  const ThemedPageBackground({
    super.key,
    required this.accentColor,
    this.theme,
    required this.child,
    this.ambientHeight = 680,
    this.intensity = 0.55,
  });

  /// The active section's chosen accent color (e.g. Coral Crimson, Golden Amber,
  /// Warm Gold, Emerald Mint, Royal Amethyst).
  final Color accentColor;

  /// Optional explicit [ModeTheme]. If omitted, resolved from [accentColor].
  final ModeTheme? theme;

  /// The inner page content/body.
  final Widget child;

  /// Height of the vertical gradient ambient wash (flows through the upper half).
  final double ambientHeight;

  /// Base opacity multiplier for the ambient glow.
  final double intensity;

  ModeTheme get _resolvedTheme {
    if (theme != null) return theme!;
    for (final t in ModeTheme.all) {
      if (t.primaryAccent.value == accentColor.value) {
        return t;
      }
    }
    return ModeTheme.orderFood;
  }

  @override
  Widget build(BuildContext context) {
    final t = _resolvedTheme;
    final effectiveWashColors = t.pageWashColors;
    final effectiveWashStops = t.pageWashStops;
    final effectiveBloomColor = t.pageBloomColor;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Deep Base Canvas ───────────────────────────────────────────
        Container(color: AppColors.background),

        // ── Cascading Vertical Ambient Color Wash ───────────────────────
        // Starts rich at the top and seamlessly fades out at the half of the screen
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
                  colors: effectiveWashColors,
                  stops: effectiveWashStops,
                ),
              ),
            ),
          ),
        ),

        // ── Top Radial Ambient Bloom ───────────────────────────────────
        Positioned(
          top: -50,
          left: -40,
          right: -40,
          height: 280,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.4),
                  radius: 1.15,
                  colors: [
                    effectiveBloomColor.withValues(alpha: 0.35 * (intensity / 0.55)),
                    effectiveBloomColor.withValues(alpha: 0.12 * (intensity / 0.55)),
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
