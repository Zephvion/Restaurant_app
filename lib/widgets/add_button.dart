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
