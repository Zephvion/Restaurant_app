import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/order_model.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/menu_service.dart';
import '../../services/order_service.dart';
import '../../state/cart_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/checkout_widgets.dart';
import '../../widgets/order_cancellation_sheet.dart';
import '../../widgets/price_text.dart';

/// Previous Order — a summary of the user's last order loaded from
/// Firestore OrderService with a re-order action.
class PreviousOrderScreen extends StatefulWidget {
  const PreviousOrderScreen({super.key});

  @override
  State<PreviousOrderScreen> createState() => _PreviousOrderScreenState();
}

class _PreviousOrderScreenState extends State<PreviousOrderScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';
    final orders = await OrderService.instance.getUserOrders(uid);
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCancelOrder(BuildContext context, OrderModel order) async {
    await OrderCancellationSheet.show(
      context: context,
      orderId: order.id,
      amount: order.grandTotal,
      paymentMode: order.paymentMethodLabel,
      isTakeaway: false,
      onConfirmCancel: (reason) async {
        await OrderService.instance.cancelOrder(order.id, reason: reason);
        if (mounted) {
          AppToast.showSuccess(
            context,
            'Order #${order.id} cancelled. 100% refund initiated to ${order.paymentMethodLabel}!',
            title: 'Order Cancelled',
          );
          _loadOrders();
        }
      },
    );
  }

  void _reorderOrder(BuildContext context, OrderModel order) {
    final cart = CartController.instance;
    if (order.items.isNotEmpty) {
      for (final item in order.items) {
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Order History')),
      body: _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text(
                    'No previous orders found',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Explore our menu and place your first delicious order!',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maroon,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.foodHome),
                    child: const Text('EXPLORE MENU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              itemCount: _orders.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildOrderCard(context, _orders[i]),
              ),
            ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final statusColor = order.status == OrderStatus.delivered
        ? Colors.green
        : (order.status == OrderStatus.cancelled ? Colors.red : AppColors.copper);

    return RoundedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.formattedDate} · ${order.formattedTime} · ${order.items.length} items',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.statusText.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const PanelDivider(),
          for (final item in order.items) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${item.quantity}x',
                    style: const TextStyle(
                      color: AppColors.copper,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  PriceText(price: item.lineTotal, size: 14),
                ],
              ),
            ),
          ],
          const PanelDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount Paid',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              PriceText(price: order.grandTotal, size: 16),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.copper,
                    side: const BorderSide(color: AppColors.copper),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.near_me_outlined, size: 16),
                  label: const Text('Track Order', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.trackOrder,
                      arguments: order.id,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.maroon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.replay_rounded, size: 16),
                  label: const Text('Reorder', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  onPressed: () => _reorderOrder(context, order),
                ),
              ),
            ],
          ),
          if (order.canBeCancelled) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentRed,
                  side: BorderSide(color: AppColors.accentRed.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 15),
                label: const Text('Cancel Order (Instant Refund)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                onPressed: () => _handleCancelOrder(context, order),
              ),
            ),
          ] else if (order.isCancelled) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cancel, color: AppColors.accentRed, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Cancelled: ${order.cancellationReason ?? "Order cancelled"}',
                      style: const TextStyle(
                          color: AppColors.accentRed, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
