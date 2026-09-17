import 'package:flutter/material.dart';

import '../models/dish.dart';
import '../theme/app_colors.dart';
import 'add_button.dart';
import 'network_image_with_fallback.dart';
import 'nutrition_badge.dart';
import 'price_text.dart';

/// The large horizontal card used in the "Frequent order" rail:
/// photo on top, then name, nutrition badges and a price + add row.
class FeaturedDishCard extends StatelessWidget {
  const FeaturedDishCard({
    super.key,
    required this.dish,
    required this.onTap,
    required this.onAdd,
    this.inCart = false,
    this.width = 190,
  });

  final Dish dish;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final bool inCart;
  final double width;

  @override
  Widget build(BuildContext context) {
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
                height: 124,
                width: double.infinity,
                child: NetworkImageWithFallback(url: dish.imageUrl),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DishBadges(dish: dish),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PriceText(price: dish.price, size: 16),
                        AddCircleButton(onTap: onAdd, inCart: inCart),
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

/// The card used in the "Recommended Breakfast" rail: photo on top and a
/// centred name / price / badges / add column below.
class RecommendedDishCard extends StatelessWidget {
  const RecommendedDishCard({
    super.key,
    required this.dish,
    required this.onTap,
    required this.onAdd,
    this.inCart = false,
    this.width = 175,
  });

  final Dish dish;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final bool inCart;
  final double width;

  @override
  Widget build(BuildContext context) {
    final title = dish.subtitle == null ? dish.name : '${dish.name} - ${dish.subtitle}';
    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 120,
                width: double.infinity,
                child: NetworkImageWithFallback(url: dish.imageUrl),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
                child: Column(
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    PriceText(price: dish.price, size: 15),
                    const SizedBox(height: 8),
                    DishBadges(dish: dish),
                    const SizedBox(height: 12),
                    AddCircleButton(onTap: onAdd, inCart: inCart, size: 32),
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
