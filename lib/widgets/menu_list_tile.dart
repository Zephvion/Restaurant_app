import 'package:flutter/material.dart';

import '../models/dish.dart';
import 'dish_card.dart';
import 'network_image_with_fallback.dart';

/// A menu tile redesigned to match the Taco Bell dark aesthetic:
/// - Dark background: Color(0xFF1E1E23)
/// - Dark border: Color(0xFF303036)
/// - Food image with rounded corners
/// - Dietary indicator + Bestseller badge + Emerald rating badge
/// - Prominent title in Color(0xFFF5F5F5)
/// - Nutrition line in Color(0xFF9A9AA5)
/// - Strikethrough price + Yellow price pill + Green outlined ADD / Stepper
class MenuListTile extends StatelessWidget {
  const MenuListTile({
    super.key,
    required this.dish,
    required this.onTap,
    required this.onAdd,
    this.onIncrement,
    this.onDecrement,
    this.quantity = 0,
    this.inCart = false,
  });

  final Dish dish;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final int quantity;
  final bool inCart;

  @override
  Widget build(BuildContext context) {
    final title =
        dish.subtitle == null ? dish.name : '${dish.name} - ${dish.subtitle}';
    final effectiveQuantity = quantity > 0 ? quantity : (inCart ? 1 : 0);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E23),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF303036),
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Food image with rounded corners
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 82,
                  height: 82,
                  child: NetworkImageWithFallback(
                    url: dish.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Metadata: Veg/Non-Veg + Bestseller + Rating
                    Row(
                      children: [
                        DietaryIndicator(isVeg: dish.isVeg, size: 12),
                        if (dish.rating >= 4.6) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star_outline_rounded,
                            size: 11,
                            color: Color(0xFFEF4444),
                          ),
                          const Text(
                            'Bestseller',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F3826),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.35),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 9,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                dish.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Title
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF5F5F5),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Nutrition
                    Text(
                      dish.protein > 0
                          ? '${dish.protein}g protein • ${dish.kcal} kcal'
                          : '${dish.kcal} kcal • ${dish.grams} gm',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF9A9AA5),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Bottom: Price & ADD Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Price
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (dish.hasDiscount) ...[
                              Text(
                                '₹${dish.oldPrice!.toInt()}',
                                style: const TextStyle(
                                  color: Color(0xFF9A9AA5),
                                  fontSize: 11,
                                  decoration: TextDecoration.lineThrough,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC72C),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '₹${dish.price.toInt()}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ADD Button or Stepper
                        if (effectiveQuantity == 0)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onAdd,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 28,
                                constraints: const BoxConstraints(minWidth: 64),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF10B981),
                                    width: 1.2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'ADD',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            height: 28,
                            constraints: const BoxConstraints(minWidth: 68),
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: onDecrement,
                                  borderRadius: BorderRadius.circular(4),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 3,
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$effectiveQuantity',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                InkWell(
                                  onTap: onIncrement ?? onAdd,
                                  borderRadius: BorderRadius.circular(4),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 3,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
