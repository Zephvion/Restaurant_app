import 'package:flutter/material.dart';

import '../../data/food_planner_assets.dart';
import '../../data/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';

/// Payment options screen for Food Planner matching Payment options.png and Payment options-1.png.
class FoodPlannerPaymentScreen extends StatefulWidget {
  const FoodPlannerPaymentScreen({super.key});

  @override
  State<FoodPlannerPaymentScreen> createState() =>
      _FoodPlannerPaymentScreenState();
}

class _FoodPlannerPaymentScreenState extends State<FoodPlannerPaymentScreen> {
  String _selectedPayment = 'axis_card';

  void _placeOrder() {
    final ctrl = FoodPlannerController.instance;
    ctrl.confirmPlannedMeal(dish: MockData.plainDosa);

    // Show success dialog matching image 1.png
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SuccessDialog(
        onDismiss: () {
          Navigator.of(ctx).pop(); // pop dialog
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.foodPlanner,
            (route) => route.settings.name == AppRoutes.home,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Payment Options',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              // ── Summary Card ──────────────────────────────────────────
              Container(
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
                          child: Image.network(
                            FoodPlannerAssets.dosa,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.restaurant),
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
                                fontSize: 14,
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
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textSecondary),
                        SizedBox(width: 6),
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
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '₹ 92',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ── Coupons ───────────────────────────────────────────────
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
              const SizedBox(height: 24),
              // ── Credit & Debit Cards ──────────────────────────────────
              const Text(
                'Credit & Debit Cards',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _radioRow(
                      id: 'axis_card',
                      title: 'Axis Bank **** **** **** 2453',
                      icon: Icons.credit_card,
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    _radioRow(
                      id: 'hdfc_card',
                      title: 'HDFC Bank **** **** **** 2453',
                      icon: Icons.credit_card,
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    const ListTile(
                      leading: Icon(Icons.add, color: AppColors.textSecondary),
                      title: Text('Add New Card',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // ── UPI ───────────────────────────────────────────────────
              const Text(
                'UPI',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _radioRow(
                      id: 'gpay',
                      title: 'Google Pay',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    _radioRow(
                      id: 'phonepe',
                      title: 'PhonePe',
                      icon: Icons.payment,
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    const ListTile(
                      leading: Icon(Icons.add, color: AppColors.textSecondary),
                      title: Text('Add New UPI ID',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // ── More Payment Options ──────────────────────────────────
              const Text(
                'More Payment Options',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _optionTile(title: 'Wallet', icon: Icons.wallet),
                    const Divider(height: 1, color: AppColors.border),
                    _optionTile(
                        title: 'Net Banking',
                        icon: Icons.account_balance_outlined),
                    const Divider(height: 1, color: AppColors.border),
                    _radioRow(
                      id: 'cod',
                      title: 'Cash on Delivery',
                      icon: Icons.money,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // ── Bottom Action ──────────────────────────────────────────────
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: _placeOrder,
              child: Container(
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
        ],
      ),
    );
  }

  Widget _radioRow({
    required String id,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedPayment == id;
    return ListTile(
      onTap: () => setState(() => _selectedPayment = id),
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      ),
      trailing: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.accentRed : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.accentRed : AppColors.textSecondary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _optionTile({required String title, required IconData icon}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      ),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 14, color: AppColors.textSecondary),
    );
  }
}

// ── Success Dialog matching image 1.png ───────────────────────────────────────

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog({required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background.withValues(alpha: 0.95),
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onDismiss,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Success',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your order is placed',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 48),
                // Layered Checkmark with sparkle dots/stars matching image 1.png
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Sparkle dots & stars
                      const Positioned(
                          top: 4,
                          child: Icon(Icons.star,
                              color: Color(0xFFFF9800), size: 14)),
                      const Positioned(
                          bottom: 4,
                          child: Icon(Icons.star,
                              color: Color(0xFFFF9800), size: 14)),
                      const Positioned(
                          left: 4,
                          child: Icon(Icons.star,
                              color: Color(0xFFFF9800), size: 14)),
                      const Positioned(
                          right: 4,
                          child: Icon(Icons.star,
                              color: Color(0xFFFF9800), size: 14)),
                      // Outer mint halo
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD0F8CE),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Inner vivid green circle with checkmark
                      Container(
                        width: 68,
                        height: 68,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00C853),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 40),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                const Text(
                  'NOTE: Reservation is only for 1 hour',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
