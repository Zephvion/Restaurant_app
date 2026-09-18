import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The floating bar that appears at the bottom of the menu once something is in
/// the basket: "🛒  N items added to basket" on the left, a NEXT button on the
/// right. Tapping NEXT opens the cart.
class BasketBar extends StatelessWidget {
  const BasketBar({
    super.key,
    required this.itemCount,
    required this.onNext,
    this.label = 'NEXT',
  });

  final int itemCount;
  final VoidCallback onNext;
  final String label;

  @override
  Widget build(BuildContext context) {
    final noun = itemCount == 1 ? 'Item' : 'Items';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.shopping_cart_outlined,
                color: AppColors.copper, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$itemCount $noun added',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onNext,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 9),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
