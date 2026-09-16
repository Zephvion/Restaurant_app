import 'package:flutter/material.dart';

import '../../data/food_planner_assets.dart';
import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';

/// Tab 1: Track order screen in the Food Planner matching Food planner Track order.png and track order-1.png.
class FoodPlannerTrackView extends StatefulWidget {
  const FoodPlannerTrackView({super.key});

  @override
  State<FoodPlannerTrackView> createState() => _FoodPlannerTrackViewState();
}

class _FoodPlannerTrackViewState extends State<FoodPlannerTrackView> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FoodPlannerController.instance,
      builder: (context, _) {
        final order = FoodPlannerController.instance.activeTrackOrder;

        return Stack(
          children: [
            // ── Dark Styled Route Map Canvas ──────────────────────────────
            const _TrackMapBackground(),
            // ── Back Button Top ───────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                  onPressed: () {
                    FoodPlannerController.instance.setActiveTab(0);
                  },
                ),
              ),
            ),
            // ── Expandable Bottom Sheet ───────────────────────────────────
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                constraints: BoxConstraints(
                  maxHeight: _isExpanded
                      ? MediaQuery.of(context).size.height * 0.72
                      : 210,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  children: [
                    // Expand/collapse chevron
                    Center(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _isExpanded = !_isExpanded),
                        child: Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          color: AppColors.textSecondary,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Estimated delivery',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${order.etaMins}:00 ',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(
                            text: 'mins\nremaining',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ── 3-Step Progress Stepper ───────────────────────────
                    const _ProgressStepper(),
                    if (_isExpanded) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(color: AppColors.border),
                      ),
                      // ── Delivery Partner ────────────────────────────────
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: Image.asset(
                                FoodPlannerAssets.driverJohn,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.person),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.driverName,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                order.driverPhone,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.phone,
                                color: AppColors.accentRed, size: 22),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Calling ${order.driverName}...'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // ── Order Details Rows ───────────────────────────────
                      _detailRow('Order ID', order.orderId),
                      const SizedBox(height: 14),
                      _detailRow('Payment', order.paymentLabel),
                      const SizedBox(height: 14),
                      _detailRow('Delivery time', order.deliveryTimeWindow),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Divider(color: AppColors.border),
                      ),
                      // ── My Order Breakdown ───────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Order',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${order.items.length} items',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.quantity} x  ${item.name}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '₹ ${item.price.toInt()}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sub Total',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13)),
                          Text('₹ ${order.subtotal.toInt()}',
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery fee',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13)),
                          Text('₹ ${order.deliveryFee.toInt()}',
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '₹ ${order.grandTotal.toInt()}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Progress Stepper ──────────────────────────────────────────────────────────

class _ProgressStepper extends StatelessWidget {
  const _ProgressStepper();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _step(label: 'Order accepted', done: true),
        _divider(done: true),
        _step(label: 'Taken', done: true),
        _divider(done: false),
        _step(label: 'Done', done: false),
      ],
    );
  }

  Widget _step({required String label, required bool done}) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? const Color(0xFF4CAF50) : AppColors.surfaceLight,
          ),
          child: Icon(
            Icons.check,
            size: 14,
            color: done ? Colors.white : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: done ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 10,
            fontWeight: done ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _divider({required bool done}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          color: done ? const Color(0xFF4CAF50) : AppColors.surfaceLight,
        ),
      ),
    );
  }
}

// ── Track Map Background ──────────────────────────────────────────────────────

class _TrackMapBackground extends StatelessWidget {
  const _TrackMapBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1B1D1F),
      child: CustomPaint(
        size: Size.infinite,
        painter: _MapPainter(),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFF282A2D)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final routePaint = Paint()
      ..color = AppColors.accentRed
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dashedPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Background road network lines
    final path1 = Path()
      ..moveTo(0, size.height * 0.2)
      ..cubicTo(size.width * 0.4, size.height * 0.15, size.width * 0.6,
          size.height * 0.3, size.width, size.height * 0.25);
    canvas.drawPath(path1, roadPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.3, 0)
      ..lineTo(size.width * 0.35, size.height * 0.6)
      ..lineTo(size.width * 0.6, size.height);
    canvas.drawPath(path2, roadPaint);

    // Active route line in red
    final route = Path()
      ..moveTo(size.width * 0.68, size.height * 0.42)
      ..lineTo(size.width * 0.7, size.height * 0.32)
      ..lineTo(size.width * 0.68, size.height * 0.22)
      ..lineTo(size.width * 0.72, size.height * 0.16);
    canvas.drawPath(route, routePaint);

    // Dashed remainder route to home
    final dashedRoute = Path()
      ..moveTo(size.width * 0.72, size.height * 0.16)
      ..cubicTo(size.width * 0.5, size.height * 0.14, size.width * 0.2,
          size.height * 0.18, size.width * 0.3, size.height * 0.35);
    canvas.drawPath(dashedRoute, dashedPaint);

    // Restaurant Marker (Red Cutlery)
    final restPaint = Paint()..color = AppColors.accentRed;
    canvas.drawCircle(
        Offset(size.width * 0.68, size.height * 0.42), 12, restPaint);

    // Scooter Driver Marker (Red Circle with white dot)
    final scooterPaint = Paint()..color = AppColors.accentRed;
    canvas.drawCircle(
        Offset(size.width * 0.72, size.height * 0.16), 8, scooterPaint);

    // Home Marker (White circle)
    final homePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
        Offset(size.width * 0.3, size.height * 0.35), 8, homePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
