import 'package:flutter/material.dart';

import '../models/dish.dart';
import '../theme/app_colors.dart';
import 'add_button.dart';
import 'network_image_with_fallback.dart';
import 'nutrition_badge.dart';
import 'price_text.dart';

/// A full-width menu row: thumbnail, name (+ "2 nos"), nutrition badges, price
/// and an add button. Used by the "Combination Breakfast" list.
class MenuListTile extends StatelessWidget {
  const MenuListTile({
    super.key,
    required this.dish,
    required this.onTap,
    required this.onAdd,
    this.inCart = false,
  });

  final Dish dish;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final bool inCart;

  @override
  Widget build(BuildContext context) {
    final title =
        dish.subtitle == null ? dish.name : '${dish.name} - ${dish.subtitle}';
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: NetworkImageWithFallback(url: dish.imageUrl),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DishBadges(dish: dish),
                    const SizedBox(height: 8),
                    PriceText(price: dish.price, size: 15),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AddCircleButton(onTap: onAdd, inCart: inCart, size: 36),
            ],
          ),
        ),
      ),
    );
  }
}
