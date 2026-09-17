import 'package:flutter/material.dart';

import '../models/dish.dart';
import '../theme/app_colors.dart';

/// A tiny pill showing a nutrition figure — a flame + "320 kcal" or a
/// scale + "300 gm" — used on dish cards and the product screen.
class NutritionBadge extends StatelessWidget {
  const NutritionBadge({
    super.key,
    required this.icon,
    required this.label,
    this.compact = true,
  });

  final IconData icon;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: compact ? 12 : 15, color: AppColors.copper),
        SizedBox(width: compact ? 3 : 5),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: compact ? 10.5 : 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Convenience widget: the kcal + grams badges for a [Dish], laid out in a row.
class DishBadges extends StatelessWidget {
  const DishBadges({super.key, required this.dish, this.compact = true});

  final Dish dish;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: compact ? 8 : 14,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        NutritionBadge(
          icon: Icons.local_fire_department_outlined,
          label: '${dish.kcal} kcal',
          compact: compact,
        ),
        NutritionBadge(
          icon: Icons.scale_outlined,
          label: '${dish.grams} gm',
          compact: compact,
        ),
      ],
    );
  }
}
