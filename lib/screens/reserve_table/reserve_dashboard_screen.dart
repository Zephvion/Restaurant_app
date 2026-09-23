import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/reservation.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../state/reservation_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/dashboard_tab_bar.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/payment_gateway_sheet.dart';

/// Shows the user's existing reservations (empty state or a list of cards)
/// with a ＋ button to start a new reservation.
class ReserveDashboardScreen extends StatelessWidget {
  const ReserveDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: ReservationController.instance,
        builder: (context, _) {
          final ctrl = ReservationController.instance;
          return Column(
            children: [
              // ── top hero image ──────────────────────────────────────────
              _HeroHeader(),
              // ── Swiggy-style Section Switcher ───────────────────────────
              const DashboardTabBar(activeId: 'reserve_table'),
              // ── content ────────────────────────────────────────────────
              Expanded(
                child: ctrl.isEmpty
                    ? _EmptyState(onAdd: () => _goAdd(context))
                    : _ReservationList(
                        reservations: ctrl.reservations,
                        onAdd: () => _goAdd(context),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _goAdd(BuildContext context) =>
      Navigator.of(context).pushNamed(AppRoutes.selectRestaurant);
}

// ── Hero header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          const Positioned.fill(
            child: NetworkImageWithFallback(
              url: MockData.reserveTableHero,
              fit: BoxFit.cover,
              fallbackIcon: Icons.restaurant,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.home);
                      }
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.location_on_outlined,
                        color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: Colors.white),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.notifications),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final displayName = user?.displayName;
    final userName = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : 'Valued Guest';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          Text(
            'Hello, $userName!',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 6),
          const Text(
            'No reservations yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Planning a special dinner, family gathering, or business lunch? Reserve your preferred table in seconds.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                _AddButton(onTap: onAdd),
                const SizedBox(height: 12),
                const Text(
                  'Reserve Table',
                  style: TextStyle(
                    color: AppColors.copper,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ── Reservation list ──────────────────────────────────────────────────────────

class _ReservationList extends StatelessWidget {
  const _ReservationList({required this.reservations, required this.onAdd});
  final List<Reservation> reservations;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final displayName = user?.displayName;
    final userName = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : 'Valued Guest';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $userName!',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your Reservations',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppColors.copper, size: 32),
              onPressed: onAdd,
              tooltip: 'New Reservation',
            ),
          ],
        ),
        const SizedBox(height: 18),
        ...reservations.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ReservationCard(reservation: r),
            )),
      ],
    );
  }
}

// ── Reservation card ──────────────────────────────────────────────────────────

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.reservation});
  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final isCancelled = reservation.isCancelled;
    final isCompleted = reservation.isCompleted;
    final canCancel = reservation.canBeCancelled;

    Color badgeBg;
    Color badgeTextColor;
    IconData badgeIcon;
    String badgeText;

    if (isCancelled) {
      badgeBg = const Color(0xFF3E1E1E);
      badgeTextColor = const Color(0xFFEF5350);
      badgeIcon = Icons.cancel_outlined;
      badgeText = 'CANCELLED';
    } else if (isCompleted) {
      badgeBg = Colors.white10;
      badgeTextColor = AppColors.textSecondary;
      badgeIcon = Icons.check_circle_outline;
      badgeText = 'COMPLETED';
    } else {
      badgeBg = const Color(0xFF1E3A24);
      badgeTextColor = const Color(0xFF4CAF50);
      badgeIcon = Icons.schedule;
      badgeText = 'CONFIRMED RESERVATION';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCancelled
              ? Colors.redAccent.withValues(alpha: 0.25)
              : isCompleted
                  ? Colors.white12
                  : AppColors.accentRed.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header status badge and Table Number
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 13, color: badgeTextColor),
                    const SizedBox(width: 4),
                    Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Table ${reservation.tableDisplay}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Details row with table icon and timings
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table icon
              _TableIcon(label: reservation.tableDisplay),
              const SizedBox(width: 14),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${reservation.restaurant.name}, ${reservation.restaurant.city}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Date', value: reservation.formattedDate),
                    _InfoRow(
                      label: 'Arrival',
                      value: reservation.arrivalTime,
                      highlight: !isCancelled && !isCompleted,
                    ),
                    _InfoRow(
                      label: 'Hold Until',
                      value: '${reservation.waitingUntil} (15m grace)',
                    ),
                    _InfoRow(
                      label: 'Dining',
                      value: 'Until ${reservation.reservedUntil} (90 mins)',
                    ),
                    _InfoRow(label: 'Seats', value: '${reservation.seats} Guests'),
                  ],
                ),
              ),
            ],
          ),

          // Food bill preview if added by restaurant owner
          if (reservation.foodBillAmount != null && reservation.foodBillAmount! > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2A1E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.restaurant_menu, size: 14, color: Color(0xFF4CAF50)),
                          SizedBox(width: 6),
                          Text(
                            'Food Bill (Billed by Restaurant)',
                            style: TextStyle(
                              color: Color(0xFF81C784),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹${reservation.foodBillAmount!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  if (reservation.foodItems.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...reservation.foodItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item['name']} x${item['quantity'] ?? 1}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                            Text(
                              '₹${item['price'] ?? 0}',
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),

          // ── Customer Actions & Owner Manual Test Endpoints ─────────────────
          if (!isCancelled && !isCompleted) ...[
            // Pay at Table CTA (Directly opens full Payment Gateway Modal)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handlePayAtTable(context),
                icon: const Icon(Icons.payments_outlined, size: 16),
                label: Text(
                  reservation.foodBillAmount != null && reservation.foodBillAmount! > 0
                      ? 'Pay Food Bill at Table (₹${reservation.foodBillAmount!.toStringAsFixed(0)})'
                      : 'Pay Food Bill at Table',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Testing quick actions for Owner Dashboard simulation
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _simulateOwnerAddFoodBill(context),
                    icon: const Icon(Icons.receipt_long, size: 13),
                    label: const Text(
                      'Owner: Add Food',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.copper,
                      side: BorderSide(color: AppColors.copper.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _simulateOwnerManualUnlock(context),
                    icon: const Icon(Icons.lock_open, size: 13),
                    label: const Text(
                      'Owner: Free Table',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orangeAccent,
                      side: BorderSide(color: Colors.orangeAccent.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (canCancel)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _handleCancelReservation(context),
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text(
                  'Cancel Reservation',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF5350),
                  side: const BorderSide(color: Color(0xFFEF5350), width: 1),
                  backgroundColor: const Color(0xFF2C1515),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            )
          else if (isCancelled)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: Colors.redAccent.shade100),
                      const SizedBox(width: 6),
                      Text(
                        'Reservation Cancelled',
                        style: TextStyle(
                          color: Colors.redAccent.shade100,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (reservation.cancellationReason != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Reason: ${reservation.cancellationReason}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  const Text(
                    'The table was returned to the available pool.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                const Icon(Icons.check_circle, size: 15, color: Color(0xFF4CAF50)),
                const SizedBox(width: 6),
                Text(
                  reservation.status == 'paid_at_table'
                      ? 'Bill Paid at Table · Table Freed'
                      : 'Reservation completed · Table Freed',
                  style: const TextStyle(
                    color: Color(0xFF81C784),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Interactive Pay at Table flow: Launches the payment gateway directly for the food bill
  Future<void> _handlePayAtTable(BuildContext context) async {
    // 1. Determine payable amount (food bill if set by owner, or minimum bill)
    final billAmount = (reservation.foodBillAmount != null && reservation.foodBillAmount! > 0)
        ? reservation.foodBillAmount!
        : 650.0; // Default dining bill if owner has not entered specific food items yet

    // 2. Open PaymentGatewaySheet
    final paymentResult = await PaymentGatewaySheet.show(
      context: context,
      amount: billAmount,
      isTakeaway: false,
    );

    // 3. If payment successful, unlock the table and mark reservation paid
    if (paymentResult != null && context.mounted) {
      final txnId = paymentResult['txnId'] ?? 'TXN_${DateTime.now().millisecondsSinceEpoch}';
      final mode = paymentResult['mode'] ?? 'UPI';

      await ReservationController.instance.payAtTable(
        reservation,
        paymentMethod: mode,
        transactionId: txnId,
      );

      if (context.mounted) {
        AppBanner.showSuccess(
          context,
          'Bill payment of ₹${billAmount.toStringAsFixed(0)} via $mode successful! Table ${reservation.tableDisplay} is now unlocked and available. Thank you!',
          title: 'Payment Confirmed & Table Freed',
        );
      }
    }
  }

  /// Endpoint: Owner simulates adding food ordered at the table
  Future<void> _simulateOwnerAddFoodBill(BuildContext context) async {
    final sampleItems = [
      {'name': 'Paragon Chicken Biryani', 'price': 340, 'quantity': 2},
      {'name': 'Malabar Parotta', 'price': 35, 'quantity': 4},
      {'name': 'Fresh Lime Soda', 'price': 70, 'quantity': 2},
    ];
    const total = 960.0;

    await ReservationController.instance.updateFoodBillFromOwner(
      reservation.id,
      amount: total,
      items: sampleItems,
    );

    if (context.mounted) {
      AppBanner.showSuccess(
        context,
        'Owner updated Food Bill (₹960) with Biryani, Parotta & Drinks for Table ${reservation.tableDisplay}. User can now pay!',
        title: 'Owner: Food Bill Attached',
      );
    }
  }

  /// Endpoint: Owner manually unlocks table from owner dashboard
  Future<void> _simulateOwnerManualUnlock(BuildContext context) async {
    await ReservationController.instance.manualOwnerTableUnlock(reservation);
    if (context.mounted) {
      AppBanner.showSuccess(
        context,
        'Owner manually unlocked Table ${reservation.tableDisplay}. Status updated to Unoccupied/Available!',
        title: 'Owner: Table Unlocked Manually',
      );
    }
  }

  Future<void> _handleCancelReservation(BuildContext context) async {
    const reasons = [
      'Change of schedule / plans',
      'Booked wrong date or time',
      'Guest count changed',
      'Emergency or unwell',
      'Other reasons',
    ];
    String selectedReason = reasons.first;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Colors.white12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancel Table Reservation?',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Your reserved table will be made available for others.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Please select a reason for cancellation:',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              ...reasons.map((r) => InkWell(
                    onTap: () => setSheetState(() => selectedReason = r),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Row(
                        children: [
                          Icon(
                            selectedReason == r
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: selectedReason == r
                                ? AppColors.accentRed
                                : AppColors.textSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              r,
                              style: TextStyle(
                                color: selectedReason == r
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: selectedReason == r
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Keep Reservation'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF5350),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Cancel Booking',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      await ReservationController.instance.cancelReservation(
        reservation,
        reason: selectedReason,
      );
      if (context.mounted) {
        AppBanner.showSuccess(
          context,
          'Reservation for Table ${reservation.tableDisplay} has been cancelled.',
          title: 'Reservation Cancelled',
        );
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: highlight
                    ? const Color(0xFFFFB74D)
                    : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative table icon with overlapping coloured circles (matches Figma card).
class _TableIcon extends StatelessWidget {
  const _TableIcon({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cleanLabel = label.replaceAll('#', '').trim();
    final isLong = cleanLabel.length > 3;

    return SizedBox(
      width: 68,
      height: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Four seat circles at corners
          _circle(top: 0, left: 0, color: AppColors.accentRed.withValues(alpha: 0.7)),
          _circle(top: 0, right: 0, color: Colors.grey.shade700),
          _circle(bottom: 0, left: 0, color: AppColors.accentRed.withValues(alpha: 0.7)),
          _circle(bottom: 0, right: 0, color: Colors.grey.shade700),
          // Table surface
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                cleanLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: isLong ? 11 : 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle({
    double? top, double? bottom, double? left, double? right,
    required Color color,
  }) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

// ── Add button ────────────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: AppColors.textPrimary, size: 28),
      ),
    );
  }
}

