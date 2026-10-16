import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The small circular "＋" button that adds a dish to the basket, used on the
/// menu cards and list rows. Flips to a filled check briefly when [inCart].
class AddCircleButton extends StatelessWidget {
  const AddCircleButton({
    super.key,
    required this.onTap,
    this.inCart = false,
    this.size = 34,
  });

  final VoidCallback onTap;
  final bool inCart;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: inCart ? AppColors.copper : AppColors.surfaceLight,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            inCart ? Icons.check : Icons.add,
            size: size * 0.6,
            color: inCart ? Colors.white : AppColors.copper,
          ),
        ),
      ),
    );
  }
}

/// A full-width or compact pill button that displays "+ ADD" when [quantity] == 0,
/// and switches to a stepper "[- qty +]" when [quantity] > 0, matching the Takeaway design.
class FoodQuantityButton extends StatelessWidget {
  const FoodQuantityButton({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
    this.width = double.infinity,
    this.height = 32,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height / 2);

    if (quantity == 0) {
      return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: radius),
            elevation: 0,
            padding: EdgeInsets.zero,
          ),
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 14, color: Colors.white),
          label: const Text(
            'ADD',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.accentRed,
        borderRadius: radius,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onDecrement,
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}
