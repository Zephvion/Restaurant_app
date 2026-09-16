import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/payment_method.dart';
import '../../theme/app_colors.dart';
import '../../widgets/payment_brand_mark.dart';

/// "Manage Payment Methods" — a read/manage view of saved cards and UPI ids,
/// with "add new" rows and a More section (Wallet, Net Banking).
///
/// Reached from Account → Payments. (Choosing a method for an order happens on
/// the Payment Options screen instead.)
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  void _soon(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceLight,
          content: Text('$what — coming soon'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Manage Payment Methods')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _sectionLabel(context, 'Credit & Debit Cards'),
          const SizedBox(height: 12),
          for (final card in MockData.cards) ...[
            _MethodTile(method: card, onTap: () {}),
            const SizedBox(height: 10),
          ],
          _AddRow(
            label: 'Add New Card',
            onTap: () => _soon(context, 'Add card'),
          ),
          const SizedBox(height: 28),
          _sectionLabel(context, 'UPI'),
          const SizedBox(height: 12),
          for (final upi in MockData.upi) ...[
            _MethodTile(method: upi, onTap: () {}),
            const SizedBox(height: 10),
          ],
          _AddRow(
            label: 'Add New UPI ID',
            onTap: () => _soon(context, 'Add UPI'),
          ),
          const SizedBox(height: 28),
          _sectionLabel(context, 'More'),
          const SizedBox(height: 12),
          _MoreRow(
            icon: Icons.account_balance_wallet,
            label: 'Wallet',
            onTap: () => _soon(context, 'Wallet'),
          ),
          const SizedBox(height: 10),
          _MoreRow(
            icon: Icons.account_balance,
            label: 'Net Banking',
            onTap: () => _soon(context, 'Net Banking'),
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
  const _MethodTile({required this.method, required this.onTap});

  final PaymentMethod method;
  final VoidCallback onTap;

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
              const Icon(Icons.more_horiz, color: AppColors.textSecondary),
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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.add_circle_outline, color: AppColors.copper),
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.copper,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundElevated,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary),
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
      ),
    );
  }
}
