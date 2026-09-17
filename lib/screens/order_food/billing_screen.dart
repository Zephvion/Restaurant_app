import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../state/cart_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/address_picker_sheet.dart';
import '../../widgets/checkout_widgets.dart';
import '../../widgets/price_text.dart';
import '../../widgets/primary_button.dart';

/// Billing screen — order summary, delivery slot, a coupons row and the final
/// totals, ending in PLACE ORDER (which opens the payment options).
class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  static const _coupons = <_Coupon>[
    _Coupon(code: 'WELCOMEBACK', label: '10% off your order'),
    _Coupon(code: 'PARAGON50', label: 'Flat ₹50 off above ₹300'),
    _Coupon(code: 'FREESHIP', label: 'Free delivery on this order'),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Billing')),
      body: AnimatedBuilder(
        animation: cart,
        builder: (context, _) {
          if (cart.isEmpty) {
            return const Center(
              child: Text('Nothing to bill yet.',
                  style: TextStyle(color: AppColors.textSecondary)),
            );
          }
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
                      ),
                      const SizedBox(height: 14),
                    ],
                    const PanelDivider(),
                    AddressRow(address: cart.selectedAddress.details),
                    AddressRow(
                      address: cart.selectedAddress.details,
                      onEdit: () {
                        AddressPickerSheet.show(
                          context: context,
                          onAddressSelected: (addr) => cart.selectAddress(addr),
                        );
                      },
                    ),
                    const PanelDivider(),
                    Row(
                      children: const [
                        Icon(Icons.access_time,
                            color: AppColors.textSecondary, size: 18),
                        SizedBox(width: 10),
                        Text(
                          'Breakfast - 7:30 AM',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
              _CouponsRow(
                appliedCoupon: cart.appliedCoupon,
                onTap: () => _showCoupons(context),
              ),
              const SizedBox(height: 16),
              RoundedPanel(
                child: Column(
                  children: [
                    PriceLine(label: 'Subtotal', value: cart.subtotal),
                    const SizedBox(height: 12),
                    PriceLine(label: 'GST', value: cart.gst),
                    const SizedBox(height: 12),
                    PriceLine(label: 'Delivery fee', value: cart.deliveryFee),
                    if (cart.discount > 0) ...[
                      const SizedBox(height: 12),
                      PriceLine(
                        label: 'Coupon discount',
                        value: -cart.discount,
                        valueColor: Color(0xFF3FA34D),
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
                label: 'Place Order',
                onPressed: () => Navigator.of(context)
                    .pushNamed(AppRoutes.paymentOptions),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCoupons(BuildContext context) {
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
                Text('Apply a coupon',
                    style: Theme.of(sheetContext).textTheme.titleLarge),
                const SizedBox(height: 16),
                for (final coupon in _coupons)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          cart.applyCoupon(coupon.code);
                          Navigator.of(sheetContext).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.card_giftcard,
                                  color: AppColors.copper),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(coupon.code,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        )),
                                    const SizedBox(height: 3),
                                    Text(coupon.label,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        )),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (cart.appliedCoupon != null)
                  TextButton(
                    onPressed: () {
                      cart.applyCoupon(null);
                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text('Remove coupon',
                        style: TextStyle(color: AppColors.accentRed)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CouponsRow extends StatelessWidget {
  const _CouponsRow({required this.appliedCoupon, required this.onTap});

  final String? appliedCoupon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundElevated,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              const Icon(Icons.card_giftcard, color: AppColors.copper),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  appliedCoupon == null
                      ? 'Coupons'
                      : 'Coupon applied · $appliedCoupon',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _Coupon {
  const _Coupon({required this.code, required this.label});

  final String code;
  final String label;
}
