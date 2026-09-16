import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../state/catering_controller.dart';
import '../../theme/app_colors.dart';

/// Success overlay displayed after submitting a catering order.
/// Shows animated green checkmark with confetti and order ID.
class CateringSuccessScreen extends StatefulWidget {
  const CateringSuccessScreen({super.key});

  @override
  State<CateringSuccessScreen> createState() => _CateringSuccessScreenState();
}

class _CateringSuccessScreenState extends State<CateringSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _close() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.cateringDashboard,
      (route) => route.settings.name == AppRoutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    final latestOrder = CateringController.instance.orders.isNotEmpty
        ? CateringController.instance.orders.first
        : null;
    final orderId = latestOrder?.id ?? 'ID4578';

    return Scaffold(
      backgroundColor: AppColors.background.withValues(alpha: 0.94),
      body: Stack(
        children: [
          // ── Close button ─────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: _close,
            ),
          ),
          // ── Main content ─────────────────────────────────────────────
          FadeTransition(
            opacity: _fade,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Thank you for placing\nthe order',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // ── Animated checkmark ───────────────────────────────
                  ScaleTransition(
                    scale: _scale,
                    child: const _CheckmarkBurst(),
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    "We'll get in touch with you soon.",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ORDER ID : $orderId',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Checkmark burst ───────────────────────────────────────────────────────────

class _CheckmarkBurst extends StatelessWidget {
  const _CheckmarkBurst();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti dots — teal circles
          ..._dots(),
          // Stars
          ..._stars(),
          // Glow ring
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4CAF50).withValues(alpha: 0.18),
            ),
          ),
          // Green checkmark circle
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF4CAF50),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 44),
          ),
        ],
      ),
    );
  }

  List<Widget> _dots() {
    const teal = Color(0xFF26C6A6);
    const positions = [
      Offset(100, 20),
      Offset(170, 60),
      Offset(180, 130),
      Offset(100, 185),
      Offset(30, 130),
      Offset(20, 60),
    ];
    return positions.map((p) => Positioned(
          left: p.dx,
          top: p.dy,
          child: Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: teal,
            ),
          ),
        )).toList();
  }

  List<Widget> _stars() {
    const orange = Color(0xFFFFA726);
    const positions = [
      Offset(93, 5),
      Offset(180, 42),
      Offset(145, 180),
      Offset(20, 38),
      Offset(15, 148),
    ];
    return positions.map((p) => Positioned(
          left: p.dx,
          top: p.dy,
          child: const _Star(color: orange, size: 14),
        )).toList();
  }
}

class _Star extends StatelessWidget {
  const _Star({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StarPainter(color: color),
    );
  }
}

class _StarPainter extends CustomPainter {
  const _StarPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    const n = 5;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.width / 2;
    final inner = outer * 0.45;

    for (int i = 0; i < n * 2; i++) {
      final r = i.isEven ? outer : inner;
      final angle = (math.pi / n) * i - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.color != color;
}
