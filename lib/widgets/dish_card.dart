import 'package:flutter/material.dart';

import '../models/dish.dart';
import '../services/favorites_service.dart';
import '../theme/app_colors.dart';
import 'add_button.dart';
import 'app_banner.dart';
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
              Stack(
                children: [
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: NetworkImageWithFallback(url: dish.imageUrl),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: DishFavoriteButton(dishId: dish.id),
                  ),
                ],
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
              Stack(
                children: [
                  SizedBox(
                    height: 104,
                    width: double.infinity,
                    child: NetworkImageWithFallback(url: dish.imageUrl),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: DishFavoriteButton(
                      dishId: dish.id,
                      size: 26,
                      iconSize: 15,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '₹ ${dish.price.toInt()}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    DishBadges(dish: dish),
                    const SizedBox(height: 6),
                    FoodQuantityButton(
                      height: 28,
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

/// Floating circular Heart / Favorite button with animated state feedback.
class DishFavoriteButton extends StatelessWidget {
  const DishFavoriteButton({
    super.key,
    required this.dishId,
    this.size = 28,
    this.iconSize = 16,
  });

  final String dishId;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FavoritesService.instance,
      builder: (context, _) {
        final isFav = FavoritesService.instance.isFavorite(dishId);
        return GestureDetector(
          onTap: () async {
            final nowFav =
                await FavoritesService.instance.toggleFavorite(dishId);
            if (context.mounted) {
              AppToast.showSuccess(
                context,
                nowFav
                    ? 'Saved to your favorites ❤️'
                    : 'Removed from favorites',
                title: nowFav ? 'Favorite Added' : 'Favorite Removed',
              );
            }
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              shape: BoxShape.circle,
              border: Border.all(
                color: isFav
                    ? AppColors.accentRed.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? AppColors.accentRed : Colors.white,
              size: iconSize,
            ),
          ),
        );
      },
    );
  }
}
