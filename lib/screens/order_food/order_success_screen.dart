import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/session_manager.dart';
import '../../state/cart_controller.dart';
import '../../theme/app_colors.dart';

/// Order confirmation screen: a celebratory green check with confetti, the
/// "Your order is placed" message, automatic redirection to the live delivery tracking
/// page with a visual countdown timer, and dual navigation buttons.
/// Matches Figma design.
class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  Timer? _redirectTimer;
  int _secondsRemaining = 3;
  static const int _totalSeconds = 3;
  String? _orderId;

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

    _startAutoRedirect();
  }

  void _startAutoRedirect() {
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        _trackOrder();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orderId ??= (ModalRoute.of(context)?.settings.arguments as String?) ??
        SessionManager.instance.activeOrderId;
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _redirectToDashboard() {
    _redirectTimer?.cancel();
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  void _trackOrder() {
    _redirectTimer?.cancel();
    if (!mounted) return;
    final orderId = _orderId ??
        (ModalRoute.of(context)?.settings.arguments as String?) ??
        SessionManager.instance.activeOrderId;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.trackOrder,
      (route) => route.settings.name == AppRoutes.home || route.isFirst,
      arguments: orderId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderId = _orderId ??
        (ModalRoute.of(context)?.settings.arguments as String?) ??
        SessionManager.instance.activeOrderId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: _redirectToDashboard,
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Cutlery watermark background
                    Icon(
                      Icons.restaurant,
                      size: 130,
                      color: AppColors.surfaceLight.withValues(alpha: 0.35),
                    ),
                    // Confetti particles
                    const Positioned.fill(child: _Confetti()),
                    // Animated green check
                    ScaleTransition(
                      scale: _scale,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3FA34D),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 56,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Success',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your order is placed',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              if (orderId != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'ORDER ID: #$orderId',
                    style: const TextStyle(
                      color: AppColors.copper,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              // Automatic redirection countdown badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.copper.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        value: (_totalSeconds - _secondsRemaining + 1) /
                            _totalSeconds.toDouble(),
                        strokeWidth: 2.2,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.copper,
                        ),
                        backgroundColor: AppColors.border,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Redirecting to delivery tracking in ${_secondsRemaining}s...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),

              // ── Dual Redirection Buttons ─────────────────────────────────
              // 1. Track Order Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.copper,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.location_on_rounded, size: 20),
                  label: Text(
                    'TRACK ORDER (${_secondsRemaining}s)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  onPressed: _trackOrder,
                ),
              ),
              const SizedBox(height: 12),

              // 2. Redirect to Dashboard Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  icon: const Icon(Icons.dashboard_outlined, size: 20),
                  label: const Text(
                    'REDIRECT TO DASHBOARD',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  onPressed: _redirectToDashboard,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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
      final radius = 72 + rand.nextDouble() * 38;
      final pos = center +
          Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      final color = colors[i % colors.length];
      final paint = Paint()..color = color;

      if (i % 3 == 0) {
        canvas.drawCircle(pos, 3.0, paint);
      } else if (i % 3 == 1) {
        paint
          ..strokeWidth = 2.8
          ..strokeCap = StrokeCap.round;
        final d = Offset(math.cos(angle), math.sin(angle)) * 6;
        canvas.drawLine(pos - d, pos + d, paint);
      } else {
        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(angle);
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: 5.5, height: 5.5),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
