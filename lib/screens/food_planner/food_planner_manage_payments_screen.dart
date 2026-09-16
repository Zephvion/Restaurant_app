import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Manage Payment Methods screen for Food Planner matching Planner Account 6.png.
class FoodPlannerManagePaymentsScreen extends StatelessWidget {
  const FoodPlannerManagePaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Manage Payment Methods',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          // ── Credit & Debit Cards ──────────────────────────────────────
          const Text(
            'Credit & Debit Cards',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.credit_card,
                      color: AppColors.accentRed, size: 24),
                  title: Text(
                    'Axis Bank **** **** **** 2453',
                    style:
                        TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  ),
                ),
                Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: Icon(Icons.credit_card,
                      color: Colors.blueAccent, size: 24),
                  title: Text(
                    'HDFC Bank **** **** **** 2453',
                    style:
                        TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  ),
                ),
                Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: Icon(Icons.add, color: AppColors.textSecondary),
                  title: Text(
                    'Add New Card',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // ── UPI ───────────────────────────────────────────────────────
          const Text(
            'UPI',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.amber, size: 24),
                  title: Text(
                    'Google Pay',
                    style:
                        TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  ),
                ),
                Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: Icon(Icons.payment,
                      color: Colors.purpleAccent, size: 24),
                  title: Text(
                    'PhonePe',
                    style:
                        TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  ),
                ),
                Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: Icon(Icons.qr_code_2,
                      color: Colors.tealAccent, size: 24),
                  title: Text(
                    'artiabraham@oksbi',
                    style:
                        TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  ),
                ),
                Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: Icon(Icons.add, color: AppColors.textSecondary),
                  title: Text(
                    'Add New UPI ID',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // ── More Payment Options ──────────────────────────────────────
          const Text(
            'More Payment Options',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.wallet,
                      color: AppColors.textSecondary, size: 22),
                  title: Text('Wallet',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 13)),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 14, color: AppColors.textSecondary),
                ),
                Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: Icon(Icons.account_balance_outlined,
                      color: AppColors.textSecondary, size: 22),
                  title: Text('Net Banking',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 13)),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
