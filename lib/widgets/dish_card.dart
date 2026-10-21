import 'package:flutter/material.dart';

import '../models/dish.dart';
import 'network_image_with_fallback.dart';

/// Authentic Indian FSSAI dietary indicator (green circle for veg, red triangle for non-veg).
class DietaryIndicator extends StatelessWidget {
  const DietaryIndicator({
    super.key,
    required this.isVeg,
    this.size = 13,
  });

  final bool isVeg;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.center,
      child: isVeg
          ? Container(
              width: size * 0.46,
              height: size * 0.46,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            )
          : CustomPaint(
              size: Size(size * 0.5, size * 0.5),
              painter: _TrianglePainter(color),
            ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Reusable Taco Bell product card with black/dark theme styling:
/// - Dark background: Color(0xFF1E1E23)
/// - Subtle dark border: Color(0xFF303036)
/// - Large food image with ClipRRect(borderRadius: BorderRadius.circular(12))
/// - Metadata row directly beneath image (Veg/Non-Veg, Bestseller tag, green rating pill)
/// - Prominent title in Color(0xFFF5F5F5)
/// - Nutrition line in Color(0xFF9A9AA5)
/// - Bottom row: strikethrough original price + yellow price badge on left, ADD button on right
class TacoBellProductCard extends StatelessWidget {
  const TacoBellProductCard({
    super.key,
    required this.dish,
    required this.onTap,
    required this.onAdd,
    this.onIncrement,
    this.onDecrement,
    this.quantity = 0,
    this.inCart = false,
    this.width,
    this.height,
  });

  final Dish dish;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final int quantity;
  final bool inCart;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final effectiveQuantity = quantity > 0 ? quantity : (inCart ? 1 : 0);

    final cardContent = Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF303036),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Food Image with rounded corners and optional badges
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                SizedBox(
                  height: 114,
                      width: double.infinity,
                      child: NetworkImageWithFallback(
                        url: dish.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (dish.protein >= 15)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A162B).withValues(alpha: 0.92),
                            border: Border.all(
                              color: const Color(0xFFF472B6),
                              width: 0.8,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fitness_center_rounded,
                                size: 9,
                                color: Color(0xFFF472B6),
                              ),
                              SizedBox(width: 3),
                              Text(
                                'HIGH PROTEIN',
                                style: TextStyle(
                                  color: Color(0xFFF472B6),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // 2. Metadata row: Veg/Non-Veg + Bestseller tag + Rating pill
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
                        color: const Color(0xFF10B981).withValues(alpha: 0.35),
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

              // 3. Product Title
              Text(
                dish.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFF5F5F5),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),

              // 4. Macro & Nutrition Info
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
          const Spacer(),

          // 5. Bottom Row: Price on left, ADD button on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Price block
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dish.hasDiscount) ...[
                    Text(
                      '₹${dish.oldPrice!.toInt()}',
                      style: const TextStyle(
                        color: Color(0xFF9A9AA5),
                        fontSize: 10.5,
                        decoration: TextDecoration.lineThrough,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
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
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),

              // ADD button or Stepper
              if (effectiveQuantity == 0)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAdd,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 28,
                      constraints: const BoxConstraints(minWidth: 62),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
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
                Material(
                  color: Colors.transparent,
                  child: Container(
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: onDecrement,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(6),
                          ),
                          child: const SizedBox(
                            width: 22,
                            height: 28,
                            child: Icon(
                              Icons.remove,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            '$effectiveQuantity',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: onIncrement ?? onAdd,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(6),
                          ),
                          child: const SizedBox(
                            width: 22,
                            height: 28,
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
                ),
            ],
          ),
        ],
      ),
    );

    final interactiveCard = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: cardContent,
      ),
    );

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: interactiveCard,
      );
    }

    return interactiveCard;
  }
}

/// The horizontal card used in the "Frequent order" rail.
class FeaturedDishCard extends StatelessWidget {
  const FeaturedDishCard({
    super.key,
    required this.dish,
    required this.onTap,
    required this.onAdd,
    this.onIncrement,
    this.onDecrement,
    this.quantity = 0,
    this.inCart = false,
    this.width = 175,
  });

  final Dish dish;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final int quantity;
  final bool inCart;
  final double width;

  @override
  Widget build(BuildContext context) {
    return TacoBellProductCard(
      dish: dish,
      onTap: onTap,
      onAdd: onAdd,
      onIncrement: onIncrement,
      onDecrement: onDecrement,
      quantity: quantity,
      inCart: inCart,
      width: width,
    );
  }
}

/// The card used in the "Recommended Breakfast" rail.
class RecommendedDishCard extends StatelessWidget {
  const RecommendedDishCard({
    super.key,
    required this.dish,
    required this.onTap,
    required this.onAdd,
    this.onIncrement,
    this.onDecrement,
    this.quantity = 0,
    this.inCart = false,
    this.width = 175,
  });

  final Dish dish;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final int quantity;
  final bool inCart;
  final double width;

  @override
  Widget build(BuildContext context) {
    return TacoBellProductCard(
      dish: dish,
      onTap: onTap,
      onAdd: onAdd,
      onIncrement: onIncrement,
      onDecrement: onDecrement,
      quantity: quantity,
      inCart: inCart,
      width: width,
    );
  }
}
