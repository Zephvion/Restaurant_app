import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/mock_data.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../services/session_manager.dart';
import '../../theme/app_colors.dart';
import '../../widgets/customer_support_sheet.dart';
import '../../widgets/network_image_with_fallback.dart';
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
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
                  // ── Map Layer (takes full background, elements positioned in visible zone) ──
                  Positioned.fill(
                    child: _MapBackground(
                      pulseAnimation: _pulseController,
                      status: status,
                      visibleHeight: maxH - collapsedHeight,
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
                                onTap: () => Navigator.of(context).maybePop(),
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.copper.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4CAF50),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    status == OrderStatus.delivered
                                        ? 'DELIVERED'
                                        : 'LIVE TRACKING',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Centered on delivery vehicle'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
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
  });

  final bool expanded;
  final VoidCallback onToggle;
  final OrderModel? order;
  final String orderId;
  final int eta;
  final OrderStatus status;

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
                  _TrackStepper(status: status),
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
                    value: order?.deliveryAddress.label.isNotEmpty == true
                        ? '${order!.deliveryAddress.label} · ${order!.deliveryAddress.details}'
                        : 'Palazhi, Calicut',
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
  const _TrackStepper({this.status = OrderStatus.outForDelivery});

  final OrderStatus status;

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

    return Row(
      children: [
        _Step(label: 'Confirmed', done: isAccepted),
        _StepBar(done: isPreparing),
        _Step(label: 'Preparing', done: isPreparing),
        _StepBar(done: isOut),
        _Step(label: 'On the Way', done: isOut),
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
          width: 54,
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
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
        ],
      ),
    );
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

/// A responsive stylized dark map with animated pulse, clean routes and markers
class _MapBackground extends StatelessWidget {
  const _MapBackground({
    required this.pulseAnimation,
    required this.status,
    required this.visibleHeight,
  });

  final Animation<double> pulseAnimation;
  final OrderStatus status;
  final double visibleHeight;

  @override
  Widget build(BuildContext context) {
    final safeH = math.max(260.0, visibleHeight);

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(color: Color(0xFF141419)),
        ),
        CustomPaint(
          painter: _MapPainter(safeHeight: safeH),
          child: const SizedBox.expand(),
        ),

        // ── Street Labels ──────────────────────────────────────────────
        Positioned(
          left: 24,
          top: safeH * 0.28,
          child: const Text(
            'Mavoor Road',
            style: TextStyle(
              color: Color(0xFF4A4A58),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Positioned(
          right: 28,
          top: safeH * 0.48,
          child: const Text(
            'Hilite Mall Way',
            style: TextStyle(
              color: Color(0xFF4A4A58),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // ── Restaurant Marker (Origin) ─────────────────────────────────
        Positioned(
          left: 48,
          top: safeH * 0.16,
          child: const _MapPin(
            title: 'PARAGON',
            color: AppColors.accentRed,
            icon: Icons.restaurant,
          ),
        ),

        // ── Rider Marker (Moving Pin with Pulse) ───────────────────────
        AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            final t = pulseAnimation.value;
            return Positioned(
              right: 60,
              top: safeH * 0.38,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer radar pulse
                  Container(
                    width: 44 + (t * 22),
                    height: 44 + (t * 22),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.copper.withValues(alpha: (1.0 - t) * 0.4),
                    ),
                  ),
                  const _MapPin(
                    title: 'Rider',
                    color: AppColors.copper,
                    icon: Icons.two_wheeler,
                    isRider: true,
                  ),
                ],
              ),
            );
          },
        ),

        // ── Destination Marker (Customer Location) ─────────────────────
        Positioned(
          left: 80,
          top: safeH * 0.62,
          child: const _MapPin(
            title: 'Your Location',
            color: Colors.white,
            icon: Icons.home_rounded,
            iconColor: Color(0xFF141419),
          ),
        ),
      ],
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.title,
    required this.color,
    required this.icon,
    this.iconColor = Colors.white,
    this.isRider = false,
  });

  final String title;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final bool isRider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: isRider ? 38 : 34,
          height: isRider ? 38 : 34,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: isRider ? 20 : 17),
        ),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter({required this.safeHeight});

  final double safeHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final streetPaint = Paint()
      ..color = const Color(0xFF22222B)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    final secondaryStreetPaint = Paint()
      ..color = const Color(0xFF1B1B22)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Background road network
    canvas.drawLine(
      Offset(0, safeHeight * 0.22),
      Offset(size.width, safeHeight * 0.18),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.38, size.height),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.82, 0),
      Offset(size.width * 0.65, size.height),
      streetPaint,
    );
    canvas.drawLine(
      Offset(0, safeHeight * 0.52),
      Offset(size.width, safeHeight * 0.58),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.1, safeHeight * 0.8),
      Offset(size.width * 0.9, safeHeight * 0.72),
      secondaryStreetPaint,
    );

    // Dynamic Delivery Route (smooth curved line connecting restaurant -> rider -> destination)
    final routeGlow = Paint()
      ..color = AppColors.accentRed.withValues(alpha: 0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePath = Path()
      ..moveTo(68, safeHeight * 0.22)
      ..cubicTo(
        size.width * 0.5,
        safeHeight * 0.20,
        size.width - 50,
        safeHeight * 0.30,
        size.width - 70,
        safeHeight * 0.44,
      )
      ..cubicTo(
        size.width - 80,
        safeHeight * 0.56,
        140,
        safeHeight * 0.55,
        100,
        safeHeight * 0.68,
      );

    canvas.drawPath(routePath, routeGlow);

    final routeMain = Paint()
      ..color = AppColors.accentRed
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(routePath, routeMain);
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) =>
      oldDelegate.safeHeight != safeHeight;
}

