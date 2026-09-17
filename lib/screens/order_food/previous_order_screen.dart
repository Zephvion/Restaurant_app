import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/order_model.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/menu_service.dart';
import '../../services/order_service.dart';
import '../../state/cart_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/checkout_widgets.dart';
import '../../widgets/price_text.dart';
import '../../widgets/primary_button.dart';

/// Previous Order — a summary of the user's last order loaded from
/// Firestore OrderService with a re-order action.
class PreviousOrderScreen extends StatefulWidget {
  const PreviousOrderScreen({super.key});

  @override
  State<PreviousOrderScreen> createState() => _PreviousOrderScreenState();
}

class _PreviousOrderScreenState extends State<PreviousOrderScreen> {
  OrderModel? _lastOrder;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreviousOrder();
  }

  Future<void> _loadPreviousOrder() async {
    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';
    final orders = await OrderService.instance.getUserOrders(uid);
    if (mounted) {
      setState(() {
        _lastOrder = orders.isNotEmpty ? orders.first : null;
        _isLoading = false;
      });
    }
  }

  void _reorder(BuildContext context) {
    final cart = CartController.instance;
    if (_lastOrder != null && _lastOrder!.items.isNotEmpty) {
      for (final item in _lastOrder!.items) {
        final dish = MenuService.instance.findDishById(item.dishId) ??
            MockData.dishes.firstWhere(
              (d) => d.id == item.dishId,
              orElse: () => MockData.plainDosa,
            );
        cart.add(dish, qty: item.quantity);
      }
    } else {
      cart.add(MockData.plainDosa);
      cart.add(MockData.meals);
    }
    Navigator.of(context).pushNamed(AppRoutes.cart);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.accentRed)),
      );
    }

    final order = _lastOrder;
    final address = order?.deliveryAddress ?? MockData.addresses.first;
    final subtotal = order?.subtotal ?? 130.0;
    final gst = order?.gst ?? 20.0;
    final fee = order?.deliveryFee ?? 30.0;
    final total = order?.grandTotal ?? 180.0;

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
                if (order != null && order.items.isNotEmpty) ...[
                  for (final item in order.items) ...[
                    OrderSummaryRow(
                      imageUrl: item.imageUrl,
                      name: item.name,
                      quantity: item.quantity,
                      price: item.lineTotal,
                    ),
                    const SizedBox(height: 14),
                  ],
                ] else ...[
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
                ],
                const PanelDivider(),
                AddressRow(address: address.details),
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
                    PriceText(price: subtotal, size: 17),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          RoundedPanel(
            child: Column(
              children: [
                PriceLine(label: 'Subtotal', value: subtotal),
                const SizedBox(height: 12),
                PriceLine(label: 'GST', value: gst),
                const SizedBox(height: 12),
                PriceLine(label: 'Delivery partner fee for 8km', value: fee),
                const PanelDivider(),
                PriceLine(label: 'Grand Total', value: total, emphasized: true),
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
}
