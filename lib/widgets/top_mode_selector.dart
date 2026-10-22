import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../state/app_mode_controller.dart';
import '../theme/mode_theme.dart';

/// Configuration for the 5 Restaurant App modes in the top selector.
class ModeConfig {
  const ModeConfig({
    required this.mode,
    required this.id,
    required this.label,
    required this.icon,
    this.assetPath,
    required this.accentColor,
    required this.microTag,
    required this.route,
    required this.theme,
  });

  final AppMode mode;
  final String id;
  final String label;
  final IconData icon;
  final String? assetPath;
  final Color accentColor;
  final String microTag;
  final String route;
  final ModeTheme theme;
}

const List<ModeConfig> kAppModes = [
  ModeConfig(
    mode: AppMode.orderFood,
    id: 'order_food',
    label: 'Order Food',
    icon: Icons.lunch_dining_rounded,
    assetPath: 'assets/icons/modes/mode_order_food.png',
    accentColor: Color(0xFF5A001E), // Dark Wine / Deep Burgundy
    microTag: 'DELIVERY',
    route: AppRoutes.foodHome,
    theme: ModeTheme.orderFood,
  ),
  ModeConfig(
    mode: AppMode.takeAway,
    id: 'take_away',
    label: 'Take Away',
    icon: Icons.shopping_bag_rounded,
    assetPath: 'assets/icons/modes/mode_take_away.png',
    accentColor: Color(0xFFFF9500), // Golden Amber
    microTag: 'PICKUP',
    route: AppRoutes.takeawayDashboard,
    theme: ModeTheme.takeAway,
  ),
  ModeConfig(
    mode: AppMode.reserveTable,
    id: 'reserve_table',
    label: 'Reserve Table',
    icon: Icons.table_restaurant_rounded,
    assetPath: 'assets/icons/modes/mode_reserve_table.png',
    accentColor: Color(0xFFFFC107), // Paragon Warm Gold
    microTag: 'BOOKING',
    route: AppRoutes.reserveDashboard,
    theme: ModeTheme.reserveTable,
  ),
  ModeConfig(
    mode: AppMode.catering,
    id: 'catering',
    label: 'Catering',
    icon: Icons.room_service_rounded,
    assetPath: 'assets/icons/modes/mode_catering.png',
    accentColor: Color(0xFF10B981), // Emerald Mint
    microTag: 'EVENTS',
    route: AppRoutes.cateringDashboard,
    theme: ModeTheme.catering,
  ),
  ModeConfig(
    mode: AppMode.foodPlanner,
    id: 'food_planner',
    label: 'Food Planner',
    icon: Icons.calendar_month_rounded,
    assetPath: 'assets/icons/modes/mode_food_planner.png',
    accentColor: Color(0xFFA855F7), // Royal Amethyst
    microTag: 'WEEKLY',
    route: AppRoutes.foodPlanner,
    theme: ModeTheme.foodPlanner,
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

/// Returns the chosen theme for an app mode [id]
ModeTheme getModeTheme(String id) {
  try {
    return kAppModes.firstWhere((m) => m.id == id).theme;
  } catch (_) {
    return ModeTheme.orderFood;
  }
}

/// A top mode selector with organic curved flared tabs that dynamically
/// adapts its background, fill, outline, and glow to the selected mode's theme.
///
/// Features:
/// - Both selected and unselected tabs feature custom-sculpted navigation geometry.
/// - Unselected tabs are custom-shaped panels with gently crowned tops, rounded corners,
///   sculpted side boundaries, and curved lower transitions into the shared background.
/// - Selected mode is an elevated arched tab with concave flaring shoulders that
///   connect flush into the continuous baseline shelf.
/// - The continuous navigation background dynamically adopts the active mode palette.
/// - Thin, delicate outline around the curved tab apex and baseline shelf.
/// - Unselected modes sit naturally on the header with softly tinted muted icons and labels.
/// - Smooth horizontal glide and theme interpolation when switching between modes.
class TopModeSelector extends StatefulWidget {
  const TopModeSelector({
    super.key,
    this.selectedIndex,
    this.activeId,
    this.controller,
    this.padding = EdgeInsets.zero,
    this.onModeChanged,
    this.canvasColor = Colors.transparent,
    this.backgroundColor = Colors.transparent,
    this.theme,
  });

  final int? selectedIndex;
  final String? activeId;
  final TabController? controller;
  final EdgeInsetsGeometry padding;
  final ValueChanged<AppMode>? onModeChanged;
  final Color canvasColor;
  final Color backgroundColor;
  final ModeTheme? theme;

  @override
  State<TopModeSelector> createState() => _TopModeSelectorState();
}

class _TopModeSelectorState extends State<TopModeSelector> {
  final ScrollController _scrollController = ScrollController();

  static const double _barHeight = 76.0;
  static const double _tabTop = 4.0;

  double _lastTabWidth = 68.0;
  double _lastTabGap = 4.0;
  double _lastSidePad = 6.0;

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

  ModeTheme _resolveThemeForAnimIndex(double animIndex) {
    if (widget.theme != null) return widget.theme!;
    final lower = animIndex.floor().clamp(0, kAppModes.length - 1);
    final upper = animIndex.ceil().clamp(0, kAppModes.length - 1);
    final t = (animIndex - lower).clamp(0.0, 1.0);
    return ModeTheme.lerp(kAppModes[lower].theme, kAppModes[upper].theme, t);
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
        oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.theme != widget.theme) {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
        _autoScrollToActive(animated: true);
      }
    });
  }

  void _onModeControllerChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
        _autoScrollToActive(animated: true);
      }
    });
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

          if (maxW.isFinite && maxW > 0) {
            if (maxW < 340) {
              sidePad = 4.0;
              tabGap = 2.0;
              tabWidth = 60.0;
              totalWidth = sidePad * 2 + n * tabWidth + (n - 1) * tabGap;
            } else if (maxW <= 460) {
              sidePad = (maxW < 370) ? 4.0 : 6.0;
              tabGap = (maxW < 370) ? 2.0 : 4.0;
              tabWidth = (maxW - (sidePad * 2) - ((n - 1) * tabGap)) / n;
              totalWidth = maxW;
            } else {
              tabWidth = 76.0;
              tabGap = 6.0;
              final contentW = n * tabWidth + (n - 1) * tabGap;
              sidePad = ((maxW - contentW) / 2).clamp(6.0, double.infinity);
              totalWidth = maxW;
            }
          } else {
            sidePad = 6.0;
            tabGap = 4.0;
            tabWidth = 68.0;
            totalWidth = sidePad * 2 + n * tabWidth + (n - 1) * tabGap;
          }

          _lastTabWidth = tabWidth;
          _lastTabGap = tabGap;
          _lastSidePad = sidePad;

          const double rTop = 15.0;
          const double rBottom = 11.0;
          const double shelfY = 66.0;

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
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                  builder: (context, animIndex, _) {
                    final activeTheme = _resolveThemeForAnimIndex(animIndex);
                    final animLeft = sidePad + animIndex * (tabWidth + tabGap);
                    final animRight = animLeft + tabWidth;

                    return CustomPaint(
                      painter: _OrganicModeBarPainter(
                        left: animLeft,
                        right: animRight,
                        top: _tabTop,
                        shelfY: shelfY,
                        rTop: rTop,
                        rBottom: rBottom,
                        sidePad: sidePad,
                        tabWidth: tabWidth,
                        tabGap: tabGap,
                        totalWidth: totalWidth,
                        theme: activeTheme,
                      ),
                      child: Stack(
                        children: [
                          // Tab content and tap targets for all 5 modes
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
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                  child: Center(
                                    child: _ModeTabContent(
                                      mode: mode,
                                      isSelected: isSelected,
                                      theme: activeTheme,
                                    ),
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
}

/// Precision custom painter that renders:
/// 1. The continuous navigation background dynamically adapted to the active mode theme
/// 2. Individually custom-shaped unselected tabs with:
///    - Gently curved, raised upper edge with rounded top corners ($R \approx 10.5$)
///    - Slightly slanted, sculpted side boundaries
///    - Curved lower transitions into the shared baseline shelf
///    - Subtle borders separating neighboring tabs
///    - Dark, translucent panel fills that blend into the theme background
/// 3. The selected tab's raised, curved upper profile with convex corners ($R \approx 16$)
/// 4. Custom curved lower transitions with concave fillets ($R \approx 12$) connecting flush to the shelf
/// 5. A thin, subtle highlight outline around the selected tab and shelf line in the mode's accent palette
/// 6. A slightly brighter translucent fill and halo glow on the active tab
class _OrganicModeBarPainter extends CustomPainter {
  const _OrganicModeBarPainter({
    required this.left,
    required this.right,
    required this.top,
    required this.shelfY,
    required this.rTop,
    required this.rBottom,
    required this.sidePad,
    required this.tabWidth,
    required this.tabGap,
    required this.totalWidth,
    required this.theme,
  });

  final double left;
  final double right;
  final double top;
  final double shelfY;
  final double rTop;
  final double rBottom;
  final double sidePad;
  final double tabWidth;
  final double tabGap;
  final double totalWidth;
  final ModeTheme theme;

  void _drawUnselectedTab(
    Canvas canvas, {
    required double tLeft,
    required double tRight,
    required double tTop,
    required double shelfY,
    required double rTop,
    required double rBottom,
    required double opacity,
  }) {
    if (opacity <= 0.01) return;

    final unselRect = Rect.fromLTRB(tLeft, tTop, tRight, shelfY);
    const topInset = 1.2;
    final effectiveRTop = rTop.clamp(4.0, (tRight - tLeft) / 2.6);
    final xLeftTop = tLeft + topInset;
    final xRightTop = tRight - topInset;
    final midX = (tLeft + tRight) / 2;
    final apexY = tTop - 1.2;

    // 1. Soft and muted left outline (traces lower fillet into shelf and slanted left boundary)
    final leftPath = Path();
    leftPath.moveTo(tLeft, shelfY);
    leftPath.arcToPoint(
      Offset(tLeft + topInset * 0.5, shelfY - rBottom),
      radius: Radius.circular(rBottom),
      clockwise: false,
    );
    leftPath.quadraticBezierTo(
      xLeftTop - 0.5,
      (shelfY + tTop) / 2,
      xLeftTop,
      tTop + effectiveRTop,
    );

    final leftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.tabBorderSide.withValues(alpha: 0.12 * opacity),
          theme.shelfLine.withValues(alpha: 0.05 * opacity),
        ],
      ).createShader(unselRect)
      ..strokeWidth = 0.95
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(leftPath, leftPaint);

    // 2. Gently curved top crown outline (rounded corners and apex crowning)
    final topPath = Path();
    topPath.moveTo(xLeftTop, tTop + effectiveRTop);
    topPath.arcToPoint(
      Offset(xLeftTop + effectiveRTop, tTop),
      radius: Radius.circular(effectiveRTop),
      clockwise: true,
    );
    topPath.quadraticBezierTo(
      midX,
      apexY,
      xRightTop - effectiveRTop,
      tTop,
    );
    topPath.arcToPoint(
      Offset(xRightTop, tTop + effectiveRTop),
      radius: Radius.circular(effectiveRTop),
      clockwise: true,
    );

    final topPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          theme.tabBorderApex.withValues(alpha: 0.18 * opacity),
          theme.tabBorderApex.withValues(alpha: 0.32 * opacity),
          theme.tabBorderApex.withValues(alpha: 0.38 * opacity),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(unselRect)
      ..strokeWidth = 1.05
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(topPath, topPaint);

    // 3. Brighter and sharper right outline (traces slanted right boundary and lower fillet into shelf)
    final rightPath = Path();
    rightPath.moveTo(xRightTop, tTop + effectiveRTop);
    rightPath.quadraticBezierTo(
      xRightTop + 0.5,
      (shelfY + tTop) / 2,
      tRight - topInset * 0.5,
      shelfY - rBottom,
    );
    rightPath.arcToPoint(
      Offset(tRight, shelfY),
      radius: Radius.circular(rBottom),
      clockwise: false,
    );

    final rightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.tabBorderApex.withValues(alpha: 0.38 * opacity),
          theme.tabBorderSide.withValues(alpha: 0.24 * opacity),
          theme.shelfLine.withValues(alpha: 0.08 * opacity),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(unselRect)
      ..strokeWidth = 1.15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(rightPath, rightPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final startX = (left - rBottom).clamp(0.0, totalWidth);
    final endX = (right + rBottom).clamp(0.0, totalWidth);
    final effectiveRTop = rTop.clamp(2.0, (right - left) / 2.5);

    // 1. Upper navigation surface:
    // Fills (0, 0) to (totalWidth, shelfY), cleanly carving OUT the active tab arch
    // so the active tab remains transparent to receive the lower background layer.
    final upperBgPath = Path()
      ..moveTo(0, 0)
      ..lineTo(totalWidth, 0)
      ..lineTo(totalWidth, shelfY)
      ..lineTo(endX, shelfY);

    if (endX > right) {
      upperBgPath.arcToPoint(
        Offset(right, shelfY - rBottom),
        radius: Radius.circular(rBottom),
        clockwise: true,
      );
    } else {
      upperBgPath.lineTo(right, shelfY - rBottom);
    }

    upperBgPath.lineTo(right, top + effectiveRTop);
    upperBgPath.arcToPoint(
      Offset(right - effectiveRTop, top),
      radius: Radius.circular(effectiveRTop),
      clockwise: false,
    );
    upperBgPath.lineTo(left + effectiveRTop, top);
    upperBgPath.arcToPoint(
      Offset(left, top + effectiveRTop),
      radius: Radius.circular(effectiveRTop),
      clockwise: false,
    );
    upperBgPath.lineTo(left, shelfY - rBottom);

    if (left > startX) {
      upperBgPath.arcToPoint(
        Offset(startX, shelfY),
        radius: Radius.circular(rBottom),
        clockwise: true,
      );
    } else {
      upperBgPath.lineTo(startX, shelfY);
    }

    upperBgPath.lineTo(0, shelfY);
    upperBgPath.close();

    final upperBgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.navBgTop,
          theme.upperBackgroundColor,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, totalWidth, shelfY))
      ..style = PaintingStyle.fill;
    canvas.drawPath(upperBgPath, upperBgPaint);

    // 2. Lower navigation surface & Selected Tab:
    // Seamless single physical surface covering the area below shelfY
    // and rising UP into the custom active tab.
    final lowerBgPath = Path()
      ..moveTo(0, shelfY)
      ..lineTo(startX, shelfY);

    if (left > startX) {
      lowerBgPath.arcToPoint(
        Offset(left, shelfY - rBottom),
        radius: Radius.circular(rBottom),
        clockwise: false,
      );
    } else {
      lowerBgPath.lineTo(left, shelfY - rBottom);
    }

    lowerBgPath.lineTo(left, top + effectiveRTop);
    lowerBgPath.arcToPoint(
      Offset(left + effectiveRTop, top),
      radius: Radius.circular(effectiveRTop),
      clockwise: true,
    );
    lowerBgPath.lineTo(right - effectiveRTop, top);
    lowerBgPath.arcToPoint(
      Offset(right, top + effectiveRTop),
      radius: Radius.circular(effectiveRTop),
      clockwise: true,
    );
    lowerBgPath.lineTo(right, shelfY - rBottom);

    if (endX > right) {
      lowerBgPath.arcToPoint(
        Offset(endX, shelfY),
        radius: Radius.circular(rBottom),
        clockwise: false,
      );
    } else {
      lowerBgPath.lineTo(endX, shelfY);
    }

    lowerBgPath.lineTo(totalWidth, shelfY);
    lowerBgPath.lineTo(totalWidth, size.height);
    lowerBgPath.lineTo(0, size.height);
    lowerBgPath.close();

    final lowerBounds = Rect.fromLTWH(0, top, totalWidth, size.height - top);
    final lowerBgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.tabFillTop,
          theme.tabFillMiddle,
          theme.lowerBackgroundColor,
          theme.lowerBackgroundColor,
        ],
        stops: const [0.0, 0.32, 0.70, 1.0],
      ).createShader(lowerBounds)
      ..style = PaintingStyle.fill;
    canvas.drawPath(lowerBgPath, lowerBgPaint);

    // 3. Render each unselected tab as a custom-shaped curved panel
    final unselTop = top + 4.5;
    const rUnselTop = 10.5;
    const rUnselBottom = 6.0;
    final activeCenter = (left + right) / 2;

    for (int i = 0; i < kAppModes.length; i++) {
      final tLeft = sidePad + i * (tabWidth + tabGap);
      final tRight = tLeft + tabWidth;
      final tCenter = tLeft + tabWidth / 2;
      final dist = (tCenter - activeCenter).abs() / tabWidth;

      // When dist >= 0.8 it is completely unselected (opacity = 1.0)
      // When dist < 0.4 it is under the sliding active tab (opacity = 0.0)
      final opacity = ((dist - 0.4) / 0.4).clamp(0.0, 1.0);

      _drawUnselectedTab(
        canvas,
        tLeft: tLeft,
        tRight: tRight,
        tTop: unselTop,
        shelfY: shelfY,
        rTop: rUnselTop,
        rBottom: rUnselBottom,
        opacity: opacity,
      );
    }


    // 5. Ambient top crest halo glow on selected tab
    final glowRect = Rect.fromLTRB(left + 2, top - 2, right - 2, top + 16);
    final glowPath = Path()
      ..addRRect(RRect.fromRectAndRadius(glowRect, Radius.circular(effectiveRTop)));
    final glowPaint = Paint()
      ..color = theme.glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(glowPath, glowPaint);

    // 6. Thin, subtle outline separating the upper and lower surfaces
    // Traced continuously along shelfY and around the custom curved active tab
    final strokePath = Path();
    strokePath.moveTo(0, shelfY);
    strokePath.lineTo(startX, shelfY);

    if (left > startX) {
      strokePath.arcToPoint(
        Offset(left, shelfY - rBottom),
        radius: Radius.circular(rBottom),
        clockwise: false,
      );
    } else {
      strokePath.lineTo(left, shelfY - rBottom);
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
    strokePath.lineTo(right, shelfY - rBottom);

    if (endX > right) {
      strokePath.arcToPoint(
        Offset(endX, shelfY),
        radius: Radius.circular(rBottom),
        clockwise: false,
      );
    } else {
      strokePath.lineTo(right, shelfY);
    }

    strokePath.lineTo(totalWidth, shelfY);

    final strokeBounds = Rect.fromLTRB(0, top, totalWidth, shelfY + 2);
    final strokePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.tabBorderApex,
          theme.tabBorderSide,
          theme.shelfLine,
        ],
        stops: const [0.0, 0.45, 0.95],
      ).createShader(strokeBounds)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(strokePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _OrganicModeBarPainter oldDelegate) {
    return oldDelegate.left != left ||
        oldDelegate.right != right ||
        oldDelegate.top != top ||
        oldDelegate.shelfY != shelfY ||
        oldDelegate.totalWidth != totalWidth ||
        oldDelegate.sidePad != sidePad ||
        oldDelegate.tabWidth != tabWidth ||
        oldDelegate.tabGap != tabGap ||
        oldDelegate.theme != theme;
  }
}

/// Renders the mode tab icon, badge, and label with theme-tinted colors.
class _ModeTabContent extends StatelessWidget {
  const _ModeTabContent({
    required this.mode,
    required this.isSelected,
    required this.theme,
  });

  final ModeConfig mode;
  final bool isSelected;
  final ModeTheme theme;

  Widget _buildIcon() {
    final inactiveColor = theme.inactiveIcon;

    Widget buildAssetOrFallback() {
      if (mode.assetPath != null) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          opacity: isSelected ? 1.0 : 0.82,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            scale: isSelected ? 1.06 : 0.94,
            child: Image.asset(
              mode.assetPath!,
              width: 26,
              height: 26,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                mode.icon,
                size: 24,
                color: isSelected ? theme.activeIcon : inactiveColor,
              ),
            ),
          ),
        );
      }
      return Icon(
        mode.icon,
        size: 24,
        color: isSelected ? theme.activeIcon : inactiveColor,
      );
    }

    if (mode.id == 'take_away') {
      return Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          buildAssetOrFallback(),
          Positioned(
            bottom: -5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF), // Express Delivery Blue pill badge
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Text(
                '15 Mins',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return buildAssetOrFallback();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: Offset(0, isSelected ? 0.0 : 0.035),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 28,
            child: Center(child: _buildIcon()),
          ),
          const SizedBox(height: 5),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            style: TextStyle(
              fontSize: isSelected ? 11.0 : 10.0,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? theme.activeText : theme.inactiveText,
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
      ),
    );
  }
}
