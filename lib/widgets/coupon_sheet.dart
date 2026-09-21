import 'package:flutter/material.dart';

import '../state/cart_controller.dart';
import '../theme/app_colors.dart';
import 'app_banner.dart';

class CouponItem {
  const CouponItem({
    required this.code,
    required this.label,
    required this.description,
    this.minOrder = 0,
  });

  final String code;
  final String label;
  final String description;
  final double minOrder;
}

/// A production-ready coupon selection & custom code entry modal bottom sheet.
class CouponSheet extends StatefulWidget {
  const CouponSheet({super.key});

  static const List<CouponItem> availableCoupons = [
    CouponItem(
      code: 'WELCOMEBACK',
      label: '10% OFF',
      description: 'Get 10% off on your entire food order.',
    ),
    CouponItem(
      code: 'PARAGON50',
      label: 'FLAT ₹50 OFF',
      description: 'Flat ₹50 instant discount on orders above ₹300.',
      minOrder: 300,
    ),
    CouponItem(
      code: 'FREESHIP',
      label: 'FREE DELIVERY',
      description: '100% waiver on doorstep delivery fees.',
    ),
    CouponItem(
      code: 'PARAGONSPECIAL',
      label: '15% SPECIAL',
      description: 'Exclusive 15% discount for Paragon food lovers.',
      minOrder: 500,
    ),
  ];

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CouponSheet(),
    );
  }

  @override
  State<CouponSheet> createState() => _CouponSheetState();
}

class _CouponSheetState extends State<CouponSheet> {
  final TextEditingController _codeCtrl = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _applyCode(String inputCode) {
    final code = inputCode.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter a valid coupon code.');
      return;
    }

    final cart = CartController.instance;
    // Check if minimum order constraint applies
    final match = CouponSheet.availableCoupons.where((c) => c.code == code).firstOrNull;
    if (match != null && match.minOrder > 0 && cart.subtotal < match.minOrder) {
      setState(() {
        _errorMessage = 'Requires minimum order of ₹${match.minOrder.toInt()}.';
      });
      return;
    }

    cart.applyCoupon(code);
    Navigator.of(context).pop();
    AppToast.showSuccess(
      context,
      'Coupon "$code" applied! Saved ₹${cart.discount.toInt()}.',
      title: 'Coupon Applied',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;
    final applied = cart.appliedCoupon;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border, width: 1.2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.copper.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.discount_outlined,
                      color: AppColors.copper, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Coupons & Offers',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Custom coupon input field
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _errorMessage != null
                      ? AppColors.accentRed
                      : AppColors.border,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'ENTER COUPON CODE',
                        hintStyle: TextStyle(
                          color: AppColors.hint,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (_) {
                        if (_errorMessage != null) {
                          setState(() => _errorMessage = null);
                        }
                      },
                      onSubmitted: _applyCode,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _applyCode(_codeCtrl.text),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.copper,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                    child: const Text('APPLY'),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.accentRed, fontSize: 12),
              ),
            ],

            const SizedBox(height: 18),
            const Text(
              'Available Coupons',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Pre-configured coupons list
            for (final coupon in CouponSheet.availableCoupons) ...[
              _CouponTile(
                coupon: coupon,
                isApplied: applied == coupon.code,
                onApply: () => _applyCode(coupon.code),
              ),
              const SizedBox(height: 10),
            ],

            if (applied != null) ...[
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    cart.applyCoupon(null);
                    Navigator.of(context).pop();
                    AppToast.showInfo(context, 'Coupon removed');
                  },
                  icon: const Icon(Icons.close_rounded,
                      size: 16, color: AppColors.accentRed),
                  label: const Text(
                    'Remove Active Coupon',
                    style: TextStyle(
                      color: AppColors.accentRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CouponTile extends StatelessWidget {
  const _CouponTile({
    required this.coupon,
    required this.isApplied,
    required this.onApply,
  });

  final CouponItem coupon;
  final bool isApplied;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isApplied ? AppColors.copper : AppColors.border,
          width: isApplied ? 1.4 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.copper.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        coupon.code,
                        style: const TextStyle(
                          color: AppColors.copper,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      coupon.label,
                      style: const TextStyle(
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  coupon.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isApplied)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'APPLIED',
                style: TextStyle(
                  color: Color(0xFF22C55E),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            )
          else
            OutlinedButton(
              onPressed: onApply,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.copper,
                side: const BorderSide(color: AppColors.copper),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                minimumSize: const Size(60, 34),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'APPLY',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

