import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/paragon_bottom_nav.dart';

/// Track Order — a stylised delivery map with a tracking panel that expands to
/// reveal the delivery partner, order id, payment, timing and item breakdown.
class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxH = constraints.maxHeight;
          final sheetHeight = _expanded ? maxH * 0.78 : 280.0;
          return Stack(
            children: [
              const Positioned.fill(child: _MapBackground()),
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Material(
                      color: Colors.black.withOpacity(0.4),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const SizedBox(
                          width: 42,
                          height: 42,
                          child: Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  height: sheetHeight,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: _TrackingSheet(
                    expanded: _expanded,
                    onToggle: () => setState(() => _expanded = !_expanded),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const ParagonBottomNav(current: ParagonTab.location),
    );
  }
}

/// The scrollable tracking details inside the bottom sheet.
class _TrackingSheet extends StatelessWidget {
  const _TrackingSheet({required this.expanded, required this.onToggle});

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Icon(
              expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated delivery',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '15:00',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: AppColors.copper),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'mins remaining',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const _TrackStepper(),
                const SizedBox(height: 24),
                const _DeliveryPartnerCard(),
                const SizedBox(height: 18),
                const _InfoLine(
                  icon: Icons.receipt_long_outlined,
                  label: 'Order ID',
                  value: MockData.orderId,
                ),
                const _InfoLine(
                  icon: Icons.credit_card,
                  label: 'Payment',
                  value: 'Card Payment Ending with *8754',
                ),
                const _InfoLine(
                  icon: Icons.access_time,
                  label: 'Delivery time',
                  value: 'Home  ·  7:30 AM - 8:00 AM',
                ),
                const SizedBox(height: 22),
                Text(
                  'My Order',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 14),
                const _OrderLine(qty: 1, name: 'Plain Dosa', price: 80),
                const SizedBox(height: 12),
                const _OrderLine(
                    qty: 1, name: 'Fresh Juice - Orange', price: 110),
                const Divider(color: AppColors.border, height: 30),
                const _TotalLine(label: 'Sub Total', value: '₹190'),
                const SizedBox(height: 8),
                const _TotalLine(label: 'Delivery fee', value: '₹30'),
                const SizedBox(height: 8),
                const _TotalLine(label: 'Total', value: '₹220', bold: true),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackStepper extends StatelessWidget {
  const _TrackStepper();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _Step(label: 'Order accepted', done: true, first: true),
        _StepBar(done: true),
        _Step(label: 'Taken', done: true),
        _StepBar(done: false),
        _Step(label: 'Done', done: false, last: true),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.done,
    this.first = false,
    this.last = false,
  });

  final String label;
  final bool done;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: done ? const Color(0xFF3FA34D) : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: done ? const Color(0xFF3FA34D) : AppColors.border,
              width: 2,
            ),
          ),
          child: Icon(
            done ? Icons.check : Icons.circle,
            color: done ? Colors.white : AppColors.hint,
            size: done ? 16 : 8,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: done ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 11,
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
        padding: const EdgeInsets.only(bottom: 26),
        child: Container(
          height: 3,
          color: done ? const Color(0xFF3FA34D) : AppColors.border,
        ),
      ),
    );
  }
}

class _DeliveryPartnerCard extends StatelessWidget {
  const _DeliveryPartnerCard();

  void _handleCall() async {
    final uri = Uri(
      scheme: 'tel',
      path: MockData.deliveryPartnerPhone.replaceAll(' ', ''),
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 48,
              height: 48,
              child: NetworkImageWithFallback(
                url:
                    'https://images.unsplash.com/photo-1633332755192-727a05c4013d?auto=format&fit=crop&w=120&q=70',
                fallbackIcon: Icons.person,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  MockData.deliveryPartnerName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  MockData.deliveryPartnerPhone,
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.accentRed,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _handleCall,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.call, color: Colors.white, size: 20),
              ),
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label:  ',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
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
        Text(
          '${qty}x',
          style: const TextStyle(
            color: AppColors.copper,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          '₹$price',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
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
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}

/// A stylised dark map: faint street grid, a red delivery route and markers
/// for the restaurant, the rider and the destination.
class _MapBackground extends StatelessWidget {
  const _MapBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(color: Color(0xFF15151A)),
        ),
        CustomPaint(painter: _MapPainter(), child: const SizedBox.expand()),
        // Street labels.
        const Positioned(
          left: 30,
          top: 120,
          child: Text('Kaipurath P',
              style: TextStyle(color: Color(0xFF55555F), fontSize: 12)),
        ),
        const Positioned(
          right: 40,
          top: 190,
          child: Text('Canoly Canal',
              style: TextStyle(color: Color(0xFF55555F), fontSize: 12)),
        ),
        // Restaurant marker (top).
        const Positioned(
          left: 70,
          top: 90,
          child: _MapMarker(
            color: AppColors.accentRed,
            icon: Icons.restaurant,
          ),
        ),
        // Rider marker (mid).
        const Positioned(
          right: 90,
          top: 150,
          child: _MapMarker(
            color: AppColors.copper,
            icon: Icons.two_wheeler,
          ),
        ),
        // Destination marker.
        const Positioned(
          left: 120,
          top: 210,
          child: _MapMarker(
            color: Colors.white,
            icon: Icons.home,
            iconColor: Color(0xFF15151A),
          ),
        ),
      ],
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.color,
    required this.icon,
    this.iconColor = Colors.white,
  });

  final Color color;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final street = Paint()
      ..color = const Color(0xFF23232B)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // A few criss-crossing streets.
    canvas.drawLine(
        Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.18),
        street);
    canvas.drawLine(Offset(size.width * 0.2, 0),
        Offset(size.width * 0.35, size.height), street);
    canvas.drawLine(Offset(size.width * 0.8, 0),
        Offset(size.width * 0.6, size.height), street);
    canvas.drawLine(
        Offset(0, size.height * 0.55), Offset(size.width, size.height * 0.62),
        street);

    // The delivery route (dashed-ish red path).
    final route = Paint()
      ..color = AppColors.accentRed
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(90, 118)
      ..cubicTo(140, 150, 180, 150, size.width - 100, 175)
      ..cubicTo(size.width - 60, 195, 160, 210, 140, 232);
    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
