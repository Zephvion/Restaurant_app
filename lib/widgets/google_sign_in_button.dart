import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The "Sign in with google" / "Login with google" row from the Figma.
/// A centered, tappable row with a multi-color Google "G" and a label.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GoogleLogo(size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A hand-painted approximation of the Google "G" logo (four-color ring + bar).
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static const Color _blue = Color(0xFF4285F4);
  static const Color _red = Color(0xFFEA4335);
  static const Color _yellow = Color(0xFFFBBC05);
  static const Color _green = Color(0xFF34A853);

  double _rad(double deg) => deg * math.pi / 180.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.34;
    final stroke = size.width * 0.20;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Angles: 0deg = 3 o'clock, positive = clockwise (y-down canvas).
    // Red across the top, blue down the upper-right, green the bottom,
    // yellow the left. A gap on the lower-right is filled by the crossbar.
    canvas.drawArc(rect, _rad(225), _rad(90), false, arc..color = _red);
    canvas.drawArc(rect, _rad(315), _rad(45), false, arc..color = _blue);
    canvas.drawArc(rect, _rad(45), _rad(90), false, arc..color = _green);
    canvas.drawArc(rect, _rad(135), _rad(90), false, arc..color = _yellow);

    // Blue crossbar of the "G": horizontal, from center toward the right edge.
    final barHeight = stroke;
    final barRect = Rect.fromLTWH(
      center.dx + radius * 0.02,
      center.dy - barHeight / 2,
      radius + stroke / 2,
      barHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        barRect,
        topLeft: Radius.circular(barHeight / 2),
        bottomLeft: Radius.circular(barHeight / 2),
      ),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
