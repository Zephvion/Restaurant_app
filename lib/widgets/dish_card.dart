import 'package:flutter/material.dart';

import '../models/dish.dart';
import '../theme/app_colors.dart';
import 'add_button.dart';
import 'network_image_with_fallback.dart';
import 'nutrition_badge.dart';

/// The large horizontal card used in the "Frequent order" rail:
/// photo on top, then name, nutrition badges and a price + add row.
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
    this.width = 190,
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
    final effectiveQuantity = quantity > 0 ? quantity : (inCart ? 1 : 0);

    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 120,
                width: double.infinity,
                child: NetworkImageWithFallback(url: dish.imageUrl),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹ ${dish.price.toInt()}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DishBadges(dish: dish),
                    const SizedBox(height: 8),
                    FoodQuantityButton(
                      quantity: effectiveQuantity,
                      onAdd: onAdd,
                      onIncrement: onIncrement ?? onAdd,
                      onDecrement: onDecrement ?? () {},
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

/// The card used in the "Recommended Breakfast" rail: photo on top and a
/// name / price / badges / quantity stepper below.
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
    final title = dish.subtitle == null ? dish.name : '${dish.name} - ${dish.subtitle}';
    final effectiveQuantity = quantity > 0 ? quantity : (inCart ? 1 : 0);

    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 116,
                width: double.infinity,
                child: NetworkImageWithFallback(url: dish.imageUrl),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹ ${dish.price.toInt()}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DishBadges(dish: dish),
                    const SizedBox(height: 8),
                    FoodQuantityButton(
                      quantity: effectiveQuantity,
                      onAdd: onAdd,
                      onIncrement: onIncrement ?? onAdd,
                      onDecrement: onDecrement ?? () {},
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
