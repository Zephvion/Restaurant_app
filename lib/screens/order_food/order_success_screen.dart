import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../state/cart_controller.dart';
import '../../theme/app_colors.dart';

/// Order confirmation screen: a celebratory green check with confetti, the
/// "Your order is placed" message and a Track order button. Placing the order
/// clears the basket.
class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    // Placing the order empties the basket.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CartController.instance.clear();
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.foodHome,
      (route) => route.settings.name == AppRoutes.home || route.isFirst,
    );
  }

  void _track() {
    final orderId = ModalRoute.of(context)?.settings.arguments as String?;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.trackOrder,
      (route) => route.settings.name == AppRoutes.home || route.isFirst,
      arguments: orderId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.textPrimary),
                onPressed: _close,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Faint cutlery watermark.
                  Icon(
                    Icons.restaurant,
                    size: 150,
                    color: AppColors.surfaceLight.withOpacity(0.4),
                  ),
                  // Confetti.
                  const Positioned.fill(child: _Confetti()),
                  // Animated green check.
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 108,
                      height: 108,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3FA34D),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 64),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            Text(
              'Success',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            const Text(
              'Your order is placed',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Material(
                  color: AppColors.copper,
                  borderRadius: BorderRadius.circular(30),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _track,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.location_on, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Track order',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A scatter of small festive shapes around the check mark.
class _Confetti extends StatelessWidget {
  const _Confetti();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ConfettiPainter());
  }
}

class _ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rand = math.Random(7);
    const colors = [
      Color(0xFFF5B942), // amber
      Color(0xFF3FA34D), // green
      AppColors.accentRed,
      AppColors.copper,
    ];

    for (var i = 0; i < 26; i++) {
      final angle = rand.nextDouble() * 2 * math.pi;
      final radius = 78 + rand.nextDouble() * 42;
      final pos = center +
          Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      final color = colors[i % colors.length];
      final paint = Paint()..color = color;

      if (i % 3 == 0) {
        // Small star-ish dot.
        canvas.drawCircle(pos, 3.2, paint);
      } else if (i % 3 == 1) {
        // Short dash.
        paint
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
        final d = Offset(math.cos(angle), math.sin(angle)) * 7;
        canvas.drawLine(pos - d, pos + d, paint);
      } else {
        // Tiny square.
        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(angle);
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: 6, height: 6),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
