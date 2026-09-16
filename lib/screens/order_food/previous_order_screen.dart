import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../state/cart_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/checkout_widgets.dart';
import '../../widgets/price_text.dart';
import '../../widgets/primary_button.dart';

/// Previous Order — a read-only summary of the user's last order with a
/// re-order ("ORDER NOW") action that drops the same dishes back into the cart.
class PreviousOrderScreen extends StatelessWidget {
  const PreviousOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final address = MockData.addresses.first;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Previous Order')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          RoundedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order summary',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 16),
                OrderSummaryRow(
                  imageUrl: MockData.plainDosa.imageUrl,
                  name: 'Plain Dosa',
                  quantity: 1,
                  price: 50,
                ),
                const SizedBox(height: 14),
                OrderSummaryRow(
                  imageUrl: MockData.meals.imageUrl,
                  name: 'Meals',
                  quantity: 1,
                  price: 80,
                ),
                const PanelDivider(),
                AddressRow(address: address.details),
                const PanelDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Rate',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    PriceText(price: 130, size: 17),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          RoundedPanel(
            child: Column(
              children: const [
                PriceLine(label: 'Subtotal', value: 130),
                SizedBox(height: 12),
                PriceLine(label: 'GST', value: 20),
                SizedBox(height: 12),
                PriceLine(label: 'Delivery partner fee for 8km', value: 30),
                PanelDivider(),
                PriceLine(label: 'Grand Total', value: 180, emphasized: true),
              ],
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Order Now',
            onPressed: () => _reorder(context),
          ),
        ],
      ),
    );
  }

  void _reorder(BuildContext context) {
    final cart = CartController.instance;
    cart.add(MockData.plainDosa);
    cart.add(MockData.meals);
    Navigator.of(context).pushNamed(AppRoutes.cart);
  }
}
