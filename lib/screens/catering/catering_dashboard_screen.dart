import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/catering_order.dart';
import '../../models/payment_method.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../state/catering_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/dashboard_tab_bar.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/payment_gateway_sheet.dart';

/// Dashboard screen for Catering:
/// Shows empty state ("No catering orders yet") or active order cards with progress stepper,
/// coordinator call modal, pickup/kitchen details, and mock payment gateway integration.
class CateringDashboardScreen extends StatelessWidget {
  const CateringDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: CateringController.instance,
        builder: (context, _) {
          final ctrl = CateringController.instance;
          return Column(
            children: [
              // ── Top Hero Image ──────────────────────────────────────────
              const _HeroHeader(),
              // ── Swiggy-style Section Switcher ───────────────────────────
              const DashboardTabBar(activeId: 'catering'),
              // ── Main Content ────────────────────────────────────────────
              Expanded(
                child: ctrl.hasNoOrders
                    ? _EmptyState(onAdd: () => _goNotice(context))
                    : _OrdersList(
                        orders: ctrl.orders,
                        onAdd: () => _goNotice(context),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _goNotice(BuildContext context) =>
      Navigator.of(context).pushNamed(AppRoutes.cateringNotice);
}

// ── Hero header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          const Positioned.fill(
            child: NetworkImageWithFallback(
              url: MockData.cateringTable,
              fit: BoxFit.cover,
              fallbackIcon: Icons.room_service,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                  AppColors.background.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  const SizedBox(width: 8),
                  const Text(
                    'Paragon Catering Hub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
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
            'No catering orders yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Planning a wedding, corporate gala, or family feast? Create a custom catering request in seconds.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                _AddButton(onTap: onAdd),
                const SizedBox(height: 12),
                const Text(
                  'Book Catering Service',
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

// ── Orders list ───────────────────────────────────────────────────────────────

class _OrdersList extends StatelessWidget {
  const _OrdersList({required this.orders, required this.onAdd});
  final List<CateringOrder> orders;
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
                    'Your Catering Bookings',
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
              tooltip: 'New Catering Booking',
            ),
          ],
        ),
        const SizedBox(height: 18),
        ...orders.map((order) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _CateringOrderCard(order: order),
            )),
      ],
    );
  }
}

// ── Catering Order Card ───────────────────────────────────────────────────────

class _CateringOrderCard extends StatelessWidget {
  const _CateringOrderCard({required this.order});
  final CateringOrder order;

  void _showOwnerCallDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1.2),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.copper.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_in_talk_rounded,
                        color: AppColors.copper, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catering Coordinator Direct Line',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.ownerName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _dialogInfoRow(
                      icon: Icons.phone_android,
                      label: 'Direct Phone',
                      value: order.ownerPhone,
                    ),
                    const Divider(color: AppColors.border, height: 16),
                    _dialogInfoRow(
                      icon: Icons.storefront,
                      label: 'Kitchen Hub',
                      value: order.pickupLocation,
                    ),
                    const Divider(color: AppColors.border, height: 16),
                    _dialogInfoRow(
                      icon: Icons.bookmark_added_outlined,
                      label: 'Order Reference',
                      value: order.id,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.call, size: 20),
                label: Text(
                  'CALL NOW (${order.ownerPhone})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  CateringController.instance
                      .updateOrderStatus(order.id, CateringStatus.call);
                  AppBanner.showSuccess(
                    context,
                    'Connecting to ${order.ownerName} (${order.ownerPhone})...',
                    title: 'Calling Catering Operations',
                  );
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _dialogInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.copper),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _proceedToPayment(BuildContext context) async {
    final payAmount = order.totalAmount > 0 ? order.totalAmount : 25000.0;

    final result = await PaymentGatewaySheet.show(
      context: context,
      amount: payAmount,
      selectedMethod: const PaymentMethod(
        id: 'upi_gpay',
        title: 'Google Pay / UPI',
        subtitle: 'Fast UPI verification',
        kind: PaymentKind.upi,
        assetKind: 'gpay',
      ),
    );

    if (result == null || !context.mounted) return;

    final txnId = result['txnId'] ?? '';
    final mode = result['mode'] ?? '';

    await CateringController.instance.confirmPayment(
      order.id,
      txnId: txnId,
      paymentMode: mode,
    );
    if (context.mounted) {
      AppBanner.showSuccess(
        context,
        'Payment of ₹${payAmount.toInt()} verified! Catering booking ${order.id} is confirmed.',
        title: 'Booking Confirmed',
      );
    }
  }

  void _confirmCancelOrder(BuildContext context) {
    final isConfirmed =
        order.status == CateringStatus.bookingConfirmed || order.isPaid;
    final displayAmount = order.totalAmount > 0 ? order.totalAmount : 25000.0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.accentRed, size: 24),
            SizedBox(width: 8),
            Text(
              'Cancel Catering?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          isConfirmed
              ? 'Your booking is confirmed with an advance of ₹${displayAmount.toInt()} paid via ${order.paymentMode ?? "UPI"}.\n\nCancelling now will initiate a 100% refund back to your payment account within 24–48 hours. Are you sure you want to cancel?'
              : 'Are you sure you want to cancel and withdraw your catering request (${order.id}) for ${order.eventType} on ${order.formattedDate}?',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Booking',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await CateringController.instance.cancelOrder(order.id);
              if (context.mounted) {
                AppBanner.showSuccess(
                  context,
                  'Catering request ${order.id} has been cancelled successfully.',
                  title: 'Order Cancelled',
                );
              }
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConfirmed =
        order.status == CateringStatus.bookingConfirmed || order.isPaid;
    final displayAmount = order.totalAmount > 0 ? order.totalAmount : 25000.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isConfirmed
              ? const Color(0xFF2E7D32).withValues(alpha: 0.5)
              : AppColors.border,
          width: isConfirmed ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isConfirmed
                  ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
                  : AppColors.copper.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: Row(
              children: [
                Icon(
                  isConfirmed ? Icons.check_circle : Icons.access_time_filled,
                  color:
                      isConfirmed ? const Color(0xFF2E7D32) : AppColors.copper,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.statusLabel,
                    style: TextStyle(
                      color: isConfirmed
                          ? const Color(0xFF2E7D32)
                          : AppColors.copper,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.id,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.textSecondary, size: 18),
                  tooltip: 'Cancel Catering Request',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _confirmCancelOrder(context),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Progress Stepper ────────────────────────────────────────
                _ProgressStepper(status: order.status),
                const SizedBox(height: 18),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 14),

                // ── Event & Package Details ─────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.eventType,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${order.menuPackage} • ${order.guestRange}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total Estimate',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                        ),
                        Text(
                          '₹ ${displayAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                          style: const TextStyle(
                            color: AppColors.copper,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Key Information Rows ────────────────────────────────────
                _infoTile(
                  icon: Icons.calendar_today_outlined,
                  title: 'Date & Time',
                  content: '${order.formattedDate} • ${order.timeSlot}',
                ),
                const SizedBox(height: 8),
                _infoTile(
                  icon: Icons.storefront_outlined,
                  title: 'Pickup & Kitchen Hub',
                  content: order.pickupLocation,
                ),
                const SizedBox(height: 8),
                _infoTile(
                  icon: Icons.location_on_outlined,
                  title: 'Event Venue',
                  content: order.venueAddress,
                ),
                const SizedBox(height: 8),
                _infoTile(
                  icon: Icons.person_pin_outlined,
                  title: 'Catering Lead / Owner',
                  content: '${order.ownerName} (${order.ownerPhone})',
                ),

                // ── Payment Status Badge (If Paid) ──────────────────────────
                if (order.isPaid) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified,
                            color: Color(0xFF2E7D32), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Paid: ₹${displayAmount.toInt()} via ${order.paymentMode ?? "UPI"} (Txn: ${order.paymentTxnId ?? "VERIFIED"})',
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 14),

                // ── Action Buttons ──────────────────────────────────────────
                Row(
                  children: [
                    // Enquiry Call Button
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.copper),
                          foregroundColor: AppColors.copper,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.phone_outlined, size: 16),
                        label: const Text(
                          'Call for Enquiry',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () => _showOwnerCallDialog(context),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Proceed to Payment / Status Button
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isConfirmed
                              ? const Color(0xFF2E7D32)
                              : AppColors.accentRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: Icon(
                          isConfirmed ? Icons.check_circle : Icons.payment,
                          size: 16,
                        ),
                        label: Text(
                          isConfirmed ? 'CONFIRMED' : 'PROCEED TO PAY',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        onPressed: isConfirmed
                            ? () {
                                AppBanner.showSuccess(
                                  context,
                                  'Catering order ${order.id} is confirmed and scheduled.',
                                  title: 'Booking Confirmed',
                                );
                              }
                            : () => _proceedToPayment(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.copper),
        const SizedBox(width: 8),
        SizedBox(
          width: 125,
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            content,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Progress Stepper ──────────────────────────────────────────────────────────

class _ProgressStepper extends StatelessWidget {
  const _ProgressStepper({required this.status});
  final CateringStatus status;

  @override
  Widget build(BuildContext context) {
    final isNotifiedDone = status == CateringStatus.notifiedParagon ||
        status == CateringStatus.call ||
        status == CateringStatus.bookingConfirmed;

    final isCallDone = status == CateringStatus.call ||
        status == CateringStatus.bookingConfirmed;

    final isBookingDone = status == CateringStatus.bookingConfirmed;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _stepItem(label: 'Notified', active: isNotifiedDone),
        _divider(active: isCallDone),
        _stepItem(label: 'Enquiry Call', active: isCallDone),
        _divider(active: isBookingDone),
        _stepItem(label: 'Confirmed & Paid', active: isBookingDone),
      ],
    );
  }

  Widget _stepItem({required String label, required bool active}) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? const Color(0xFF2E7D32)
                : AppColors.surfaceLight,
          ),
          child: Icon(
            active ? Icons.check : Icons.circle,
            size: active ? 14 : 8,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 10,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _divider({required bool active}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          children: List.generate(
            5,
            (index) => Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                color: active
                    ? const Color(0xFF2E7D32)
                    : AppColors.surfaceLight,
              ),
            ),
          ),
        ),
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
