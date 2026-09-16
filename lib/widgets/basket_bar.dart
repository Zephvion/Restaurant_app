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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Container(
          height: 62,
          padding: const EdgeInsets.only(left: 18, right: 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.shopping_cart_outlined,
                  color: AppColors.copper, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$itemCount $noun added to basket',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onNext,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
