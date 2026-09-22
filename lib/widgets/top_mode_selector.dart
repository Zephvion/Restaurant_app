import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../state/app_mode_controller.dart';

/// Configuration for the 5 Restaurant App modes in the top selector.
class ModeConfig {
  const ModeConfig({
    required this.mode,
    required this.id,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.microTag,
    required this.route,
  });

  final AppMode mode;
  final String id;
  final String label;
  final IconData icon;
  final Color accentColor;
  final String microTag;
  final String route;
}

const List<ModeConfig> kAppModes = [
  ModeConfig(
    mode: AppMode.orderFood,
    id: 'order_food',
    label: 'Order Food',
    icon: Icons.lunch_dining_rounded,
    accentColor: Color(0xFFFF5252), // Vibrant Coral Red
    microTag: 'DELIVERY',
    route: AppRoutes.foodHome,
  ),
  ModeConfig(
    mode: AppMode.takeAway,
    id: 'take_away',
    label: 'Take Away',
    icon: Icons.shopping_bag_rounded,
    accentColor: Color(0xFFFF9800), // Vibrant Amber Orange
    microTag: 'PICKUP',
    route: AppRoutes.takeawayDashboard,
  ),
  ModeConfig(
    mode: AppMode.reserveTable,
    id: 'reserve_table',
    label: 'Reserve Table',
    icon: Icons.table_restaurant_rounded,
    accentColor: Color(0xFFFFB300), // Warm Gold
    microTag: 'BOOKING',
    route: AppRoutes.reserveDashboard,
  ),
  ModeConfig(
    mode: AppMode.catering,
    id: 'catering',
    label: 'Catering',
    icon: Icons.room_service_rounded,
    accentColor: Color(0xFF26A69A), // Teal
    microTag: 'EVENTS',
    route: AppRoutes.cateringDashboard,
  ),
  ModeConfig(
    mode: AppMode.foodPlanner,
    id: 'food_planner',
    label: 'Food Planner',
    icon: Icons.calendar_month_rounded,
    accentColor: Color(0xFFAB47BC), // Amethyst Purple
    microTag: 'WEEKLY',
    route: AppRoutes.foodPlanner,
  ),
];

/// A Swiggy-style top mode selector with organic curved flared tabs.
///
/// Features:
/// - ZERO rectangular cards or closed outline boxes.
/// - Selected mode is an elevated arched tab with concave flaring shoulders that
///   connect flush into the content canvas below with no bottom border.
/// - Unselected modes sit naturally on the header as subdued icons and labels.
/// - Smooth horizontal glide animation when switching between modes.
class TopModeSelector extends StatefulWidget {
  const TopModeSelector({
    super.key,
    this.selectedIndex,
    this.activeId,
    this.controller,
    this.padding = EdgeInsets.zero,
    this.onModeChanged,
    this.canvasColor = const Color(0xFF16161D),
    this.backgroundColor = const Color(0xFF0E0E11),
  });

  final int? selectedIndex;
  final String? activeId;
  final TabController? controller;
  final EdgeInsetsGeometry padding;
  final ValueChanged<AppMode>? onModeChanged;
  final Color canvasColor;
  final Color backgroundColor;

  @override
  State<TopModeSelector> createState() => _TopModeSelectorState();
}

class _TopModeSelectorState extends State<TopModeSelector> {
  final ScrollController _scrollController = ScrollController();

  static const double _tabWidth = 68.0;
  static const double _tabGap = 8.0;
  static const double _sidePad = 12.0;
  static const double _barHeight = 74.0;
  static const double _tabTop = 4.0;
  static const double _rTop = 14.0;
  static const double _rBottom = 8.0;

  double get _totalWidth =>
      _sidePad * 2 + (kAppModes.length * _tabWidth) + ((kAppModes.length - 1) * _tabGap);

  int get _currentIndex {
    if (widget.controller != null) {
      return widget.controller!.index;
    }
    if (widget.selectedIndex != null) {
      return widget.selectedIndex!.clamp(0, kAppModes.length - 1);
    }
    if (widget.activeId != null) {
      final idx = kAppModes.indexWhere((m) => m.id == widget.activeId);
      return idx >= 0 ? idx : 0;
    }
    final mode = AppModeController.instance.mode;
    final idx = kAppModes.indexWhere((m) => m.mode == mode);
    return idx >= 0 ? idx : 0;
  }

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerChange);
    AppModeController.instance.addListener(_onModeControllerChange);
  }

  @override
  void didUpdateWidget(covariant TopModeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChange);
      widget.controller?.addListener(_onControllerChange);
    }
    _autoScrollToActive();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChange);
    AppModeController.instance.removeListener(_onModeControllerChange);
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) {
      setState(() {});
      _autoScrollToActive();
    }
  }

  void _onModeControllerChange() {
    if (mounted) {
      setState(() {});
      _autoScrollToActive();
    }
  }

  void _autoScrollToActive() {
    if (!_scrollController.hasClients) return;
    final idx = _currentIndex;
    final targetX = _sidePad + idx * (_tabWidth + _tabGap) - 40;
    _scrollController.animateTo(
      targetX.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
    );
  }

  void _handleTabTap(int index) {
    final modeConfig = kAppModes[index];
    if (widget.controller != null) {
      widget.controller!.animateTo(
        index,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    }
    AppModeController.instance.setMode(modeConfig.mode);
    widget.onModeChanged?.call(modeConfig.mode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex;

    return Padding(
      padding: widget.padding,
      child: Container(
        width: double.infinity,
        height: _barHeight,
        color: widget.backgroundColor,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: _totalWidth,
            height: _barHeight,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: currentIndex.toDouble(),
                end: currentIndex.toDouble(),
              ),
              duration: const Duration(milliseconds: 550),
              curve: Curves.easeInOutCubic,
              builder: (context, animIndex, child) {
                final left = _sidePad + animIndex * (_tabWidth + _tabGap);
                final right = left + _tabWidth;

                final lowerIdx = animIndex.floor().clamp(0, kAppModes.length - 1);
                final upperIdx = animIndex.ceil().clamp(0, kAppModes.length - 1);
                final t = (animIndex - lowerIdx).clamp(0.0, 1.0);
                final currentColor = Color.lerp(
                  kAppModes[lowerIdx].accentColor,
                  kAppModes[upperIdx].accentColor,
                  t,
                )!;

                return CustomPaint(
                  painter: _SwiggyFlaredTabPainter(
                    left: left,
                    right: right,
                    top: _tabTop,
                    bottom: _barHeight,
                    rTop: _rTop,
                    rBottom: _rBottom,
                    fillColor: widget.canvasColor,
                    accentColor: currentColor,
                    totalWidth: _totalWidth,
                  ),
                  child: child,
                );
              },
              child: Stack(
                children: List.generate(kAppModes.length, (i) {
                  final mode = kAppModes[i];
                  final isSelected = i == currentIndex;
                  final tabLeft = _sidePad + i * (_tabWidth + _tabGap);

                  return Positioned(
                    left: tabLeft,
                    top: _tabTop,
                    width: _tabWidth,
                    height: _barHeight - _tabTop,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _handleTabTap(i),
                      child: _ModeTabContent(
                        mode: mode,
                        isSelected: isSelected,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders the icon, label, and micro tag inside each tab slot.
class _ModeTabContent extends StatelessWidget {
  const _ModeTabContent({
    required this.mode,
    required this.isSelected,
  });

  final ModeConfig mode;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      padding: const EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 6,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mode Icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            width: isSelected ? 28 : 22,
            height: isSelected ? 28 : 22,
            decoration: isSelected
                ? BoxDecoration(
                    color: mode.accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            alignment: Alignment.center,
            child: Icon(
              mode.icon,
              size: isSelected ? 18 : 16,
              color: isSelected
                  ? mode.accentColor
                  : Colors.white.withValues(alpha: 0.60),
            ),
          ),
          const SizedBox(height: 4),
          // Mode Label
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            style: TextStyle(
              fontSize: isSelected ? 10.5 : 9.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.65),
              letterSpacing: 0.1,
              height: 1.1,
            ),
            child: Text(
              mode.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter that draws the Swiggy arched bell/folder tab with concave flaring shoulders.
///
/// Follows smooth C1-continuous curvature:
/// - Convex rounded corners on top ($R_{top} = 14$).
/// - Concave fillet flaring arcs at the bottom ($R_{bottom} = 8$) that sweep outward
///   onto the baseline.
/// - Glowing ambient shadow.
/// - Top and side highlight stroke (no stroke at bottom baseline).
/// - Baseline divider line on either side of the flared tab.
class _SwiggyFlaredTabPainter extends CustomPainter {
  const _SwiggyFlaredTabPainter({
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
    required this.rTop,
    required this.rBottom,
    required this.fillColor,
    required this.accentColor,
    required this.totalWidth,
  });

  final double left;
  final double right;
  final double top;
  final double bottom;
  final double rTop;
  final double rBottom;
  final Color fillColor;
  final Color accentColor;
  final double totalWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Construct the closed organic flared tab path for fill and shadow
    final fillPath = Path();

    // Start on baseline at the outer tip of the left concave flare
    fillPath.moveTo(left - rBottom, bottom);

    // Concave arc curving upward and inward to the left vertical edge
    fillPath.arcToPoint(
      Offset(left, bottom - rBottom),
      radius: Radius.circular(rBottom),
      clockwise: false,
    );

    // Left vertical line
    fillPath.lineTo(left, top + rTop);

    // Convex rounded top-left corner
    fillPath.arcToPoint(
      Offset(left + rTop, top),
      radius: Radius.circular(rTop),
      clockwise: true,
    );

    // Top horizontal line
    fillPath.lineTo(right - rTop, top);

    // Convex rounded top-right corner
    fillPath.arcToPoint(
      Offset(right, top + rTop),
      radius: Radius.circular(rTop),
      clockwise: true,
    );

    // Right vertical line
    fillPath.lineTo(right, bottom - rBottom);

    // Concave arc curving downward and outward to baseline
    fillPath.arcToPoint(
      Offset(right + rBottom, bottom),
      radius: Radius.circular(rBottom),
      clockwise: false,
    );

    // Close along baseline
    fillPath.lineTo(left - rBottom, bottom);
    fillPath.close();

    // 2. Ambient top glow shadow
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(fillPath, glowPaint);

    // 3. Tab fill (matches content canvas below)
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // 4. Highlight stroke on top and flared sides (excluding bottom baseline)
    final strokePath = Path();
    strokePath.moveTo(left - rBottom, bottom);
    strokePath.arcToPoint(
      Offset(left, bottom - rBottom),
      radius: Radius.circular(rBottom),
      clockwise: false,
    );
    strokePath.lineTo(left, top + rTop);
    strokePath.arcToPoint(
      Offset(left + rTop, top),
      radius: Radius.circular(rTop),
      clockwise: true,
    );
    strokePath.lineTo(right - rTop, top);
    strokePath.arcToPoint(
      Offset(right, top + rTop),
      radius: Radius.circular(rTop),
      clockwise: true,
    );
    strokePath.lineTo(right, bottom - rBottom);
    strokePath.arcToPoint(
      Offset(right + rBottom, bottom),
      radius: Radius.circular(rBottom),
      clockwise: false,
    );

    final strokePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.90)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(strokePath, strokePaint);

    // 5. Baseline divider line flanking the active tab on left and right
    final baselinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final flareLeft = left - rBottom;
    final flareRight = right + rBottom;

    if (flareLeft > 0) {
      canvas.drawLine(Offset(0, bottom), Offset(flareLeft, bottom), baselinePaint);
    }
    if (flareRight < totalWidth) {
      canvas.drawLine(Offset(flareRight, bottom), Offset(totalWidth, bottom), baselinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SwiggyFlaredTabPainter oldDelegate) {
    return oldDelegate.left != left ||
        oldDelegate.right != right ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.fillColor != fillColor;
  }
}
