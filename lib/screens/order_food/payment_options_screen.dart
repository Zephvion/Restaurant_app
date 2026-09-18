import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/payment_method.dart';
import '../../routes/app_routes.dart';
import '../../state/cart_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/checkout_widgets.dart';
import '../../widgets/payment_brand_mark.dart';
import '../../widgets/payment_gateway_sheet.dart';
import '../../widgets/price_text.dart';

/// "Payment Options" — pick a payment method (cards, UPI, Net Banking, Wallet, Cash on Delivery).
/// A PROCEED TO PAY button slides in once a method is selected.
class PaymentOptionsScreen extends StatefulWidget {
  const PaymentOptionsScreen({super.key});

  @override
  State<PaymentOptionsScreen> createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  String? _selectedId;

  late List<PaymentMethod> _cards;
  late List<PaymentMethod> _upi;

  final CartController _cart = CartController.instance;

  static const _netBankingMethod = PaymentMethod(
    id: 'net_banking',
    title: 'Net Banking',
    subtitle: 'All Indian Banks Supported',
    kind: PaymentKind.netBanking,
    assetKind: 'netbanking',
  );

  static const _walletMethod = PaymentMethod(
    id: 'wallet',
    title: 'Digital Wallet',
    subtitle: 'Paytm, PhonePe, Amazon Pay',
    kind: PaymentKind.wallet,
    assetKind: 'wallet',
  );

  @override
  void initState() {
    super.initState();
    _cards = List.of(MockData.cards);
    _upi = List.of(MockData.upi);
    _selectedId = _cards.isNotEmpty
        ? _cards.first.id
        : (_upi.isNotEmpty ? _upi.first.id : MockData.cashOnDelivery.id);
  }

  PaymentMethod? get _selected {
    if (_selectedId == null) {
      return _cards.isNotEmpty ? _cards.first : MockData.cashOnDelivery;
    }
    if (_selectedId == _netBankingMethod.id) return _netBankingMethod;
    if (_selectedId == _walletMethod.id) return _walletMethod;
    for (final m in [..._cards, ..._upi, MockData.cashOnDelivery]) {
      if (m.id == _selectedId) return m;
    }
    return _cards.isNotEmpty ? _cards.first : MockData.cashOnDelivery;
  }

  void _proceed() {
    final method = _selected ??
        (_cards.isNotEmpty ? _cards.first : MockData.cashOnDelivery);
    _cart.selectPayment(method);

    PaymentGatewaySheet.show(
      context: context,
      amount: _cart.grandTotal,
      selectedMethod: method,
      onPaymentSuccess: (txnId, mode) async {
        final order = await _cart.checkout();
        if (mounted) {
          AppBanner.showSuccess(
            context,
            'Payment successful via $mode! Order #${order.id} placed.',
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.orderSuccess,
            (r) => r.settings.name == AppRoutes.home || r.isFirst,
            arguments: order.id,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Payment Options')),
      body: AnimatedBuilder(
        animation: _cart,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              // ── Order summary panel ──────────────────────────────────────
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
                    const SizedBox(height: 14),
                    // First item (if any)
                    if (_cart.items.isNotEmpty) ...[
                      OrderSummaryRow(
                        imageUrl: _cart.items.first.dish.imageUrl,
                        name: _cart.items.first.dish.name,
                        quantity: _cart.items.first.quantity,
                        price: _cart.items.first.dish.price,
                      ),
                    ],
                    const PanelDivider(),
                    AddressRow(address: _cart.selectedAddress.details),
                    const PanelDivider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        PriceText(price: _cart.grandTotal, size: 17),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Coupons row ──────────────────────────────────────────────
              _CouponsRow(
                appliedCoupon: _cart.appliedCoupon,
                onTap: () => _showCoupons(context),
              ),
              const SizedBox(height: 24),

              // ── Credit & Debit Cards ─────────────────────────────────────
              _sectionLabel(context, 'Credit & Debit Cards'),
              const SizedBox(height: 12),
              RoundedPanel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (int i = 0; i < _cards.length; i++) ...[
                      _radioTile(_cards[i], divider: i < _cards.length - 1),
                    ],
                    _AddMethodRow(
                      label: 'Add New Card',
                      onTap: () => _showAddCard(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── UPI ──────────────────────────────────────────────────────
              _sectionLabel(context, 'UPI'),
              const SizedBox(height: 12),
              RoundedPanel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (int i = 0; i < _upi.length; i++) ...[
                      _radioTile(_upi[i], divider: i < _upi.length - 1),
                    ],
                    _AddMethodRow(
                      label: 'Add New UPI ID',
                      onTap: () => _showAddUpi(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── More Payment Options ─────────────────────────────────────
              _sectionLabel(context, 'More Payment Options'),
              const SizedBox(height: 12),
              RoundedPanel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _radioTile(_walletMethod, divider: true),
                    _radioTile(_netBankingMethod, divider: true),
                    _radioTile(MockData.cashOnDelivery, divider: false),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _selected == null
          ? const SizedBox.shrink()
          : _ProceedBar(onTap: _proceed),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }

  Widget _radioTile(PaymentMethod method, {bool divider = false}) {
    final selected = _selectedId == method.id;
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _selectedId = method.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: selected
                  ? Border.all(color: AppColors.accentRed, width: 1.4)
                  : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                PaymentBrandMark(assetKind: method.assetKind),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (method.subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          method.subtitle!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _RadioDot(selected: selected),
              ],
            ),
          ),
        ),
        if (divider)
          const Divider(height: 1, color: AppColors.border, indent: 56),
      ],
    );
  }

  void _showCoupons(BuildContext context) {
    const coupons = <_Coupon>[
      _Coupon(code: 'WELCOMEBACK', label: '10% off your order'),
      _Coupon(code: 'PARAGON50', label: 'Flat ₹50 off above ₹300'),
      _Coupon(code: 'FREESHIP', label: 'Free delivery on this order'),
    ];
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
                for (final coupon in coupons)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          _cart.applyCoupon(coupon.code);
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                if (_cart.appliedCoupon != null)
                  TextButton(
                    onPressed: () {
                      _cart.applyCoupon(null);
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

  // ── Add New Card sheet ────────────────────────────────────────────────────

  void _showAddCard(BuildContext context) {
    final cardNumberCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Card',
                style: Theme.of(sheetCtx).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              _inputField(
                controller: cardNumberCtrl,
                label: 'Card Number',
                hint: 'XXXX XXXX XXXX XXXX',
                keyboardType: TextInputType.number,
                maxLength: 19,
              ),
              const SizedBox(height: 14),
              _inputField(
                controller: nameCtrl,
                label: 'Name on Card',
                hint: 'Cardholder Name',
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _inputField(
                      controller: expiryCtrl,
                      label: 'Expiry',
                      hint: 'MM/YY',
                      keyboardType: TextInputType.datetime,
                      maxLength: 5,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _inputField(
                      controller: cvvCtrl,
                      label: 'CVV',
                      hint: '•••',
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscure: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    final rawNumber = cardNumberCtrl.text.trim().replaceAll(' ', '');
                    if (rawNumber.isEmpty) return;
                    final last4 = rawNumber.length >= 4
                        ? rawNumber.substring(rawNumber.length - 4)
                        : rawNumber;
                    final name = nameCtrl.text.trim();
                    final newCard = PaymentMethod(
                      id: 'card_${DateTime.now().millisecondsSinceEpoch}',
                      title: 'Card  ....$last4',
                      subtitle: name.isNotEmpty ? name : 'Debit / Credit Card',
                      kind: PaymentKind.card,
                      assetKind: rawNumber.startsWith('4') ? 'visa' : 'mastercard',
                    );
                    setState(() {
                      _cards.add(newCard);
                      _selectedId = newCard.id;
                    });
                    Navigator.of(sheetCtx).pop();
                    AppToast.showSuccess(
                      context,
                      'Card ending in $last4 added & selected',
                    );
                  },
                  child: const Text(
                    'ADD CARD',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Add New UPI ID sheet ──────────────────────────────────────────────────

  void _showAddUpi(BuildContext context) {
    final upiCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New UPI ID',
                style: Theme.of(sheetCtx).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your UPI ID to link it for payments.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              _inputField(
                controller: upiCtrl,
                label: 'UPI ID',
                hint: 'username@bank',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    final upiId = upiCtrl.text.trim();
                    if (upiId.isEmpty) return;
                    final newUpi = PaymentMethod(
                      id: 'upi_${DateTime.now().millisecondsSinceEpoch}',
                      title: upiId,
                      kind: PaymentKind.upi,
                      assetKind: 'upi',
                    );
                    setState(() {
                      _upi.add(newUpi);
                      _selectedId = newUpi.id;
                    });
                    Navigator.of(sheetCtx).pop();
                    AppToast.showSuccess(
                      context,
                      'UPI ID "$upiId" added & selected',
                    );
                  },
                  child: const Text(
                    'VERIFY & ADD',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Shared text field builder ─────────────────────────────────────────────

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        hintStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _Coupon {
  const _Coupon({required this.code, required this.label});
  final String code;
  final String label;
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

class _AddMethodRow extends StatelessWidget {
  const _AddMethodRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.add_circle_outline,
                color: AppColors.copper, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.copper,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreOptionRow extends StatelessWidget {
  const _MoreOptionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
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
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.accentRed : AppColors.hint,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: AppColors.accentRed,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class _ProceedBar extends StatelessWidget {
  const _ProceedBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: Material(
            color: AppColors.accentRed,
            borderRadius: BorderRadius.circular(30),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: const Center(
                child: Text(
                  'PROCEED TO PAY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
