import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/payment_method.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/payment_brand_mark.dart';
import '../../widgets/payment_gateway_sheet.dart';

/// 10/10 Interactive Manage Payment Methods Screen.
/// Manage saved cards, UPI IDs, digital wallets, net banking,
/// with interactive "Add New" sheets and test payment triggers.
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  late List<PaymentMethod> _cards;
  late List<PaymentMethod> _upi;
  late List<PaymentMethod> _wallets;
  late List<PaymentMethod> _banks;

  @override
  void initState() {
    super.initState();
    _cards = List.from(MockData.cards);
    _upi = List.from(MockData.upi);
    _wallets = [
      const PaymentMethod(
        id: 'w_paytm',
        title: 'Paytm Wallet',
        subtitle: 'Linked (+91 9874563210)',
        kind: PaymentKind.wallet,
        assetKind: 'paytm',
      ),
      const PaymentMethod(
        id: 'w_phonepe',
        title: 'PhonePe Wallet',
        subtitle: 'Linked (+91 9874563210)',
        kind: PaymentKind.wallet,
        assetKind: 'phonepe',
      ),
    ];
    _banks = [
      const PaymentMethod(
        id: 'nb_hdfc',
        title: 'HDFC Bank',
        subtitle: 'A/c ending in ••8492',
        kind: PaymentKind.netBanking,
        assetKind: 'netbanking',
      ),
    ];
  }

  Future<void> _openPaymentModal(PaymentMethod method) async {
    final result = await PaymentGatewaySheet.show(
      context: context,
      amount: 450.0,
      selectedMethod: method,
    );
    if (result != null && mounted) {
      AppBanner.showSuccess(
        context,
        'Test transaction of ₹450 with ${method.title} verified successfully! Txn: ${result['txnId']}',
        title: 'Payment Successful',
      );
    }
  }

  void _showAddCardSheet() {
    final numberCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Card',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: numberCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '4532 •••• •••• 8892',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                hintStyle: const TextStyle(color: AppColors.hint),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Cardholder Name',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: expCtrl,
                    keyboardType: TextInputType.datetime,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Expiry (MM/YY)',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: cvvCtrl,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                final num = numberCtrl.text.trim();
                final name = nameCtrl.text.trim();
                if (num.isEmpty) return;
                final last4 = num.length >= 4 ? num.substring(num.length - 4) : '1234';
                final newCard = PaymentMethod(
                  id: 'card_${DateTime.now().millisecondsSinceEpoch}',
                  title: '•••• •••• •••• $last4',
                  subtitle: name.isNotEmpty ? name : 'Debit Card',
                  kind: PaymentKind.card,
                  assetKind: 'mastercard',
                );
                setState(() => _cards.add(newCard));
                Navigator.of(ctx).pop();
                AppBanner.showSuccess(
                  context,
                  'Card •••• $last4 added successfully!',
                  title: 'Card Linked',
                );
              },
              child: const Text(
                'SAVE & LINK CARD',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUpiSheet() {
    final vpaCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New UPI ID',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: vpaCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'UPI Virtual Payment Address (VPA)',
                hintText: 'username@okhdfcbank / mobile@upi',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                hintStyle: const TextStyle(color: AppColors.hint),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                final vpa = vpaCtrl.text.trim();
                if (vpa.isEmpty || !vpa.contains('@')) {
                  AppBanner.showError(context, 'Please enter a valid UPI address (e.g. name@upi)');
                  return;
                }
                final newUpi = PaymentMethod(
                  id: 'upi_${DateTime.now().millisecondsSinceEpoch}',
                  title: vpa,
                  subtitle: 'Verified UPI ID',
                  kind: PaymentKind.upi,
                  assetKind: vpa.contains('gpay') ? 'gpay' : (vpa.contains('ybl') ? 'phonepe' : 'upi'),
                );
                setState(() => _upi.add(newUpi));
                Navigator.of(ctx).pop();
                AppBanner.showSuccess(
                  context,
                  'UPI ID $vpa verified and linked!',
                  title: 'UPI Linked',
                );
              },
              child: const Text(
                'VERIFY & LINK UPI',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWalletSheet() {
    final wallets = [
      {'name': 'Amazon Pay Balance', 'kind': 'wallet', 'icon': Icons.account_balance_wallet},
      {'name': 'MobiKwik Wallet', 'kind': 'wallet', 'icon': Icons.wallet_rounded},
      {'name': 'Airtel Money', 'kind': 'wallet', 'icon': Icons.phone_android},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Link Digital Wallet',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              for (final w in wallets)
                ListTile(
                  leading: Icon(w['icon'] as IconData, color: AppColors.copper),
                  title: Text(w['name'] as String, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.add, color: AppColors.copper),
                  onTap: () {
                    final newW = PaymentMethod(
                      id: 'wallet_${DateTime.now().millisecondsSinceEpoch}',
                      title: w['name'] as String,
                      subtitle: 'Active Balance Link',
                      kind: PaymentKind.wallet,
                      assetKind: 'wallet',
                    );
                    setState(() => _wallets.add(newW));
                    Navigator.of(ctx).pop();
                    AppBanner.showSuccess(context, '${w['name']} linked successfully!');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBankSheet() {
    final banks = [
      'State Bank of India (SBI)',
      'ICICI Bank',
      'Axis Bank',
      'Kotak Mahindra Bank',
      'Canara Bank',
      'Federal Bank',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Net Banking Bank',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              for (final b in banks)
                ListTile(
                  leading: const Icon(Icons.account_balance, color: AppColors.copper),
                  title: Text(b, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                  onTap: () {
                    final newBank = PaymentMethod(
                      id: 'bank_${DateTime.now().millisecondsSinceEpoch}',
                      title: b,
                      subtitle: 'Internet Banking Enabled',
                      kind: PaymentKind.netBanking,
                      assetKind: 'netbanking',
                    );
                    setState(() => _banks.add(newBank));
                    Navigator.of(ctx).pop();
                    AppBanner.showSuccess(context, '$b net banking connected!');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Payment Methods'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _sectionLabel(context, 'Credit & Debit Cards'),
          const SizedBox(height: 12),
          for (final card in _cards) ...[
            _MethodTile(
              method: card,
              onTap: () => _openPaymentModal(card),
              onDelete: () => setState(() => _cards.remove(card)),
            ),
            const SizedBox(height: 10),
          ],
          _AddRow(
            label: 'Add New Card',
            onTap: _showAddCardSheet,
          ),
          const SizedBox(height: 28),
          _sectionLabel(context, 'UPI Accounts'),
          const SizedBox(height: 12),
          for (final upi in _upi) ...[
            _MethodTile(
              method: upi,
              onTap: () => _openPaymentModal(upi),
              onDelete: () => setState(() => _upi.remove(upi)),
            ),
            const SizedBox(height: 10),
          ],
          _AddRow(
            label: 'Add New UPI ID',
            onTap: _showAddUpiSheet,
          ),
          const SizedBox(height: 28),
          _sectionLabel(context, 'Digital Wallets'),
          const SizedBox(height: 12),
          for (final w in _wallets) ...[
            _MethodTile(
              method: w,
              onTap: () => _openPaymentModal(w),
              onDelete: () => setState(() => _wallets.remove(w)),
            ),
            const SizedBox(height: 10),
          ],
          _AddRow(
            label: 'Link New Wallet',
            onTap: _showAddWalletSheet,
          ),
          const SizedBox(height: 28),
          _sectionLabel(context, 'Net Banking'),
          const SizedBox(height: 12),
          for (final b in _banks) ...[
            _MethodTile(
              method: b,
              onTap: () => _openPaymentModal(b),
              onDelete: () => setState(() => _banks.remove(b)),
            ),
            const SizedBox(height: 10),
          ],
          _AddRow(
            label: 'Add Bank Account for Net Banking',
            onTap: _showAddBankSheet,
          ),
        ],
      ),
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
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.onTap,
    this.onDelete,
  });

  final PaymentMethod method;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundElevated,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
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
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textSecondary),
                  onPressed: onDelete,
                )
              else
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddRow extends StatelessWidget {
  const _AddRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.copper.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.copper.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_circle_outline, color: AppColors.copper, size: 20),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.copper,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
