import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Formats a rupee amount without trailing ".0" (e.g. 80 → "₹80", 92.5 → "₹92.5").
String formatRupees(double amount) {
  if (amount == amount.roundToDouble()) {
    return '₹${amount.toInt()}';
  }
  return '₹${amount.toStringAsFixed(2)}';
}

/// Shows a current price and, optionally, a struck-through original price to
/// its right (e.g. **₹80**  ~~₹100~~).
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.price,
    this.oldPrice,
    this.size = 16,
    this.color = AppColors.textPrimary,
  });

  final double price;
  final double? oldPrice;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          formatRupees(price),
          style: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (oldPrice != null && oldPrice! > price) ...[
          const SizedBox(width: 6),
          Text(
            formatRupees(oldPrice!),
            style: TextStyle(
              color: AppColors.hint,
              fontSize: size * 0.8,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.hint,
            ),
          ),
        ],
      ],
    );
  }
}
