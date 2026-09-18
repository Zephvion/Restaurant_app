import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import 'app_banner.dart';

/// Customer support, restaurant assistance, and delivery partner contact modal.
class CustomerSupportSheet extends StatelessWidget {
  const CustomerSupportSheet({
    super.key,
    this.orderId,
    this.riderName = 'Rahul Sharma',
    this.riderPhone = MockData.deliveryPartnerPhone,
  });

  final String? orderId;
  final String riderName;
  final String riderPhone;

  static Future<void> show({
    required BuildContext context,
    String? orderId,
    String riderName = 'Rahul Sharma',
    String riderPhone = MockData.deliveryPartnerPhone,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CustomerSupportSheet(
        orderId: orderId,
        riderName: riderName,
        riderPhone: riderPhone,
      ),
    );
  }

  void _showActionToast(BuildContext context, String message) {
    Navigator.of(context).pop();
    AppToast.showSuccess(context, message, title: 'Support');
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
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
            const SizedBox(height: 18),

            // Header
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.copper.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.headset_mic_rounded,
                      color: AppColors.copper, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Help & Order Support',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (orderId != null)
                      Text(
                        'Order ID: $orderId',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 14),

            // Call Delivery Partner
            _buildOptionTile(
              context,
              icon: Icons.two_wheeler_rounded,
              iconColor: const Color(0xFF4285F4),
              title: 'Call Delivery Partner ($riderName)',
              subtitle: riderPhone,
              onTap: () => _showActionToast(context, 'Calling $riderName ($riderPhone)...'),
            ),

            const SizedBox(height: 10),

            // Call Restaurant
            _buildOptionTile(
              context,
              icon: Icons.restaurant_rounded,
              iconColor: AppColors.copper,
              title: 'Call Paragon Restaurant',
              subtitle: '+91 495 276 7020 (Calicut Branch)',
              onTap: () => _showActionToast(context, 'Connecting to Paragon Restaurant...'),
            ),

            const SizedBox(height: 10),

            // Live Chat
            _buildOptionTile(
              context,
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: const Color(0xFF34A853),
              title: 'Live Chat with Support',
              subtitle: 'Average reply time: < 1 min',
              onTap: () => _showActionToast(context, 'Live agent connected. Chatting...'),
            ),

            const SizedBox(height: 10),

            // Report an Issue
            _buildOptionTile(
              context,
              icon: Icons.report_problem_outlined,
              iconColor: AppColors.accentRed,
              title: 'Report an Issue with Order',
              subtitle: 'Wrong items, packaging, or delay',
              onTap: () => _showActionToast(context, 'Issue report submitted. Ticket #9201 generated.'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.phone_forwarded, color: AppColors.hint, size: 18),
          ],
        ),
      ),
    );
  }
}

