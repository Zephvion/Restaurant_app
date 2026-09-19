import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/mock_data.dart';
import '../../models/address.dart';
import '../../models/order_model.dart';
import '../../routes/app_routes.dart';
import '../../services/gps_detection_service.dart';
import '../../services/location_service.dart';
import '../../services/order_service.dart';
import '../../services/session_manager.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/customer_support_sheet.dart';
import '../../widgets/gps_location_picker_sheet.dart';
import '../../widgets/interactive_map_view.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/order_cancellation_sheet.dart';
import '../../widgets/paragon_bottom_nav.dart';

/// Track Order — a world-class, production-ready live delivery tracker
/// featuring a responsive stylized map with vehicle route animation,
/// pulsating GPS pins, floating controls, and a non-overlapping expandable bottom sheet.
class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeOrderId = ModalRoute.of(context)?.settings.arguments as String?;
    final orderId = routeOrderId ??
        SessionManager.instance.activeOrderId ??
        MockData.orderId;

    return StreamBuilder<OrderModel?>(
      stream: OrderService.instance.streamOrder(orderId),
      builder: (context, snapshot) {
        final order = snapshot.data;
        final eta = order?.estimatedDeliveryMinutes ?? 15;
        final status = order?.status ?? OrderStatus.outForDelivery;

        final savedAddr = SessionManager.instance.getSelectedAddress();
        final Address activeDestination = order?.deliveryAddress ??
            ((savedAddr != null && !savedAddr.details.toLowerCase().contains('palazhi'))
                ? savedAddr
                : GpsDetectionService.instance.lastDetectedAddress ??
                    const Address(
                      id: 'addr_live_blr',
                      label: 'Bengaluru (Live GPS)',
                      details: 'Church Street / Brigade Road Area, Bengaluru - 560001',
                      lat: 12.9753,
                      lng: 77.5910,
                      isDefault: true,
                    ));

        final originRestaurant = LocationService.instance.getNearestRestaurant(
          lat: activeDestination.lat,
          lng: activeDestination.lng,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final maxH = constraints.maxHeight;
              // Sized dynamically so the map always has ample visible breathing room
              final collapsedHeight = math.min(170.0, maxH * 0.28);
              final expandedHeight = math.min(maxH * 0.74, 560.0);
              final sheetHeight = _expanded ? expandedHeight : collapsedHeight;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // ── Map Layer with Dynamic GPS Route & Animated Rider ───
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, _) {
                        double currentProgress = 0.45;
                        if (status == OrderStatus.delivered) {
                          currentProgress = 1.0;
                        } else if (status == OrderStatus.outForDelivery) {
                          currentProgress =
                              0.15 + (_progressController.value * 0.75);
                        } else {
                          currentProgress = 0.05;
                        }
                        return InteractiveMapView(
                          destination: activeDestination,
                          customOriginLat: originRestaurant.lat,
                          customOriginLng: originRestaurant.lng,
                          originTitle: originRestaurant.name,
                          originSubtitle: originRestaurant.branch,
                          progress: currentProgress,
                          showControls: !_expanded,
                          showTelemetry: false,
                        );
                      },
                    ),
                  ),

                  // ── Top Navigation Bar ─────────────────────────────────
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Material(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: const CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              elevation: 4,
                              child: InkWell(
                                onTap: () {
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  } else {
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                      AppRoutes.home,
                                      (route) => false,
                                    );
                                  }
                                },
                                child: const SizedBox(
                                  width: 42,
                                  height: 42,
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            Material(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                              clipBehavior: Clip.antiAlias,
                              elevation: 4,
                              child: InkWell(
                                onTap: () {
                                  CustomerSupportSheet.show(
                                    context: context,
                                    orderId: orderId,
                                    riderName: order?.deliveryPartnerName ??
                                        MockData.deliveryPartnerName,
                                    riderPhone: order?.deliveryPartnerPhone ??
                                        MockData.deliveryPartnerPhone,
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.headset_mic_rounded,
                                          color: AppColors.copper, size: 16),
                                      SizedBox(width: 5),
                                      Text(
                                        'HELP',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          letterSpacing: 0.6,
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
                    ),
                  ),

                  // ── Floating Map Quick Action (Re-center / Call Driver) ─
                  if (!_expanded)
                    Positioned(
                      right: 16,
                      bottom: collapsedHeight + 16,
                      child: FloatingActionButton.small(
                        heroTag: 'recenter_map',
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.copper,
                        elevation: 4,
                        onPressed: () {
                          AppToast.showInfo(
                            context,
                            'Centered on delivery vehicle',
                          );
                        },
                        child: const Icon(Icons.my_location, size: 20),
                      ),
                    ),

                  // ── Expandable Non-Overlapping Bottom Tracking Sheet ───
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeInOutCubic,
                      height: sheetHeight,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 18,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: _TrackingSheet(
                        expanded: _expanded,
                        order: order,
                        orderId: orderId,
                        eta: eta,
                        status: status,
                        destination: activeDestination,
                        onAddressChanged: (newAddr) => setState(() {}),
                        onToggle: () => setState(() => _expanded = !_expanded),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          bottomNavigationBar:
              const ParagonBottomNav(current: ParagonTab.location),
        );
      },
    );
  }
}

/// The sleek non-overlapping tracking sheet with peek & expanded views
class _TrackingSheet extends StatelessWidget {
  const _TrackingSheet({
    required this.expanded,
    required this.onToggle,
    required this.order,
    required this.orderId,
    required this.eta,
    required this.status,
    required this.destination,
    this.onAddressChanged,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final OrderModel? order;
  final String orderId;
  final int eta;
  final OrderStatus status;
  final Address destination;
  final ValueChanged<Address>? onAddressChanged;

  @override
  Widget build(BuildContext context) {
    final items = order?.items ?? [];
    final riderName = order?.deliveryPartnerName ?? MockData.deliveryPartnerName;
    final riderPhone = order?.deliveryPartnerPhone ?? MockData.deliveryPartnerPhone;
    final riderPhoto = order?.deliveryPartnerPhotoUrl;

    return Column(
      children: [
        // ── Drag Pill & Header Toggle ───────────────────────────────────
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.hint.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // ── Peek Content (Visible in both collapsed and expanded states) ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      status == OrderStatus.delivered
                          ? 'Order Delivered'
                          : 'Estimated Delivery',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          status == OrderStatus.delivered
                              ? 'Delivered'
                              : '$eta mins',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: AppColors.copper,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        if (status != OrderStatus.delivered && order != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(${order?.formattedEstimatedDeliveryTime})',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentRed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.accentRed.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            status.name.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.accentRed,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (status != OrderStatus.delivered && order != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Kitchen Prep: ~${order?.prepTimeMinutes}m · Transit: ~${order?.transitMinutes}m',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _QuickCallButton(phone: riderPhone, name: riderName),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ── Scrollable Body when Expanded ───────────────────────────────
        if (expanded)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.border, height: 20),

                  // ── Stepper ───────────────────────────────────────────
                  _TrackStepper(
                    status: status,
                    prepTimeMinutes: order?.prepTimeMinutes,
                    transitMinutes: order?.transitMinutes,
                  ),
                  const SizedBox(height: 20),

                  // ── Delivery Partner Card ─────────────────────────────
                  _DeliveryPartnerCard(
                    name: riderName,
                    phone: riderPhone,
                    photoUrl: riderPhoto,
                  ),
                  const SizedBox(height: 18),

                  // ── Order & Address Details ───────────────────────────
                  _InfoLine(
                    icon: Icons.receipt_long_outlined,
                    label: 'Order ID',
                    value: order?.id ?? orderId,
                  ),
                  _InfoLine(
                    icon: Icons.credit_card,
                    label: 'Payment',
                    value: order?.paymentMethodLabel ?? 'Card Payment Ending *8754',
                  ),
                  _InfoLine(
                    icon: Icons.location_on_outlined,
                    label: 'Delivering to',
                    value: destination.label.isNotEmpty == true
                        ? '${destination.label} · ${destination.details}'
                        : destination.details,
                    actionLabel: 'Change ✏️',
                    onTap: () {
                      GpsLocationPickerSheet.show(
                        context: context,
                        initialAddress: destination,
                        onAddressSelected: (Address newAddr) async {
                          await OrderService.instance.updateDeliveryAddress(
                            order?.id ?? orderId,
                            newAddr,
                          );
                          onAddressChanged?.call(newAddr);
                          if (context.mounted) {
                            AppBanner.showSuccess(
                              context,
                              'Delivery address updated to ${newAddr.label} (${newAddr.details})!',
                              title: 'Address Updated',
                            );
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  // ── Items Breakdown ───────────────────────────────────
                  Text(
                    'Order Items',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (items.isNotEmpty) ...[
                    for (final item in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _OrderLine(
                          qty: item.quantity,
                          name: item.name,
                          price: item.lineTotal.toInt(),
                        ),
                      ),
                  ] else ...[
                    const _OrderLine(qty: 1, name: 'Special Chicken Biryani', price: 260),
                    const SizedBox(height: 8),
                    const _OrderLine(qty: 1, name: 'Paragon Dosa & Chutney', price: 120),
                  ],

                  const Divider(color: AppColors.border, height: 26),

                  // ── Price Summary ─────────────────────────────────────
                  _TotalLine(
                    label: 'Subtotal',
                    value: '₹${(order?.subtotal ?? 380).toInt()}',
                  ),
                  const SizedBox(height: 6),
                  _TotalLine(
                    label: 'Delivery fee',
                    value: '₹${(order?.deliveryFee ?? 30).toInt()}',
                  ),
                  const SizedBox(height: 8),
                  _TotalLine(
                    label: 'Grand Total',
                    value: '₹${(order?.grandTotal ?? 410).toInt()}',
                    bold: true,
                  ),

                  // ── Order Cancellation Actions / Details ──────────────
                  if (order?.canBeCancelled ?? true) ...[
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text(
                          'Cancel Order (100% Instant Refund)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentRed,
                          side: BorderSide(
                            color: AppColors.accentRed.withValues(alpha: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          OrderCancellationSheet.show(
                            context: context,
                            orderId: order?.id ?? orderId,
                            amount: order?.grandTotal ?? 410.0,
                            paymentMode: order?.paymentMethodLabel ??
                                'Original Payment Source',
                            isTakeaway: false,
                            onConfirmCancel: (reason) async {
                              await OrderService.instance.cancelOrder(
                                order?.id ?? orderId,
                                reason: reason,
                              );
                              if (context.mounted) {
                                AppBanner.showSuccess(
                                  context,
                                  'Order #${order?.id ?? orderId} cancelled. Refund processed to ${order?.paymentMethodLabel ?? "source account"}!',
                                  title: 'Order Cancelled',
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ] else if (order?.isCancelled == true) ...[
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accentRed.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.cancel,
                                  color: AppColors.accentRed, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'ORDER CANCELLED',
                                style: TextStyle(
                                  color: AppColors.accentRed,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          if (order?.cancellationReason != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Reason: ${order!.cancellationReason}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            order?.refundStatus ??
                                'Full refund of ₹${(order?.grandTotal ?? 410).toInt()} has been processed to original payment method.',
                            style: const TextStyle(
                              color: Color(0xFF81C784),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          // Collapsed Peek driver mini summary
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 34,
                    height: 34,
                    color: AppColors.backgroundElevated,
                    child: NetworkImageWithFallback(
                      url: riderPhoto ??
                          'https://images.unsplash.com/photo-1633332755192-727a05c4013d?auto=format&fit=crop&w=120&q=70',
                      fallbackIcon: Icons.two_wheeler,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Rider: $riderName is on the way',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: onToggle,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.copper,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'VIEW DETAILS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _QuickCallButton extends StatelessWidget {
  const _QuickCallButton({required this.phone, required this.name});

  final String phone;
  final String name;

  void _call() async {
    final uri = Uri(
      scheme: 'tel',
      path: phone.replaceAll(' ', ''),
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.copper,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.copper.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.phone_in_talk, color: Colors.white, size: 18),
        tooltip: 'Call Driver',
        onPressed: _call,
      ),
    );
  }
}

class _TrackStepper extends StatelessWidget {
  const _TrackStepper({
    this.status = OrderStatus.outForDelivery,
    this.prepTimeMinutes,
    this.transitMinutes,
  });

  final OrderStatus status;
  final int? prepTimeMinutes;
  final int? transitMinutes;

  @override
  Widget build(BuildContext context) {
    final isAccepted = status == OrderStatus.accepted ||
        status == OrderStatus.taken ||
        status == OrderStatus.outForDelivery ||
        status == OrderStatus.delivered;

    final isPreparing = status == OrderStatus.taken ||
        status == OrderStatus.outForDelivery ||
        status == OrderStatus.delivered;

    final isOut = status == OrderStatus.outForDelivery ||
        status == OrderStatus.delivered;

    final isDone = status == OrderStatus.delivered;

    final prepLabel = prepTimeMinutes != null
        ? 'Prep\n(~${prepTimeMinutes}m)'
        : 'Preparing';

    final transitLabel = transitMinutes != null
        ? 'Transit\n(~${transitMinutes}m)'
        : 'On the Way';

    return Row(
      children: [
        _Step(label: 'Confirmed', done: isAccepted),
        _StepBar(done: isPreparing),
        _Step(label: prepLabel, done: isPreparing),
        _StepBar(done: isOut),
        _Step(label: transitLabel, done: isOut),
        _StepBar(done: isDone),
        _Step(label: 'Delivered', done: isDone),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.done,
  });

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: done ? const Color(0xFF3FA34D) : AppColors.backgroundElevated,
            shape: BoxShape.circle,
            border: Border.all(
              color: done ? const Color(0xFF3FA34D) : AppColors.border,
              width: 2,
            ),
          ),
          child: Icon(
            done ? Icons.check : Icons.circle,
            color: done ? Colors.white : AppColors.hint,
            size: done ? 14 : 6,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 62,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: done ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 10,
              fontWeight: done ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Container(
          height: 3,
          color: done ? const Color(0xFF3FA34D) : AppColors.border,
        ),
      ),
    );
  }
}

class _DeliveryPartnerCard extends StatelessWidget {
  const _DeliveryPartnerCard({
    required this.name,
    required this.phone,
    this.photoUrl,
  });

  final String name;
  final String phone;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 44,
              height: 44,
              child: NetworkImageWithFallback(
                url: photoUrl ??
                    'https://images.unsplash.com/photo-1633332755192-727a05c4013d?auto=format&fit=crop&w=120&q=70',
                fallbackIcon: Icons.person,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 3),
                    const Text(
                      '4.9',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      phone,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.copper,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.phone, size: 14),
            label: const Text('Call', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            onPressed: () {
              CustomerSupportSheet.show(
                context: context,
                riderName: name,
                riderPhone: phone,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
    this.actionLabel,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.copper, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.copper.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  color: AppColors.copper,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      );
    }
    return content;
  }
}

class _OrderLine extends StatelessWidget {
  const _OrderLine({
    required this.qty,
    required this.name,
    required this.price,
  });

  final int qty;
  final String name;
  final int price;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${qty}x',
            style: const TextStyle(
              color: AppColors.copper,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          ),
        ),
        Text(
          '₹$price',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TotalLine extends StatelessWidget {
  const _TotalLine({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: bold ? AppColors.textPrimary : AppColors.textSecondary,
      fontSize: bold ? 15 : 13,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}

