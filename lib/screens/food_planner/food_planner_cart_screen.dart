import 'package:flutter/material.dart';

import '../../data/food_planner_assets.dart';
import '../../routes/app_routes.dart';
import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/network_image_with_fallback.dart';

/// Cart screen for the Food Planner matching Cart.png and Billing 2.png.
class FoodPlannerCartScreen extends StatelessWidget {
  const FoodPlannerCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FoodPlannerController.instance,
      builder: (context, _) {
        final ctrl = FoodPlannerController.instance;
        final mealType = ctrl.currentSlotMealType;
        final slotTime = ctrl.currentSlotTime;
        final subtotal = ctrl.basketSubtotal > 0 ? ctrl.basketSubtotal : 50.0;
        const gst = 12.0;
        const deliveryFee = 30.0;
        final grandTotal = subtotal + gst + deliveryFee;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Cart',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // ── Order Summary Card ──────────────────────────────────────
                _OrderSummaryCard(
                  mealType: mealType.name,
                  timeSlot: slotTime,
                  subtotal: subtotal,
                ),
                const SizedBox(height: 20),
                // ── Coupons ────────────────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Text('🎁', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 14),
                      Text(
                        'Coupons',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios,
                          size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // ── Bill Breakdown Card ─────────────────────────────────────
                _BillBreakdownCard(
                  subtotal: subtotal,
                  gst: gst,
                  deliveryFee: deliveryFee,
                  grandTotal: grandTotal,
                ),
                const Spacer(),
                // ── Proceed to Pay Button ──────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(AppRoutes.foodPlannerPayment);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'PROCEED TO PAY',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Order Summary Card ────────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.mealType,
    required this.timeSlot,
    required this.subtotal,
  });

  final String mealType;
  final String timeSlot;
  final double subtotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                  width: 72,
                  height: 72,
                  child: NetworkImageWithFallback(
                    url: FoodPlannerAssets.dosa,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.restaurant,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order summary',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Plain Dosa',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Qty: 1',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Flat no 9B, Landmark World, Palazhi, Calicut',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                '${mealType[0].toUpperCase()}${mealType.substring(1)} - $timeSlot',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rate',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '₹ ${subtotal.toInt()}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Bill Breakdown Card ───────────────────────────────────────────────────────

class _BillBreakdownCard extends StatelessWidget {
  const _BillBreakdownCard({
    required this.subtotal,
    required this.gst,
    required this.deliveryFee,
    required this.grandTotal,
  });

  final double subtotal;
  final double gst;
  final double deliveryFee;
  final double grandTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              Text('₹ ${subtotal.toInt()}',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('GST',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              Text('₹ ${gst.toInt()}',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery partner fee for 8km',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              Text('₹ ${deliveryFee.toInt()}',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.border),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              Text('₹ ${grandTotal.toInt()}',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
