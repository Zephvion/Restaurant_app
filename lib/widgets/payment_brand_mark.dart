import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A small brand mark for a payment method, keyed by [assetKind]
/// ('mastercard', 'visa', 'gpay', 'phonepe', 'upi', 'wallet', 'netbanking',
/// 'cod'). Kept lightweight — simple painted/lettered chips, no external logos.
class PaymentBrandMark extends StatelessWidget {
  const PaymentBrandMark({super.key, required this.assetKind, this.size = 42});

  final String? assetKind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: _mark(),
    );
  }

  Widget _mark() {
    switch (assetKind) {
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
      case 'gpay':
        return Icon(Icons.account_balance_wallet_outlined,
            color: const Color(0xFF4285F4), size: size * 0.5);
      case 'phonepe':
        return Icon(Icons.smartphone,
            color: const Color(0xFF5F259F), size: size * 0.5);
      case 'upi':
        return Icon(Icons.qr_code_2,
            color: const Color(0xFF3FA34D), size: size * 0.55);
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
        color: color.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
    );
  }
}
