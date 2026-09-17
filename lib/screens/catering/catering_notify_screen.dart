import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../state/catering_controller.dart';
import '../../theme/app_colors.dart';
import 'catering_booking_screen.dart' show CateringBookingArgs;

/// "Notify the restaurant?" confirmation screen displaying the selected date and guest range.
class CateringNotifyScreen extends StatelessWidget {
  const CateringNotifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as CateringBookingArgs;

    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final formattedDate =
        '${months[args.date.month - 1]} ${args.date.day} , ${args.date.year}';

    void proceed() {
      CateringController.instance.placeOrder(
    Future<void> proceed() async {
      await CateringController.instance.placeOrder(
        date: args.date,
        guestRange: args.guestRange,
      );
      Navigator.of(context).pushNamed(AppRoutes.cateringSuccess);
      if (context.mounted) {
        Navigator.of(context).pushNamed(AppRoutes.cateringSuccess);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: AppColors.textPrimary, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 32),
              const Text(
                'Notify the restaurant?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "The restaurant will be notified and we'll contact you to confirm your order.",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),
              // ── Date Row ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Date',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: AppColors.border),
              ),
              // ── Expected number of people ────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Expected Number\nof people',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  Text(
                    args.guestRange,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // ── PROCEED Button ───────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: proceed,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'PROCEED',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
