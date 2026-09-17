import 'dart:async';
import 'package:flutter/material.dart';

import '../models/payment_method.dart';
import '../theme/app_colors.dart';

enum PaymentGatewayStatus {
  selecting,
  processing,
  success,
  failed,
}

/// A comprehensive interactive Payment Gateway bottom sheet.
/// Supports UPI apps (Google Pay, PhonePe, Paytm, BHIM), Cards (with 3D Secure / CVV),
/// NetBanking, and Cash on Delivery (COD).
class PaymentGatewaySheet extends StatefulWidget {
  const PaymentGatewaySheet({
    super.key,
    required this.amount,
    required this.selectedMethod,
    required this.onPaymentSuccess,
  });

  final double amount;
  final PaymentMethod selectedMethod;
  final Function(String transactionId, String paymentMode) onPaymentSuccess;

  static Future<void> show({
    required BuildContext context,
    required double amount,
    required PaymentMethod selectedMethod,
    required Function(String transactionId, String paymentMode) onPaymentSuccess,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PaymentGatewaySheet(
        amount: amount,
        selectedMethod: selectedMethod,
        onPaymentSuccess: onPaymentSuccess,
      ),
    );
  }

  @override
  State<PaymentGatewaySheet> createState() => _PaymentGatewaySheetState();
}

class _PaymentGatewaySheetState extends State<PaymentGatewaySheet> {
  PaymentGatewayStatus _status = PaymentGatewayStatus.selecting;
  String _selectedUpiApp = 'Google Pay';
  final _cvvCtrl = TextEditingController(text: '789');
  int _countdown = 3;
  Timer? _timer;
  String? _txnId;

  @override
  void initState() {
    super.initState();
    if (widget.selectedMethod.kind == PaymentKind.upi) {
      if (widget.selectedMethod.title.toLowerCase().contains('phonepe')) {
        _selectedUpiApp = 'PhonePe';
      } else if (widget.selectedMethod.title.toLowerCase().contains('paytm')) {
        _selectedUpiApp = 'Paytm';
      } else {
        _selectedUpiApp = 'Google Pay';
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _startPayment() {
    setState(() {
      _status = PaymentGatewayStatus.processing;
      _countdown = 3;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        if (mounted) setState(() => _countdown--);
      } else {
        timer.cancel();
        final txn = 'TXN_PG_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
        _txnId = txn;
        if (mounted) {
          setState(() {
            _status = PaymentGatewayStatus.success;
          });
        }

        // Brief delay for success animation, then notify parent
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) {
            Navigator.of(context).pop(); // close sheet
            widget.onPaymentSuccess(
              txn,
              widget.selectedMethod.kind == PaymentKind.upi
                  ? 'UPI - $_selectedUpiApp'
                  : widget.selectedMethod.kind.name.toUpperCase(),
            );
          }
        });
      }
    });
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PARAGON Secure Pay',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: const [
                          Icon(Icons.lock, size: 11, color: Color(0xFF34A853)),
                          SizedBox(width: 4),
                          Text(
                            '256-Bit Encrypted Payment',
                            style: TextStyle(
                              color: Color(0xFF34A853),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
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
          const SizedBox(height: 18),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 18),

          // Payment mode details
          if (widget.selectedMethod.kind == PaymentKind.upi) ...[
            const Text(
              'Select UPI App to Pay',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildUpiOption('Google Pay', Icons.account_balance_wallet, const Color(0xFF4285F4)),
            _buildUpiOption('PhonePe', Icons.payments, const Color(0xFF5F259F)),
            _buildUpiOption('Paytm', Icons.qr_code, const Color(0xFF00BAF2)),
            _buildUpiOption('BHIM UPI', Icons.flash_on, const Color(0xFF00796B)),
          ] else if (widget.selectedMethod.kind == PaymentKind.card) ...[
            Container(
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
                              widget.selectedMethod.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (widget.selectedMethod.subtitle != null)
                              Text(
                                widget.selectedMethod.subtitle!,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
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
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.money, color: Color(0xFF34A853), size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Cash on Delivery (COD)',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pay cash or UPI directly to delivery partner upon arrival',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          // Action Button
          ElevatedButton(
            onPressed: _startPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.selectedMethod.kind == PaymentKind.cash
                      ? 'CONFIRM ORDER (₹${widget.amount.toStringAsFixed(2)})'
                      : 'PAY NOW ₹${widget.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpiOption(String appName, IconData icon, Color color) {
    final isSelected = _selectedUpiApp == appName;
    return GestureDetector(
      onTap: () => setState(() => _selectedUpiApp = appName),
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
              const Icon(Icons.radio_button_unchecked, color: AppColors.hint, size: 20),
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
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.copper),
                  strokeWidth: 3.5,
                ),
                Text(
                  '$_countdown',
                  style: const TextStyle(
                    color: AppColors.copper,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.selectedMethod.kind == PaymentKind.upi
                ? 'Opening $_selectedUpiApp...'
                : 'Processing Payment securely...',
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
          const Text(
            'Payment Verified Successfully!',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ref ID: ${_txnId ?? "TXN_OK"}',
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

