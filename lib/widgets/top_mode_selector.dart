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
    accentColor: Color(0xFFFF4B4B), // Coral Crimson
    microTag: 'DELIVERY',
    route: AppRoutes.foodHome,
  ),
  ModeConfig(
    mode: AppMode.takeAway,
    id: 'take_away',
    label: 'Take Away',
    icon: Icons.shopping_bag_rounded,
    accentColor: Color(0xFFFF9500), // Golden Amber
    microTag: 'PICKUP',
    route: AppRoutes.takeawayDashboard,
  ),
  ModeConfig(
    mode: AppMode.reserveTable,
    id: 'reserve_table',
    label: 'Reserve Table',
    icon: Icons.table_restaurant_rounded,
    accentColor: Color(0xFFFFC107), // Paragon Warm Gold
    microTag: 'BOOKING',
    route: AppRoutes.reserveDashboard,
  ),
  ModeConfig(
    mode: AppMode.catering,
    id: 'catering',
    label: 'Catering',
    icon: Icons.room_service_rounded,
    accentColor: Color(0xFF10B981), // Emerald Mint
    microTag: 'EVENTS',
    route: AppRoutes.cateringDashboard,
  ),
  ModeConfig(
    mode: AppMode.foodPlanner,
    id: 'food_planner',
    label: 'Food Planner',
    icon: Icons.calendar_month_rounded,
    accentColor: Color(0xFFA855F7), // Royal Amethyst
    microTag: 'WEEKLY',
    route: AppRoutes.foodPlanner,
  ),
];

/// Returns the chosen accent color for an app mode [id]
Color getModeAccentColor(String id) {
  try {
    return kAppModes.firstWhere((m) => m.id == id).accentColor;
  } catch (_) {
    return const Color(0xFFFF4B4B);
  }
}

/// A top mode selector with organic curved flared tabs.
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
    this.canvasColor = const Color(0xFF0E0E11),
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

  static const double _barHeight = 74.0;
  static const double _tabTop = 4.0;

  double _lastTabWidth = 68.0;
  double _lastTabGap = 6.0;
  double _lastSidePad = 8.0;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _autoScrollToActive(animated: false);
    });
  }

  @override
  void didUpdateWidget(covariant TopModeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChange);
      widget.controller?.addListener(_onControllerChange);
    }
    if (oldWidget.activeId != widget.activeId ||
        oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _autoScrollToActive(animated: true);
      });
    }
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _autoScrollToActive(animated: true);
      });
    }
  }

  void _onModeControllerChange() {
    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _autoScrollToActive(animated: true);
      });
    }
  }

  void _autoScrollToActive({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    final idx = _currentIndex;
    final tabLeft = _lastSidePad + idx * (_lastTabWidth + _lastTabGap);
    final tabCenter = tabLeft + _lastTabWidth / 2;
    final viewportWidth = _scrollController.position.viewportDimension;
    final targetX = (tabCenter - viewportWidth / 2).clamp(0.0, maxScroll);

    if (animated) {
      _scrollController.animateTo(
        targetX,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _scrollController.jumpTo(targetX);
    }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _autoScrollToActive(animated: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex;

    return Padding(
      padding: widget.padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final n = kAppModes.length;

          double sidePad;
          double tabGap;
          double tabWidth;
          double totalWidth;
          double rBottom;
          const double rTop = 12.0;

          if (maxW.isFinite && maxW > 0) {
            if (maxW < 330) {
              sidePad = 6.0;
              tabGap = 4.0;
              tabWidth = 62.0;
              totalWidth = sidePad * 2 + n * tabWidth + (n - 1) * tabGap;
              rBottom = 6.0;
            } else if (maxW <= 460) {
              sidePad = (maxW < 370) ? 6.0 : 8.0;
              tabGap = (maxW < 370) ? 4.0 : 6.0;
              tabWidth = (maxW - (sidePad * 2) - ((n - 1) * tabGap)) / n;
              totalWidth = maxW;
              rBottom = sidePad;
            } else {
              tabWidth = 78.0;
              tabGap = 8.0;
              final contentW = n * tabWidth + (n - 1) * tabGap;
              sidePad = ((maxW - contentW) / 2).clamp(8.0, double.infinity);
              totalWidth = maxW;
              rBottom = 8.0;
            }
          } else {
            sidePad = 8.0;
            tabGap = 6.0;
            tabWidth = 68.0;
            totalWidth = sidePad * 2 + n * tabWidth + (n - 1) * tabGap;
            rBottom = 8.0;
          }

          _lastTabWidth = tabWidth;
          _lastTabGap = tabGap;
          _lastSidePad = sidePad;

          return Container(
            width: double.infinity,
            height: _barHeight,
            color: widget.backgroundColor,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: totalWidth,
                height: _barHeight,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: currentIndex.toDouble(),
                    end: currentIndex.toDouble(),
                  ),
                  duration: const Duration(milliseconds: 550),
                  curve: Curves.easeInOutCubic,
                  builder: (context, animIndex, _) {
                    final left = sidePad + animIndex * (tabWidth + tabGap);
                    final right = left + tabWidth;

                    final lowerIdx =
                        animIndex.floor().clamp(0, kAppModes.length - 1);
                    final upperIdx =
                        animIndex.ceil().clamp(0, kAppModes.length - 1);
                    final t = (animIndex - lowerIdx).clamp(0.0, 1.0);
                    final currentColor = Color.lerp(
                      kAppModes[lowerIdx].accentColor,
                      kAppModes[upperIdx].accentColor,
                      t,
                    )!;

                    return CustomPaint(
                      painter: _OrganicFlaredTabPainter(
                        left: left,
                        right: right,
                        top: _tabTop,
                        bottom: _barHeight,
                        rTop: rTop,
                        rBottom: rBottom,
                        fillColor: widget.canvasColor,
                        accentColor: currentColor,
                        totalWidth: totalWidth,
                      ),
                      child: Stack(
                        children: [
                          if (currentIndex > 0)
                            _buildUnselectedGroupContainer(
                              startIdx: 0,
                              endIdx: currentIndex - 1,
                              sidePad: sidePad,
                              tabWidth: tabWidth,
                              tabGap: tabGap,
                              color: currentColor,
                            ),
                          if (currentIndex < kAppModes.length - 1)
                            _buildUnselectedGroupContainer(
                              startIdx: currentIndex + 1,
                              endIdx: kAppModes.length - 1,
                              sidePad: sidePad,
                              tabWidth: tabWidth,
                              tabGap: tabGap,
                              color: currentColor,
                            ),
                          ...List.generate(kAppModes.length, (i) {
                            final mode = kAppModes[i];
                            final isSelected = i == currentIndex;
                            final tabLeft = sidePad + i * (tabWidth + tabGap);

                            return Positioned(
                              left: tabLeft,
                              top: _tabTop,
                              width: tabWidth,
                              height: _barHeight - _tabTop,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _handleTabTap(i),
                                child: Center(
                                  child: _ModeTabContent(
                                    mode: mode,
                                    isSelected: isSelected,
                                    activeColor: currentColor,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnselectedGroupContainer({
    required int startIdx,
    required int endIdx,
    required double sidePad,
    required double tabWidth,
    required double tabGap,
    required Color color,
  }) {
    final left = sidePad + startIdx * (tabWidth + tabGap);
    final count = endIdx - startIdx + 1;
    final width = count * tabWidth + (count - 1) * tabGap;
    const top = _tabTop + 5.0;
    const height = _barHeight - _tabTop - 11.0;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.55),
              width: 1.2,
            ),
          ),
          child: count > 1
              ? Stack(
                  children: List.generate(count - 1, (i) {
                    final divLeft = (i + 1) * (tabWidth + tabGap) - tabGap / 2;
                    return Positioned(
                      left: divLeft - 0.5,
                      top: 10,
                      bottom: 10,
                      width: 1,
                      child: Container(
                        color: color.withValues(alpha: 0.22),
                      ),
                    );
                  }),
                )
              : null,
        ),
      ),
    );
  }
}

/// Renders the button icon (in white) and text label.
class _ModeTabContent extends StatelessWidget {
  const _ModeTabContent({
    required this.mode,
    required this.isSelected,
    required this.activeColor,
  });

  final ModeConfig mode;
  final bool isSelected;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          mode.icon,
          size: isSelected ? 21 : 18,
          color: Colors.white,
        ),
        const SizedBox(height: 5),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          style: TextStyle(
            fontSize: isSelected ? 11.0 : 10.0,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.82),
            letterSpacing: isSelected ? 0.2 : 0.0,
            height: 1.1,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              mode.label,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter that draws the organic arched bell/folder tab with concave flaring shoulders.
///
/// Follows smooth C1-continuous curvature:
/// - Convex rounded corners on top ($R_{top} = 12$).
/// - Concave fillet flaring arcs at the bottom ($R_{bottom} = 6..8$) that sweep outward
///   onto the baseline.
/// - Focused ambient top crest halo glow (avoids lateral bleeding into screen background).
/// - Volumetric ambient inner top-down gradient fill.
/// - Dissolving vertical stroke gradient: crisp bright apex that gracefully fades to 0%
///   opacity before the baseline, completely eliminating harsh colored side wings.
/// - Hairline baseline divider line flanking the flared tab.
class _OrganicFlaredTabPainter extends CustomPainter {
  const _OrganicFlaredTabPainter({
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
    final startX = (left - rBottom).clamp(0.0, totalWidth);
    final endX = (right + rBottom).clamp(0.0, totalWidth);
    final effectiveRTop = rTop.clamp(2.0, (right - left) / 2.5);

    // 1. Construct the closed organic flared tab path for fill and inner glow
    final fillPath = Path();
    fillPath.moveTo(startX, bottom);

    if (left > startX) {
      fillPath.arcToPoint(
        Offset(left, bottom - rBottom),
        radius: Radius.circular(rBottom),
        clockwise: false,
      );
    } else {
      fillPath.lineTo(left, bottom - rBottom);
    }

    fillPath.lineTo(left, top + effectiveRTop);
    fillPath.arcToPoint(
      Offset(left + effectiveRTop, top),
      radius: Radius.circular(effectiveRTop),
      clockwise: true,
    );
    fillPath.lineTo(right - effectiveRTop, top);
    fillPath.arcToPoint(
      Offset(right, top + effectiveRTop),
      radius: Radius.circular(effectiveRTop),
      clockwise: true,
    );
    fillPath.lineTo(right, bottom - rBottom);

    if (endX > right) {
      fillPath.arcToPoint(
        Offset(endX, bottom),
        radius: Radius.circular(rBottom),
        clockwise: false,
      );
    } else {
      fillPath.lineTo(right, bottom);
    }

    fillPath.lineTo(startX, bottom);
    fillPath.close();

    // 2. Focused ambient top-crest halo glow (avoids bleeding below the baseline or harsh lateral horns)
    final crestGlowRect = Rect.fromLTRB(left + 2, top - 2, right - 2, top + 18);
    final crestGlowPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        crestGlowRect,
        Radius.circular(effectiveRTop),
      ));
    final crestGlowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(crestGlowPath, crestGlowPaint);

    // 3. Tab base fill (matches content canvas below perfectly)
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // 4. Volumetric ambient inner top-down gradient
    // Adds luxurious depth at the top crown while dissolving seamlessly into the page background at the baseline
    final tabBounds = Rect.fromLTRB(startX, top, endX, bottom);
    final innerGlowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accentColor.withValues(alpha: 0.16),
          accentColor.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.95],
      ).createShader(tabBounds)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, innerGlowPaint);

    // 5. Dissolving highlight stroke along the arched cap and flared sides
    // Uses a vertical gradient shader that fades to 0% opacity before the baseline,
    // completely eliminating harsh colored side wings while keeping the curved cap ultra crisp.
    final strokePath = Path();
    strokePath.moveTo(startX, bottom);
    if (left > startX) {
      strokePath.arcToPoint(
        Offset(left, bottom - rBottom),
        radius: Radius.circular(rBottom),
        clockwise: false,
      );
    } else {
      strokePath.lineTo(left, bottom - rBottom);
    }
    strokePath.lineTo(left, top + effectiveRTop);
    strokePath.arcToPoint(
      Offset(left + effectiveRTop, top),
      radius: Radius.circular(effectiveRTop),
      clockwise: true,
    );
    strokePath.lineTo(right - effectiveRTop, top);
    strokePath.arcToPoint(
      Offset(right, top + effectiveRTop),
      radius: Radius.circular(effectiveRTop),
      clockwise: true,
    );
    strokePath.lineTo(right, bottom - rBottom);
    if (endX > right) {
      strokePath.arcToPoint(
        Offset(endX, bottom),
        radius: Radius.circular(rBottom),
        clockwise: false,
      );
    } else {
      strokePath.lineTo(right, bottom);
    }

    final strokePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accentColor.withValues(alpha: 0.95), // Crisp luminous top apex
          accentColor.withValues(alpha: 0.65), // Upper curved corners
          accentColor.withValues(alpha: 0.18), // Dissolving mid-body
          Colors.transparent,                  // Completely transparent at baseline
        ],
        stops: const [0.0, 0.35, 0.70, 0.96],
      ).createShader(tabBounds)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(strokePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _OrganicFlaredTabPainter oldDelegate) {
    return oldDelegate.left != left ||
        oldDelegate.right != right ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.totalWidth != totalWidth;
  }
}
