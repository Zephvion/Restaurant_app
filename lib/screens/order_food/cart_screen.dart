import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../state/cart_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/checkout_widgets.dart';
import '../../widgets/price_text.dart';
import '../../widgets/primary_button.dart';

/// Cart screen — an order summary with the delivery address and a totals
/// breakdown, ending in ORDER NOW (which proceeds to billing).
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Cart')),
      body: AnimatedBuilder(
        animation: cart,
        builder: (context, _) {
          if (cart.isEmpty) return const _EmptyCart();
          return ListView(
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
                    for (final item in cart.items) ...[
                      OrderSummaryRow(
                        imageUrl: item.dish.imageUrl,
                        name: item.dish.name,
                        quantity: item.quantity,
                        price: item.dish.price * item.quantity,
                        unitPrice: item.dish.price,
                        onIncrement: () => cart.increment(item.dish),
                        onDecrement: () => cart.decrement(item.dish),
                      ),
                      const SizedBox(height: 14),
                    ],
                    const PanelDivider(),
                    AddressRow(
                      address: cart.selectedAddress.details,
                      onEdit: () => _editAddress(context),
                    ),
                    const PanelDivider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Rate',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        PriceText(price: cart.subtotal, size: 17),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              RoundedPanel(
                child: Column(
                  children: [
                    PriceLine(label: 'Subtotal', value: cart.subtotal),
                    const SizedBox(height: 12),
                    PriceLine(label: 'GST', value: cart.gst),
                    const SizedBox(height: 12),
                    PriceLine(
                        label: 'Delivery partner fee for 8km',
                        value: cart.deliveryFee),
                    const PanelDivider(),
                    PriceLine(
                      label: 'Grand Total',
                      value: cart.grandTotal,
                      emphasized: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Order Now',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.billing),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editAddress(BuildContext context) {
    final cart = CartController.instance;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.backgroundElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deliver to',
                    style: Theme.of(sheetContext).textTheme.titleLarge),
                const SizedBox(height: 16),
                for (final address in MockData.addresses)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          cart.selectAddress(address);
                          Navigator.of(sheetContext).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  color: AppColors.copper),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(address.label,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        )),
                                    const SizedBox(height: 4),
                                    Text(address.details,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 64, color: AppColors.hint),
          const SizedBox(height: 16),
          Text('Your cart is empty',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Add a few dishes to get started.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
