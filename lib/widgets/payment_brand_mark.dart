import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A brand mark for a payment method, keyed by [assetKind]
/// ('mastercard', 'visa', 'gpay', 'googlepay', 'phonepe', 'paytm', 'bhim',
/// 'upi', 'wallet', 'netbanking', 'cod', etc.).
///
/// Features authentic real-app symbols for UPI payment providers:
/// - Google Pay: Authentic 4-color Google 'G' on crisp white tile
/// - PhonePe: Official PhonePe purple tile with bold white 'पे'
/// - Paytm: Authentic two-tone 'paytm' mark (navy + cyan)
/// - BHIM UPI: Official BHIM tricolor chevrons + 'BHIM' typography
/// - UPI (NPCI): Official dual-color (green + orange) arrows + italic 'UPI'
class PaymentBrandMark extends StatelessWidget {
  const PaymentBrandMark({super.key, required this.assetKind, this.size = 42});

  final String? assetKind;
  final double size;

  @override
  Widget build(BuildContext context) {
    final kind = (assetKind ?? '').toLowerCase();

    // Provider-specific backgrounds
    Color bgColor;
    BoxBorder? border;

    if (kind == 'phonepe') {
      bgColor = const Color(0xFF5F259F);
      border = null;
    } else if (kind == 'gpay' || kind == 'googlepay') {
      bgColor = Colors.white;
      border = Border.all(color: const Color(0xFFE5E7EB), width: 1.0);
    } else if (kind == 'paytm') {
      bgColor = Colors.white;
      border = Border.all(
        color: const Color(0xFF00BAF2).withValues(alpha: 0.35),
        width: 1.0,
      );
    } else if (kind == 'bhim') {
      bgColor = Colors.white;
      border = Border.all(color: const Color(0xFFE5E7EB), width: 1.0);
    } else if (kind == 'upi') {
      bgColor = Colors.white;
      border = Border.all(color: const Color(0xFFE5E7EB), width: 1.0);
    } else {
      bgColor = AppColors.surface;
      border = Border.all(
        color: AppColors.border.withValues(alpha: 0.5),
        width: 0.8,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 0.24),
        border: border,
        boxShadow: (kind == 'gpay' ||
                kind == 'phonepe' ||
                kind == 'paytm' ||
                kind == 'bhim' ||
                kind == 'upi')
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      child: _mark(kind),
    );
  }

  Widget _mark(String kind) {
    switch (kind) {
      case 'mastercard':
        return SizedBox(
          width: size * 0.5,
          height: size * 0.32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                child: _circle(const Color(0xFFEB001B), size * 0.30),
              ),
              Positioned(
                right: 0,
                child: _circle(const Color(0xFFF79E1B), size * 0.30),
              ),
            ],
          ),
        );

      case 'visa':
        return Text(
          'VISA',
          style: TextStyle(
            color: const Color(0xFF1A1F71),
            fontSize: size * 0.26,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.5,
          ),
        );

      // ── Real Google Pay Symbol ─────────────────────────────────────────────
      case 'gpay':
      case 'googlepay':
        return CustomPaint(
          size: Size(size * 0.56, size * 0.56),
          painter: const _GoogleGPainter(),
        );

      // ── Real PhonePe Symbol ────────────────────────────────────────────────
      case 'phonepe':
        return Center(
          child: Text(
            'पे',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.54,
              fontWeight: FontWeight.w900,
              fontFamily: 'sans-serif',
              height: 1.0,
            ),
          ),
        );

      // ── Real Paytm Symbol ──────────────────────────────────────────────────
      case 'paytm':
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'pay',
              style: TextStyle(
                color: const Color(0xFF002970),
                fontSize: size * 0.28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
                fontFamily: 'sans-serif',
              ),
            ),
            Text(
              'tm',
              style: TextStyle(
                color: const Color(0xFF00BAF2),
                fontSize: size * 0.28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
                fontFamily: 'sans-serif',
              ),
            ),
          ],
        );

      // ── Real BHIM UPI Symbol ───────────────────────────────────────────────
      case 'bhim':
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(size * 0.26, size * 0.42),
              painter: const _BhimChevronPainter(),
            ),
            const SizedBox(width: 2),
            Text(
              'BHIM',
              style: TextStyle(
                color: const Color(0xFF002E6E),
                fontSize: size * 0.22,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: -0.4,
                fontFamily: 'sans-serif',
              ),
            ),
          ],
        );

      // ── Real NPCI UPI Symbol ───────────────────────────────────────────────
      case 'upi':
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(size * 0.24, size * 0.40),
              painter: const _UpiArrowsPainter(),
            ),
            const SizedBox(width: 3),
            Text(
              'UPI',
              style: TextStyle(
                color: const Color(0xFF231F20),
                fontSize: size * 0.28,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: -0.5,
                fontFamily: 'sans-serif',
              ),
            ),
          ],
        );

      case 'wallet':
        return Icon(Icons.account_balance_wallet,
            color: AppColors.copper, size: size * 0.5);

      case 'netbanking':
        return Icon(Icons.account_balance,
            color: AppColors.copper, size: size * 0.5);

      case 'cod':
        return Icon(Icons.payments_outlined,
            color: const Color(0xFF3FA34D), size: size * 0.5);

      default:
        return Icon(Icons.credit_card,
            color: AppColors.textSecondary, size: size * 0.5);
    }
  }

  Widget _circle(Color color, double d) {
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Official 4-color Google "G" logo geometry for Google Pay
class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;
    final strokeWidth = size.width * 0.20;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Red: Top arc (from -135° to -45°)
    arcPaint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -0.75 * math.pi, 0.5 * math.pi, false, arcPaint);

    // Yellow: Left arc (from 135° to 225° / -135°)
    arcPaint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 0.75 * math.pi, 0.5 * math.pi, false, arcPaint);

    // Green: Bottom arc (from 45° to 135°)
    arcPaint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.25 * math.pi, 0.5 * math.pi, false, arcPaint);

    // Blue: Lower-right arc (from 0° to 45°)
    arcPaint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, 0.0, 0.25 * math.pi, false, arcPaint);

    // Blue: Center crossbar from center to right edge
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final barRect = Rect.fromLTWH(
      center.dx - strokeWidth * 0.15,
      center.dy - strokeWidth / 2,
      radius + strokeWidth * 0.65,
      strokeWidth,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Official BHIM dual tricolor chevrons
class _BhimChevronPainter extends CustomPainter {
  const _BhimChevronPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Green slanted chevron (left)
    final greenPath = Path()
      ..moveTo(w * 0.0, h * 0.95)
      ..lineTo(w * 0.40, h * 0.05)
      ..lineTo(w * 0.58, h * 0.05)
      ..lineTo(w * 0.18, h * 0.95)
      ..close();
    canvas.drawPath(greenPath, Paint()..color = const Color(0xFF00843D));

    // Orange slanted chevron (right)
    final orangePath = Path()
      ..moveTo(w * 0.38, h * 0.95)
      ..lineTo(w * 0.78, h * 0.05)
      ..lineTo(w * 0.96, h * 0.05)
      ..lineTo(w * 0.56, h * 0.95)
      ..close();
    canvas.drawPath(orangePath, Paint()..color = const Color(0xFFF37021));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Official NPCI UPI split directional triangles
class _UpiArrowsPainter extends CustomPainter {
  const _UpiArrowsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Top green triangle pointing right
    final greenPath = Path()
      ..moveTo(w * 0.05, h * 0.05)
      ..lineTo(w * 0.95, h * 0.42)
      ..lineTo(w * 0.38, h * 0.42)
      ..close();
    canvas.drawPath(greenPath, Paint()..color = const Color(0xFF097939));

    // Bottom orange triangle pointing right
    final orangePath = Path()
      ..moveTo(w * 0.20, h * 0.58)
      ..lineTo(w * 0.78, h * 0.58)
      ..lineTo(w * 0.05, h * 0.95)
      ..close();
    canvas.drawPath(orangePath, Paint()..color = const Color(0xFFED5B23));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
