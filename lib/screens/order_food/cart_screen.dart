import 'package:flutter/material.dart';

import '../../models/restaurant.dart';
import '../../routes/app_routes.dart';
import '../../state/app_mode_controller.dart';
import '../../state/cart_controller.dart';
import '../../state/takeaway_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/address_picker_sheet.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/checkout_widgets.dart';
import '../../widgets/coupon_sheet.dart';
import '../../widgets/price_text.dart';
import '../../widgets/primary_button.dart';

/// Cart screen — an order summary with fulfillment options (Delivery vs Take Away
/// in Global Cart only), address/pickup info, and price breakdown.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.isGlobal});

  /// If provided, explicitly controls whether this screen operates as the Global Cart.
  /// If null, checks `ModalRoute.of(context)?.settings.arguments['isGlobal']`.
  final bool? isGlobal;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _modeInitialized = false;

  bool _checkIsGlobal(BuildContext context) {
    if (widget.isGlobal != null) return widget.isGlobal!;
    final args = ModalRoute.of(context)?.settings.arguments;
    return (args is Map && args['isGlobal'] == true);
  }

  bool _checkIsTakeaway(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    return (args is Map && args['isTakeaway'] == true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_modeInitialized) {
      _modeInitialized = true;
      final isGlobal = _checkIsGlobal(context);
      final isTakeaway = _checkIsTakeaway(context);
      if (isTakeaway) {
        AppModeController.instance.setMode(AppMode.takeAway);
      } else if (!isGlobal && AppModeController.instance.isTakeAway) {
        AppModeController.instance.setMode(AppMode.orderFood);
      }
    }
  }

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

  void _editAddress(BuildContext context) {
    AddressPickerSheet.show(
      context: context,
      onAddressSelected: (addr) => CartController.instance.selectAddress(addr),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;
    final modeCtrl = AppModeController.instance;
    final isGlobal = _checkIsGlobal(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isGlobal ? 'My Cart' : (modeCtrl.isTakeAway ? 'Takeaway Cart' : 'Cart')),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([cart, modeCtrl, TakeawayController.instance]),
        builder: (context, _) {
          if (cart.isEmpty) return const _EmptyCart();

          final isTakeaway = modeCtrl.isTakeAway;
          final takeawayRest = TakeawayController.instance.activeRestaurant;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              // ── Global Cart Fulfillment Selector (Delivery vs Take Away) ──
              // Rendered ONLY in Global Cart, NEVER in inside food or takeaway carts
              if (isGlobal)
                _buildFulfillmentSelector(context, isTakeaway),

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

                    // ── Address Row or Pickup Store Row ────────────────────
                    if (isTakeaway)
                      _TakeawayPickupRow(
                        restaurant: takeawayRest,
                        onChangeStore: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.takeawaySelectRestaurant,
                          );
                        },
                      )
                    else
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
              const SizedBox(height: 16),
              // ── Coupons & Offers ─────────────────────────────────
              _CartCouponRow(
                appliedCoupon: cart.appliedCoupon,
                discount: cart.discount,
                onTap: () => CouponSheet.show(context),
              ),
              const SizedBox(height: 16),
              RoundedPanel(
                child: Column(
                  children: [
                    PriceLine(label: 'Subtotal', value: cart.subtotal),
                    const SizedBox(height: 12),
                    PriceLine(label: 'GST', value: cart.gst),
                    const SizedBox(height: 12),

                    // ── Delivery Fee breakdown ────────────────────────────
                    if (isTakeaway)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Delivery fee (Takeaway)',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'FREE',
                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      PriceLine(
                        label: 'Delivery partner fee for 8km',
                        value: cart.deliveryFee,
                      ),

                    if (cart.discount > 0) ...[
                      const SizedBox(height: 12),
                      PriceLine(
                        label: 'Discount',
                        value: -cart.discount,
                        valueColor: const Color(0xFF3FA34D),
                      ),
                    ],
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
                label: isTakeaway ? 'Proceed to Takeaway' : 'Order Now',
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

  /// Interactive Delivery vs Take Away option selector rendered strictly in Global Cart.
  Widget _buildFulfillmentSelector(BuildContext context, bool isTakeaway) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // ── Delivery Option ─────────────────────────────────
          Expanded(
            child: _FulfillmentOptionButton(
              label: 'Delivery',
              subtitle: 'To Doorstep',
              icon: Icons.delivery_dining_outlined,
              isSelected: !isTakeaway,
              onTap: () {
                AppModeController.instance.setMode(AppMode.orderFood);
              },
            ),
          ),
          const SizedBox(width: 6),
          // ── Take Away Option ────────────────────────────────
          Expanded(
            child: _FulfillmentOptionButton(
              label: 'Take Away',
              subtitle: 'Direct Pickup',
              icon: Icons.storefront_outlined,
              isSelected: isTakeaway,
              onTap: () {
                AppModeController.instance.setMode(AppMode.takeAway);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Styled selectable fulfillment button (Delivery / Take Away).
class _FulfillmentOptionButton extends StatelessWidget {
  const _FulfillmentOptionButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.copper : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.85)
                          : AppColors.hint,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Store pickup summary row displayed when Take Away is active.
class _TakeawayPickupRow extends StatelessWidget {
  const _TakeawayPickupRow({
    required this.restaurant,
    required this.onChangeStore,
  });

  final Restaurant restaurant;
  final VoidCallback onChangeStore;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.storefront_outlined,
            color: AppColors.copper, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.copper.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PICKUP',
                      style: TextStyle(
                        color: AppColors.copper,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${restaurant.address}, ${restaurant.city}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onChangeStore,
            child: const SizedBox(
              width: 30,
              height: 30,
              child: Icon(Icons.edit_outlined,
                  size: 15, color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
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

class _CartCouponRow extends StatelessWidget {
  const _CartCouponRow({
    required this.appliedCoupon,
    required this.discount,
    required this.onTap,
  });

  final String? appliedCoupon;
  final double discount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasCoupon = appliedCoupon != null;

    return Material(
      color: AppColors.backgroundElevated,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasCoupon
                  ? const Color(0xFF22C55E).withValues(alpha: 0.5)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: hasCoupon
                      ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                      : AppColors.copper.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.discount_outlined,
                  color: hasCoupon ? const Color(0xFF22C55E) : AppColors.copper,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasCoupon
                          ? 'Coupon Applied: $appliedCoupon'
                          : 'Apply Coupon / Promo Code',
                      style: TextStyle(
                        color: hasCoupon
                            ? const Color(0xFF22C55E)
                            : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasCoupon
                          ? 'You are saving ₹${discount.toInt()} on this order!'
                          : 'View available offers & discounts',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                hasCoupon ? 'CHANGE' : 'VIEW',
                style: const TextStyle(
                  color: AppColors.copper,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

