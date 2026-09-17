import 'dart:async';

import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/session_manager.dart';
import '../../theme/app_colors.dart';
import '../../widgets/paragon_logo.dart';

/// Splash screen — centered PARAGON crest on a dark background with the thin
/// red accent bar at the very bottom. Auto-advances to onboarding.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _timer = Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      if (SessionManager.instance.isLoggedIn) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: const ParagonLogo(width: 150),
            ),
          ),
          // Thin red accent bar pinned to the bottom edge.
          const Align(
            alignment: Alignment.bottomCenter,
            child: _BottomAccentBar(),
          ),
        ],
      ),
    );
  }
}

class _BottomAccentBar extends StatelessWidget {
  const _BottomAccentBar();

  @override
  Widget build(BuildContext context) {
    return Container(height: 6, color: AppColors.accentRed);
  }
}
