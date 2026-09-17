import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../state/catering_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import 'catering_booking_screen.dart' show CateringBookingArgs;

/// "Notify the restaurant?" confirmation screen displaying the selected date and guest range.
class CateringNotifyScreen extends StatefulWidget {
  const CateringNotifyScreen({super.key});

  @override
  State<CateringNotifyScreen> createState() => _CateringNotifyScreenState();
}

class _CateringNotifyScreenState extends State<CateringNotifyScreen> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final args = (rawArgs is CateringBookingArgs)
        ? rawArgs
        : CateringBookingArgs(
            date: DateTime.now().add(const Duration(days: 3)),
            guestRange: 'Less than 50',
          );

    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final formattedDate =
        '${months[args.date.month - 1]} ${args.date.day} , ${args.date.year}';

    Future<void> proceed() async {
      if (_isSubmitting) return;
      setState(() => _isSubmitting = true);

      try {
        final order = await CateringController.instance.placeOrder(
          date: args.date,
          guestRange: args.guestRange,
        );

        if (mounted) {
          AppBanner.showSuccess(
            context,
            'Catering request submitted for ${args.guestRange} guests on $formattedDate!',
            title: 'Request Submitted',
          );
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.cateringSuccess,
            arguments: order,
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          AppBanner.showError(
            context,
            'Failed to submit catering request: $e',
            title: 'Error',
          );
        }
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
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 28),
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
              const SizedBox(height: 40),

              // ── Details Card ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    // Date Row
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
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(color: AppColors.border, height: 1),
                    ),
                    // Expected number of people
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
                            color: AppColors.copper,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── PROCEED Button ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isSubmitting ? null : proceed,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'PROCEED',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: 1.5,
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
