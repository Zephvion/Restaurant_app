import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../state/cart_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/address_picker_sheet.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/checkout_widgets.dart';
import '../../widgets/price_text.dart';
import '../../widgets/primary_button.dart';

/// Cart screen — an order summary with the delivery address and a totals
/// breakdown, ending in ORDER NOW (which proceeds to billing).
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _confirmClearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Cancel & Clear Cart?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('NO', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              CartController.instance.clear();
              AppBanner.showInfo(context, 'Cart has been cleared');
            },
            child: const Text('YES, CLEAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          AnimatedBuilder(
            animation: cart,
            builder: (context, _) {
              if (cart.isEmpty) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () => _confirmClearCart(context),
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.accentRed),
                label: const Text(
                  'Clear Cart',
                  style: TextStyle(
                    color: AppColors.accentRed,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _confirmClearCart(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                label: const Text(
                  'Cancel Cart',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editAddress(BuildContext context) {
    AddressPickerSheet.show(
      context: context,
      onAddressSelected: (addr) => CartController.instance.selectAddress(addr),
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
