import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The PARAGON crest used on the splash screen — a copper art-deco emblem
/// (framed sun, rays, clouds and pillars) above the "SINCE 1959" / "PARAGON"
/// wordmark. Painted so it stays crisp at any size and needs no asset file.
class ParagonLogo extends StatelessWidget {
  const ParagonLogo({super.key, this.width = 150, this.color = AppColors.copper});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final emblemHeight = width * 1.35;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: width,
          height: emblemHeight,
          child: CustomPaint(painter: _EmblemPainter(color)),
        ),
        SizedBox(height: width * 0.10),
        _SinceRow(color: color, scale: width / 150),
        SizedBox(height: width * 0.06),
        Text(
          'PARAGON',
          style: TextStyle(
            color: color,
            fontSize: width * 0.16,
            fontWeight: FontWeight.w500,
            letterSpacing: width * 0.055,
          ),
        ),
      ],
    );
  }
}

class _SinceRow extends StatelessWidget {
  const _SinceRow({required this.color, required this.scale});

  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    Widget star = Icon(Icons.star, size: 6 * scale, color: color);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        star,
        SizedBox(width: 6 * scale),
        Text(
          'SINCE 1959',
          style: TextStyle(
            color: color,
            fontSize: 9 * scale,
            letterSpacing: 2 * scale,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(width: 6 * scale),
        star,
      ],
    );
  }
}

class _EmblemPainter extends CustomPainter {
  _EmblemPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, size.width * 0.012)
      ..strokeCap = StrokeCap.round
      ..color = color;

    // Outer rounded-rectangle frame.
    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.16,
        size.height * 0.02,
        size.width * 0.68,
        size.height * 0.96,
      ),
      Radius.circular(size.width * 0.34),
    );
    canvas.drawRRect(frame, stroke);

    final cx = size.width / 2;

    // Sun disc near the top-right, with rays fanning down-left.
    final sunCenter = Offset(size.width * 0.62, size.height * 0.30);
    final sunRadius = size.width * 0.055;
    canvas.drawCircle(sunCenter, sunRadius, Paint()..color = color);

    final rayPaint = Paint()
      ..color = color
      ..strokeWidth = math.max(1.0, size.width * 0.008)
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 11; i++) {
      final angle = _rad(100 + i * 12); // fan toward lower-left
      final start = sunCenter +
          Offset(math.cos(angle), math.sin(angle)) * (sunRadius + size.width * 0.02);
      final end = sunCenter +
          Offset(math.cos(angle), math.sin(angle)) * (sunRadius + size.width * 0.12);
      canvas.drawLine(start, end, rayPaint);
    }

    // Two stylized pillars rising from the clouds.
    _pillar(canvas, Offset(cx - size.width * 0.10, size.height * 0.62),
        size.width * 0.06, size.height * 0.16, stroke);
    _pillar(canvas, Offset(cx + size.width * 0.06, size.height * 0.56),
        size.width * 0.05, size.height * 0.22, stroke);

    // Cloud swirls near the base.
    _cloud(canvas, Offset(cx - size.width * 0.02, size.height * 0.74),
        size.width * 0.20, stroke);
    _cloud(canvas, Offset(cx + size.width * 0.04, size.height * 0.80),
        size.width * 0.14, stroke);
  }

  void _pillar(Canvas canvas, Offset base, double w, double h, Paint p) {
    final path = Path()
      ..moveTo(base.dx - w / 2, base.dy)
      ..lineTo(base.dx - w / 2, base.dy - h + w)
      ..arcToPoint(Offset(base.dx + w / 2, base.dy - h + w),
          radius: Radius.circular(w / 2))
      ..lineTo(base.dx + w / 2, base.dy);
    canvas.drawPath(path, p);
    // Small finial dot on top.
    canvas.drawCircle(
        Offset(base.dx, base.dy - h + w * 0.4), w * 0.18, Paint()..color = color);
  }

  void _cloud(Canvas canvas, Offset center, double width, Paint p) {
    final rect = Rect.fromCenter(
        center: center, width: width, height: width * 0.5);
    // A shallow scalloped arc reading as a stylized cloud/wave.
    canvas.drawArc(rect, _rad(200), _rad(140), false, p);
    final rect2 = Rect.fromCenter(
        center: center.translate(width * 0.28, width * 0.06),
        width: width * 0.6,
        height: width * 0.34);
    canvas.drawArc(rect2, _rad(190), _rad(160), false, p);
  }

  double _rad(double deg) => deg * math.pi / 180.0;

  @override
  bool shouldRepaint(covariant _EmblemPainter oldDelegate) =>
      oldDelegate.color != color;
}
