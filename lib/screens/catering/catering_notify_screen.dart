import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../state/catering_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import 'catering_booking_screen.dart' show CateringBookingArgs;
import 'catering_package_screen.dart' show CateringPackageArgs;

/// Step 4 of Catering: Final Confirmation & Venue Notification.
class CateringNotifyScreen extends StatefulWidget {
  const CateringNotifyScreen({super.key});

  @override
  State<CateringNotifyScreen> createState() => _CateringNotifyScreenState();
}

class _CateringNotifyScreenState extends State<CateringNotifyScreen> {
  bool _isSubmitting = false;

  late final TextEditingController _venueNameCtrl;
  late final TextEditingController _venueAddressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _instructionsCtrl;

  @override
  void initState() {
    super.initState();
    _venueNameCtrl = TextEditingController(text: 'Grand Occasion Hall');
    _venueAddressCtrl =
        TextEditingController(text: 'Mavoor Road, Kozhikode, Kerala 673004');
    _phoneCtrl = TextEditingController(
      text: AuthService.instance.currentUser?.phone ?? '+91 98765 43210',
    );
    _instructionsCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _venueNameCtrl.dispose();
    _venueAddressCtrl.dispose();
    _phoneCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  int _estimateGuests(String guestRange) {
    if (guestRange.contains('500+')) return 500;
    if (guestRange.contains('200')) return 300;
    if (guestRange.contains('100')) return 150;
    if (guestRange.contains('50')) return 75;
    return 40;
  }

  @override
  Widget build(BuildContext context) {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;

    CateringPackageArgs args;
    if (rawArgs is CateringPackageArgs) {
      args = rawArgs;
    } else if (rawArgs is CateringBookingArgs) {
      args = CateringPackageArgs(
        restaurant: rawArgs.restaurant,
        date: rawArgs.date,
        timeSlot: rawArgs.timeSlot,
        guestRange: rawArgs.guestRange,
        eventType: rawArgs.eventType,
        menuPackage: 'Royal Malabar Feast',
        pricePerPlate: 550.0,
        dietaryPreference: 'Mixed (Non-Veg & Veg)',
        needLiveCounters: true,
        needServiceStaff: true,
      );
    } else {
      args = CateringPackageArgs(
        date: DateTime.now().add(const Duration(days: 3)),
        timeSlot: 'Lunch (12:00 PM – 3:30 PM)',
        guestRange: '100 – 200 People',
        eventType: 'Wedding / Reception',
        menuPackage: 'Royal Malabar Feast',
        pricePerPlate: 550.0,
        dietaryPreference: 'Mixed (Non-Veg & Veg)',
        needLiveCounters: true,
        needServiceStaff: true,
      );
    }

    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final formattedDate =
        '${months[args.date.month - 1]} ${args.date.day}, ${args.date.year}';

    final estGuests = _estimateGuests(args.guestRange);
    final estMenuCost = estGuests * args.pricePerPlate;
    final estLiveCounterCost = args.needLiveCounters ? 5000.0 : 0.0;
    final estStaffCost = args.needServiceStaff ? 4000.0 : 0.0;
    final totalEstimate = estMenuCost + estLiveCounterCost + estStaffCost;

    final restaurantName = args.restaurant != null
        ? '${args.restaurant!.name} (${args.restaurant!.branch})'
        : 'Paragon Restaurant (Kozhikode)';

    Future<void> proceed() async {
      if (_isSubmitting) return;

      if (_venueAddressCtrl.text.trim().isEmpty) {
        AppBanner.showError(
          context,
          'Please provide your event venue address.',
          title: 'Missing Address',
        );
        return;
      }

      setState(() => _isSubmitting = true);
      final nav = Navigator.of(context);

      try {
        await CateringController.instance.placeOrder(
          date: args.date,
          guestRange: args.guestRange,
          restaurant: args.restaurant,
          timeSlot: args.timeSlot,
          eventType: args.eventType,
          menuPackage: args.menuPackage,
          pricePerPlate: args.pricePerPlate,
          totalAmount: totalEstimate,
          venueAddress:
              '${_venueNameCtrl.text.trim()}, ${_venueAddressCtrl.text.trim()}',
          specialInstructions: _instructionsCtrl.text.trim(),
          contactPhone: _phoneCtrl.text.trim(),
        );

        if (mounted) {
          AppBanner.showSuccess(
            context,
            'Catering request registered for ${args.guestRange}!',
            title: 'Catering Order Placed',
          );
        }
        nav.pushNamedAndRemoveUntil(
          AppRoutes.cateringDashboard,
          (route) => route.isFirst || route.settings.name == AppRoutes.home,
        );
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          AppBanner.showError(
            context,
            'Failed to submit catering request: $e',
            title: 'Error',
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              children: [
                // ── Top Header ──────────────────────────────────────────────
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: AppColors.textPrimary, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Step 4 of 4: Review & Notify',
                            style: TextStyle(
                              color: AppColors.copper,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Notify the Restaurant',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Our master catering coordinator will contact you to finalize the custom menu, tasting session, and event schedule.",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Comprehensive Order Summary Card ────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Event Summary',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.copper.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              args.eventType,
                              style: const TextStyle(
                                color: AppColors.copper,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _summaryRow(
                        icon: Icons.restaurant_outlined,
                        label: 'Kitchen Branch',
                        value: restaurantName,
                      ),
                      const SizedBox(height: 12),
                      _summaryRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date & Time',
                        value: '$formattedDate\n${args.timeSlot}',
                      ),
                      const SizedBox(height: 12),
                      _summaryRow(
                        icon: Icons.people_outline,
                        label: 'Guest Count',
                        value: args.guestRange,
                        highlight: true,
                      ),
                      const SizedBox(height: 12),
                      _summaryRow(
                        icon: Icons.restaurant_menu_rounded,
                        label: 'Menu Package',
                        value:
                            '${args.menuPackage} (₹${args.pricePerPlate.toInt()}/plate)',
                      ),
                      if (args.needLiveCounters || args.needServiceStaff) ...[
                        const SizedBox(height: 12),
                        _summaryRow(
                          icon: Icons.room_service_outlined,
                          label: 'Service Add-ons',
                          value: [
                            if (args.needLiveCounters) 'Live Cooking Station',
                            if (args.needServiceStaff) 'Uniformed Service Crew',
                          ].join(', '),
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(color: AppColors.border, height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estimated Quote',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '(Excludes custom taxes & transport)',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '₹ ${totalEstimate.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                            style: const TextStyle(
                              color: AppColors.copper,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Venue & Delivery Contact Details ────────────────────────
                const Text(
                  'Venue & Contact Details',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                _inputField(
                  controller: _venueNameCtrl,
                  label: 'Venue / Hall / Home Name',
                  icon: Icons.location_city_rounded,
                  hint: 'e.g. Grand Palace Convention Centre',
                ),
                const SizedBox(height: 12),

                _inputField(
                  controller: _venueAddressCtrl,
                  label: 'Street Address & Landmark',
                  icon: Icons.pin_drop_rounded,
                  hint: 'e.g. Mavoor Road, Near City Mall, Kozhikode',
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                _inputField(
                  controller: _phoneCtrl,
                  label: 'Coordinator Phone Number',
                  icon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  hint: '+91 98765 43210',
                ),
                const SizedBox(height: 12),

                _inputField(
                  controller: _instructionsCtrl,
                  label: 'Special Chef Notes / Dietary Requests',
                  icon: Icons.edit_note_rounded,
                  hint: 'e.g. Less spicy starters, Jain options needed for 10 guests',
                  maxLines: 2,
                ),
              ],
            ),

            // ── Persistent Proceed Button ────────────────────────────────────
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _isSubmitting ? null : proceed,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'NOTIFY PARAGON & CONFIRM',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow({
    required IconData icon,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: highlight ? AppColors.copper : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          icon: Icon(icon, color: AppColors.copper, size: 20),
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          hintText: hint,
          hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 13),
        ),
      ),
    );
  }
}
