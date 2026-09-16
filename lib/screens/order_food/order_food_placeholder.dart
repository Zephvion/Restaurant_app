import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Placeholder for the "Order Food" flow.
///
/// The full Order Food screens will be built once the next set of Figma
/// designs is provided. This keeps the Order Food card on the home screen
/// tappable and the navigation flow complete in the meantime.
class OrderFoodPlaceholder extends StatelessWidget {
  const OrderFoodPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Order Food')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.restaurant_menu,
                  size: 56, color: AppColors.copper),
              const SizedBox(height: 20),
              Text(
                'Order Food',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'This flow is ready to be built from the next set of designs.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
