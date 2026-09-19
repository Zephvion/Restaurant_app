import 'dart:async';
import 'package:flutter/material.dart';

import '../models/payment_method.dart';
import '../services/razorpay_gateway_service.dart';
import '../theme/app_colors.dart';

enum PaymentGatewayStatus {
  selecting,
  processing,
  success,
  failed,
}

/// A comprehensive interactive Payment Gateway bottom sheet.
/// Supports UPI apps (Google Pay, PhonePe, Paytm, BHIM), Cards (with 3D Secure / CVV),
/// NetBanking, and Pay at Counter / Cash on Delivery.
class PaymentGatewaySheet extends StatefulWidget {
  const PaymentGatewaySheet({
    super.key,
    required this.amount,
    this.selectedMethod,
    this.isTakeaway = false,
  });

  final double amount;
  final PaymentMethod? selectedMethod;
  final bool isTakeaway;

  /// Shows the payment gateway sheet and returns a result map
  /// {'txnId': String, 'mode': String} on success, or null if dismissed.
  static Future<Map<String, String>?> show({
    required BuildContext context,
    required double amount,
    PaymentMethod? selectedMethod,
    bool isTakeaway = false,
    // Keep the old callback parameter for backward compat but ignore it
    FutureOr<void> Function(String transactionId, String paymentMode)? onPaymentSuccess,
  }) async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PaymentGatewaySheet(
        amount: amount,
        selectedMethod: selectedMethod,
        isTakeaway: isTakeaway,
      ),
    );
    return result;
  }

  @override
  State<PaymentGatewaySheet> createState() => _PaymentGatewaySheetState();
}

class _PaymentGatewaySheetState extends State<PaymentGatewaySheet> {
  PaymentGatewayStatus _status = PaymentGatewayStatus.selecting;
  late PaymentKind _activeKind;
  String _selectedUpiApp = 'Google Pay';
  String _selectedCard = 'HDFC VISA (*2453)';
  String _selectedBank = 'HDFC Bank';
  final _cvvCtrl = TextEditingController(text: '789');
  final _upiIdCtrl = TextEditingController();
  bool _useCustomUpi = false;
  String? _txnId;

  final List<String> _popularBanks = [
    'HDFC Bank',
    'State Bank of India',
    'ICICI Bank',
    'Axis Bank',
    'Kotak Mahindra',
    'Punjab National Bank',
  ];

  @override
  void initState() {
    super.initState();
    // Default to UPI or passed method
    _activeKind = widget.selectedMethod?.kind ?? PaymentKind.upi;

    if (widget.selectedMethod != null &&
        widget.selectedMethod!.kind == PaymentKind.upi) {
      if (widget.selectedMethod!.title.toLowerCase().contains('phonepe')) {
        _selectedUpiApp = 'PhonePe';
      } else if (widget.selectedMethod!.title.toLowerCase().contains('paytm')) {
        _selectedUpiApp = 'Paytm';
      } else {
        _selectedUpiApp = 'Google Pay';
      }
    }
  }

  @override
  void dispose() {
    _cvvCtrl.dispose();
    _upiIdCtrl.dispose();
    super.dispose();
  }

  String get _currentPaymentModeLabel {
    switch (_activeKind) {
      case PaymentKind.upi:
        return _useCustomUpi && _upiIdCtrl.text.trim().isNotEmpty
            ? 'UPI (${_upiIdCtrl.text.trim()})'
            : 'UPI - $_selectedUpiApp';
      case PaymentKind.card:
        return 'Card ($_selectedCard)';
      case PaymentKind.netBanking:
        return 'Net Banking - $_selectedBank';
      case PaymentKind.cash:
        return widget.isTakeaway ? 'Pay at Counter' : 'Cash on Delivery';
      default:
        return 'Online Payment';
    }
  }

  void _completePayment(String txn, String modeLabel) {
    if (mounted) {
      setState(() {
        _status = PaymentGatewayStatus.success;
      });
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        // Pop the sheet with the result — PaymentOptionsScreen handles navigation
        Navigator.of(context).pop<Map<String, String>>({
          'txnId': txn,
          'mode': modeLabel,
        });
      }
    });
  }

  Future<void> _startPayment() async {
    final modeLabel = _currentPaymentModeLabel;

    // Fast-track Pay at Counter / COD without gateway
    if (_activeKind == PaymentKind.cash) {
      final txn = 'TXN_CTR_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      _txnId = txn;
      _completePayment(txn, modeLabel);
      return;
    }

    setState(() {
      _status = PaymentGatewayStatus.processing;
    });

    final subMethod = _activeKind == PaymentKind.upi
        ? _selectedUpiApp
        : (_activeKind == PaymentKind.card ? _selectedCard : _selectedBank);

    final result = await RazorpayGatewayService.instance.processPayment(
      amount: widget.amount,
      kind: _activeKind,
      subMethod: subMethod,
      cardCvv: _cvvCtrl.text.trim(),
      customUpiId: _useCustomUpi ? _upiIdCtrl.text.trim() : null,
    );

    if (!mounted) return;

    if (result.success) {
      final txn = result.paymentId ??
          'pay_${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';
      _txnId = txn;
      _completePayment(txn, result.paymentMode ?? modeLabel);
    } else if (result.isDismissed) {
      setState(() {
        _status = PaymentGatewayStatus.selecting;
      });
    } else {
      setState(() {
        _status = PaymentGatewayStatus.selecting;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Payment was cancelled or failed'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.2),
          left: BorderSide(color: AppColors.border, width: 1.2),
          right: BorderSide(color: AppColors.border, width: 1.2),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag pill
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_status == PaymentGatewayStatus.selecting) _buildSelectingView(),
              if (_status == PaymentGatewayStatus.processing) _buildProcessingView(),
              if (_status == PaymentGatewayStatus.success) _buildSuccessView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectingView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.maroon.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined,
                        color: AppColors.copper, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PARAGON Secure Pay',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.lock, size: 11, color: Color(0xFF34A853)),
                          SizedBox(width: 4),
                          Text(
                            '256-Bit Encrypted Payment',
                            style: TextStyle(
                              color: Color(0xFF34A853),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'To Pay',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                  Text(
                    '₹${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.copper,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Payment Category Switcher Tabs ──────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryTab(PaymentKind.upi, 'UPI', Icons.qr_code_2),
                _buildCategoryTab(PaymentKind.card, 'Cards', Icons.credit_card),
                _buildCategoryTab(
                    PaymentKind.netBanking, 'Net Banking', Icons.account_balance),
                _buildCategoryTab(
                  PaymentKind.cash,
                  widget.isTakeaway ? 'Pay at Counter' : 'Cash on Delivery',
                  widget.isTakeaway ? Icons.storefront : Icons.payments,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 18),

          // ── Category Specific Detail View ─────────────────────────────────
          if (_activeKind == PaymentKind.upi) ...[
            _buildUpiSection(),
          ] else if (_activeKind == PaymentKind.card) ...[
            _buildCardSection(),
          ] else if (_activeKind == PaymentKind.netBanking) ...[
            _buildNetBankingSection(),
          ] else ...[
            _buildCashSection(),
          ],

          const SizedBox(height: 24),

          // ── Action Button ──────────────────────────────────────────────────
          ElevatedButton(
            onPressed: _startPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: _activeKind == PaymentKind.cash
                  ? const Color(0xFF2E7D32)
                  : AppColors.maroon,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _activeKind == PaymentKind.cash
                      ? Icons.check_circle_outline
                      : Icons.lock_outline,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _getActionButtonLabel(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getActionButtonLabel() {
    switch (_activeKind) {
      case PaymentKind.upi:
        return 'PAY ₹${widget.amount.toStringAsFixed(2)} VIA ${_useCustomUpi ? "UPI ID" : _selectedUpiApp.toUpperCase()}';
      case PaymentKind.card:
        return 'PAY ₹${widget.amount.toStringAsFixed(2)} VIA CARD';
      case PaymentKind.netBanking:
        return 'PAY ₹${widget.amount.toStringAsFixed(2)} VIA $_selectedBank';
      case PaymentKind.cash:
        return widget.isTakeaway
            ? 'CONFIRM ORDER & PAY AT COUNTER'
            : 'CONFIRM CASH ON DELIVERY';
      default:
        return 'PAY NOW ₹${widget.amount.toStringAsFixed(2)}';
    }
  }

  Widget _buildCategoryTab(PaymentKind kind, String label, IconData icon) {
    final isSelected = _activeKind == kind;
    return GestureDetector(
      onTap: () => setState(() => _activeKind = kind),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentRed.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accentRed : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.accentRed : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── UPI Section ─────────────────────────────────────────────────────────────
  Widget _buildUpiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Instant UPI App',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildUpiOption('Google Pay', Icons.account_balance_wallet,
            const Color(0xFF4285F4)),
        _buildUpiOption('PhonePe', Icons.payments, const Color(0xFF5F259F)),
        _buildUpiOption('Paytm', Icons.qr_code, const Color(0xFF00BAF2)),
        _buildUpiOption('BHIM UPI', Icons.flash_on, const Color(0xFF00796B)),
        const SizedBox(height: 8),
        // Enter UPI ID option
        GestureDetector(
          onTap: () => setState(() => _useCustomUpi = !_useCustomUpi),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _useCustomUpi ? AppColors.copper : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Or enter UPI ID / VPA',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      _useCustomUpi
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color:
                          _useCustomUpi ? AppColors.copper : AppColors.hint,
                      size: 18,
                    ),
                  ],
                ),
                if (_useCustomUpi) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _upiIdCtrl,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. yourname@okhdfcbank',
                      hintStyle: const TextStyle(
                          color: AppColors.hint, fontSize: 13),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      fillColor: AppColors.backgroundElevated,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Card Section ────────────────────────────────────────────────────────────
  Widget _buildCardSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card, color: AppColors.copper, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedCard,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      'Saved Card · Primary',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.arrow_drop_down,
                    color: AppColors.textSecondary),
                onSelected: (val) => setState(() => _selectedCard = val),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'HDFC VISA (*2453)',
                    child: Text('HDFC VISA (*2453)'),
                  ),
                  const PopupMenuItem(
                    value: 'SBI MasterCard (*8754)',
                    child: Text('SBI MasterCard (*8754)'),
                  ),
                  const PopupMenuItem(
                    value: 'ICICI Rupay (*1129)',
                    child: Text('ICICI Rupay (*1129)'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Card Security Code (CVV):',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
              SizedBox(
                width: 70,
                child: TextField(
                  controller: _cvvCtrl,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    fillColor: AppColors.backgroundElevated,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.verified_user_outlined,
                  size: 13, color: Color(0xFF34A853)),
              SizedBox(width: 6),
              Text(
                'Secured with 3D Secure / OTP Verification',
                style: TextStyle(color: Color(0xFF34A853), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Net Banking Section ─────────────────────────────────────────────────────
  Widget _buildNetBankingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Bank',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularBanks.map((bank) {
            final isSelected = _selectedBank == bank;
            return GestureDetector(
              onTap: () => setState(() => _selectedBank = bank),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.copper.withValues(alpha: 0.15)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.copper : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance,
                      size: 16,
                      color:
                          isSelected ? AppColors.copper : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      bank,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Cash / Counter Section ──────────────────────────────────────────────────
  Widget _buildCashSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.isTakeaway ? Icons.storefront_rounded : Icons.money_rounded,
              color: const Color(0xFF34A853),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isTakeaway
                      ? 'Pay at Restaurant Counter'
                      : 'Cash on Delivery (COD)',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isTakeaway
                      ? 'No upfront online payment required! Simply pay via Cash, Card, or UPI at the restaurant pickup counter when collecting your hot food parcel.'
                      : 'Pay cash or UPI directly to delivery partner upon arrival.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpiOption(String appName, IconData icon, Color color) {
    final isSelected = !_useCustomUpi && _selectedUpiApp == appName;
    return GestureDetector(
      onTap: () => setState(() {
        _useCustomUpi = false;
        _selectedUpiApp = appName;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                appName,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 20)
            else
              const Icon(Icons.radio_button_unchecked,
                  color: AppColors.hint, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Column(
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.copper),
                  strokeWidth: 3.5,
                ),
                Icon(
                  _activeKind == PaymentKind.upi
                      ? Icons.account_balance_wallet
                      : (_activeKind == PaymentKind.card
                          ? Icons.credit_card
                          : Icons.account_balance),
                  color: AppColors.copper,
                  size: 28,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _activeKind == PaymentKind.upi
                ? 'Opening $_selectedUpiApp...'
                : 'Processing $_currentPaymentModeLabel securely...',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please do not press back or close the app.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, color: Color(0xFF34A853), size: 14),
                const SizedBox(width: 6),
                Text(
                  'Amount: ₹${widget.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF34A853).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF34A853),
              size: 52,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _activeKind == PaymentKind.cash && widget.isTakeaway
                ? 'Takeaway Confirmed (Pay at Counter)!'
                : 'Payment Verified Successfully!',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mode: $_currentPaymentModeLabel · Ref: ${_txnId ?? "TXN_OK"}',
            style: const TextStyle(
              color: AppColors.copper,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
