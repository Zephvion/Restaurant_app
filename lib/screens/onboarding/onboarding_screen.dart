import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/onboarding_item.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/network_image_with_fallback.dart';

/// Onboarding carousel — three swipeable slides, each with a tilted two-photo
/// collage, a title, a subtitle, and a Skip / next-arrow control row.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  List<OnboardingItem> get _items => MockData.onboarding;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _next() {
    if (_page >= _items.length - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _Dots(count: _items.length, active: _page),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _items.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _OnboardingPage(item: _items[i]),
              ),
            ),
            _Controls(onSkip: _finish, onNext: _next),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.item});

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: _Collage(front: item.frontImage, back: item.backImage),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 30,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Two rounded photos fanned out at slight opposing angles.
class _Collage extends StatelessWidget {
  const _Collage({required this.front, required this.back});

  final String front;
  final String back;

  double _rad(double deg) => deg * math.pi / 180.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final frontW = w * 0.72;
        final frontH = h * 0.74;
        final backW = w * 0.66;
        final backH = h * 0.66;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Back photo — tilted, peeking from the top-right.
            Positioned(
              top: 0,
              right: 0,
              child: Transform.rotate(
                angle: _rad(9),
                child: _Photo(url: back, width: backW, height: backH),
              ),
            ),
            // Front photo — larger, tilted the other way, lower-left.
            Positioned(
              top: h * 0.20,
              left: 0,
              child: Transform.rotate(
                angle: _rad(-5),
                child: _Photo(url: front, width: frontW, height: frontH),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.url, required this.width, required this.height});

  final String url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: NetworkImageWithFallback(url: url),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.onSkip, required this.onNext});

  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: [
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            ),
            child: Text(
              'Skip',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
          const Spacer(),
          Material(
            color: AppColors.surface,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onNext,
              child: const SizedBox(
                width: 62,
                height: 62,
                child: Icon(Icons.chevron_right,
                    color: AppColors.textPrimary, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.copper : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
