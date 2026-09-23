import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../models/reservation.dart';
import '../../routes/app_routes.dart';
import '../../state/reservation_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/payment_gateway_sheet.dart';

/// Success overlay displayed after confirming a table reservation.
/// Matches Figma design: Animated green checkmark burst with confetti,
/// reservation breakdown, and dual redirection buttons (Redirect to Dashboard vs View Reservations).
class ReservationSuccessScreen extends StatefulWidget {
  const ReservationSuccessScreen({super.key});

  @override
  State<ReservationSuccessScreen> createState() =>
      _ReservationSuccessScreenState();
}

class _ReservationSuccessScreenState extends State<ReservationSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _redirectToDashboard() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  void _viewReservations() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.reserveDashboard,
      (route) => route.settings.name == AppRoutes.home || route.isFirst,
    );
  }

  Future<void> _handlePayAtTable(BuildContext context, Reservation res) async {
    final billAmount = (res.foodBillAmount != null && res.foodBillAmount! > 0)
        ? res.foodBillAmount!
        : 650.0;

    final paymentResult = await PaymentGatewaySheet.show(
      context: context,
      amount: billAmount,
      isTakeaway: false,
    );

    if (paymentResult != null && context.mounted) {
      final txnId = paymentResult['txnId'] ?? 'TXN_${DateTime.now().millisecondsSinceEpoch}';
      final mode = paymentResult['mode'] ?? 'UPI';

      await ReservationController.instance.payAtTable(
        res,
        paymentMethod: mode,
        transactionId: txnId,
      );

      if (context.mounted) {
        AppBanner.showSuccess(
          context,
          'Bill payment of ₹${billAmount.toStringAsFixed(0)} via $mode successful! Table ${res.tableDisplay} is now unlocked and available.',
          title: 'Payment Confirmed & Table Freed',
        );
        _viewReservations();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = ModalRoute.of(context)?.settings.arguments as Reservation?;

    return Scaffold(
      backgroundColor: AppColors.background.withValues(alpha: 0.95),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Top Close button ─────────────────────────────────────────────
            Positioned(
              top: 8,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.textPrimary),
                onPressed: _redirectToDashboard,
              ),
            ),
            // ── Main Content ─────────────────────────────────────────────────
            FadeTransition(
              opacity: _fade,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
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
                      'Your table is reserved',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── Animated checkmark burst ───────────────────────────────
                    ScaleTransition(
                      scale: _scale,
                      child: const _CheckmarkBurst(),
                    ),
                    const SizedBox(height: 32),

                    // ── Reservation Details Card ───────────────────────────────
                    if (res != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Text(
                              res.restaurant.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Table #${res.tableNumber} · ${res.seats} Guests · ${res.timeSlot}',
                              style: const TextStyle(
                                color: AppColors.copper,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'NOTE: Reservation is only for 1 hour',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const Spacer(flex: 3),

                    // ── Action Buttons ─────────────────────────────────────────
                    if (res != null) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.payments_outlined, size: 20),
                          label: Text(
                            res.foodBillAmount != null && res.foodBillAmount! > 0
                                ? 'PAY FOOD BILL AT TABLE (₹${res.foodBillAmount!.toStringAsFixed(0)})'
                                : 'PAY FOOD BILL AT TABLE',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          onPressed: () => _handlePayAtTable(context, res),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // 1. View Reservations
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
                        icon: const Icon(Icons.table_restaurant_rounded, size: 20),
                        label: const Text(
                          'VIEW RESERVATIONS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        onPressed: _viewReservations,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2. Redirect to Dashboard
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
          ],
        ),
      ),
    );
  }
}

// ── Checkmark burst matching Figma ──────────────────────────────────────────

class _CheckmarkBurst extends StatelessWidget {
  const _CheckmarkBurst();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti dots — teal circles
          ..._dots(),
          // Stars
          ..._stars(),
          // Glow ring
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4CAF50).withValues(alpha: 0.18),
            ),
          ),
          // Green checkmark circle
          Container(
            width: 80,
            height: 80,
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
      Offset(90, 16),
      Offset(150, 52),
      Offset(160, 116),
      Offset(90, 165),
      Offset(24, 116),
      Offset(16, 52),
    ];
    return positions
        .map((p) => Positioned(
              left: p.dx,
              top: p.dy,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: teal,
                ),
              ),
            ))
        .toList();
  }

  List<Widget> _stars() {
    const orange = Color(0xFFFFA726);
    const positions = [
      Offset(84, 4),
      Offset(160, 36),
      Offset(130, 160),
      Offset(16, 32),
      Offset(12, 132),
    ];
    return positions
        .map((p) => Positioned(
              left: p.dx,
              top: p.dy,
              child: const _Star(color: orange, size: 13),
            ))
        .toList();
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
