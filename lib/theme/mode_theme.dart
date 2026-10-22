import 'package:flutter/material.dart';

import '../state/app_mode_controller.dart';

/// Centralized theme configuration for the 5 Restaurant App modes:
/// 1. Order Food (Burgundy / Dark Wine)
/// 2. Take Away (Warm Amber / Dark Chocolate)
/// 3. Reserve Table (Paragon Warm Gold / Deep Espresso)
/// 4. Catering (Emerald Mint / Deep Forest)
/// 5. Food Planner (Royal Amethyst / Midnight Plum)
///
/// Ensures the top navigation bar, active curved tab shape, borders, inactive tabs,
/// and cascading background mesh gradient all share a cohesive, harmonious palette.
class ModeTheme {
  const ModeTheme({
    required this.mode,
    required this.id,
    required this.primaryAccent,
    required this.upperBackgroundColor,
    required this.lowerBackgroundColor,
    required this.selectedFillColor,
    required this.unselectedFillColor,
    required this.navBgTop,
    required this.navBgMiddle,
    required this.navBgBottom,
    required this.tabFillTop,
    required this.tabFillMiddle,
    required this.tabFillBottom,
    required this.tabBorderApex,
    required this.tabBorderSide,
    required this.shelfLine,
    required this.glowColor,
    required this.inactiveText,
    required this.inactiveIcon,
    required this.activeText,
    required this.activeIcon,
    required this.dividerColor,
    required this.pageWashColors,
    required this.pageWashStops,
    required this.pageBloomColor,
  });

  final AppMode mode;
  final String id;
  final Color primaryAccent;

  /// Darker upper navigation surface behind the header and unselected tabs
  final Color upperBackgroundColor;

  /// Rich lower navigation surface immediately below and around the tab's lower edges
  final Color lowerBackgroundColor;

  /// Selected tab fill color (blends with [lowerBackgroundColor])
  final Color selectedFillColor;

  /// Unselected tab fill color (blends with [upperBackgroundColor])
  final Color unselectedFillColor;

  // Navigation bar continuous background gradient stops
  final Color navBgTop;
  final Color navBgMiddle;
  final Color navBgBottom;

  // Selected tab fill gradient
  final Color tabFillTop;
  final Color tabFillMiddle;
  final Color tabFillBottom;

  // Selected tab outline and continuous shelf
  final Color tabBorderApex;
  final Color tabBorderSide;
  final Color shelfLine;

  // Ambient glow
  final Color glowColor;

  // Tab text and icons
  final Color inactiveText;
  final Color inactiveIcon;
  final Color activeText;
  final Color activeIcon;

  // Subtle separator between inactive tabs
  final Color dividerColor;

  // Ambient page wash gradient (cascading from header down into page body)
  final List<Color> pageWashColors;
  final List<double> pageWashStops;
  final Color pageBloomColor;

  // ── Pre-configured Mode Themes ──────────────────────────────────────────

  /// 1. Order Food (Deep Burgundy / Wine)
  static const ModeTheme orderFood = ModeTheme(
    mode: AppMode.orderFood,
    id: 'order_food',
    primaryAccent: Color(0xFF5A001E),
    upperBackgroundColor: Color(0xFF1E020B),
    lowerBackgroundColor: Color(0xFF4A001B),
    selectedFillColor: Color(0xFF4A001B),
    unselectedFillColor: Color(0x381E020B),
    navBgTop: Color(0xFF1E020B),
    navBgMiddle: Color(0xFF280110),
    navBgBottom: Color(0xFF4A001B),
    tabFillTop: Color(0xFF5A0022),
    tabFillMiddle: Color(0xFF50001E),
    tabFillBottom: Color(0xFF4A001B),
    tabBorderApex: Color(0xFFC06D88),
    tabBorderSide: Color(0xFFA14F67),
    shelfLine: Color(0x40A14F67),
    glowColor: Color(0x38A14F67),
    inactiveText: Color(0xFFD1AAB6),
    inactiveIcon: Color(0xFFD1AAB6),
    activeText: Colors.white,
    activeIcon: Color(0xFFFFB84D),
    dividerColor: Color(0x24A14F67),
    pageWashColors: [
      Color(0xFF1E020B),
      Color(0xFF1E020B),
      Color(0xFF4A001B),
      Color(0xFF4A001B),
      Color(0xFF380014),
      Color(0xFF24000D),
      Color(0xFF140007),
      Colors.transparent,
    ],
    pageWashStops: [0.0, 0.10, 0.18, 0.32, 0.48, 0.66, 0.84, 1.0],
    pageBloomColor: Color(0xFF7A0E2B),
  );

  /// 2. Take Away (Warm Amber / Dark Chocolate Espresso)
  static const ModeTheme takeAway = ModeTheme(
    mode: AppMode.takeAway,
    id: 'take_away',
    primaryAccent: Color(0xFFFF9500),
    upperBackgroundColor: Color(0xFF1C0D02),
    lowerBackgroundColor: Color(0xFF462004),
    selectedFillColor: Color(0xFF462004),
    unselectedFillColor: Color(0x381C0D02),
    navBgTop: Color(0xFF1C0D02),
    navBgMiddle: Color(0xFF281303),
    navBgBottom: Color(0xFF462004),
    tabFillTop: Color(0xFF5A2B06),
    tabFillMiddle: Color(0xFF4E2405),
    tabFillBottom: Color(0xFF462004),
    tabBorderApex: Color(0xFFFFB366),
    tabBorderSide: Color(0xFFE58726),
    shelfLine: Color(0x40FF9500),
    glowColor: Color(0x4DFF9500),
    inactiveText: Color(0xFFDEBA9F),
    inactiveIcon: Color(0xFFDEBA9F),
    activeText: Colors.white,
    activeIcon: Colors.white,
    dividerColor: Color(0x28E58726),
    pageWashColors: [
      Color(0xFF1C0D02),
      Color(0xFF1C0D02),
      Color(0xFF462004),
      Color(0xFF462004),
      Color(0xFF331703),
      Color(0xFF220F02),
      Color(0xFF140901),
      Colors.transparent,
    ],
    pageWashStops: [0.0, 0.10, 0.18, 0.32, 0.48, 0.66, 0.84, 1.0],
    pageBloomColor: Color(0xFFFF9500),
  );

  /// 3. Reserve Table (Paragon Warm Gold / Deep Espresso)
  static const ModeTheme reserveTable = ModeTheme(
    mode: AppMode.reserveTable,
    id: 'reserve_table',
    primaryAccent: Color(0xFFFFC107),
    upperBackgroundColor: Color(0xFF171201),
    lowerBackgroundColor: Color(0xFF3D2E04),
    selectedFillColor: Color(0xFF3D2E04),
    unselectedFillColor: Color(0x38171201),
    navBgTop: Color(0xFF171201),
    navBgMiddle: Color(0xFF221A02),
    navBgBottom: Color(0xFF3D2E04),
    tabFillTop: Color(0xFF503D06),
    tabFillMiddle: Color(0xFF463505),
    tabFillBottom: Color(0xFF3D2E04),
    tabBorderApex: Color(0xFFFFE48A),
    tabBorderSide: Color(0xFFD6A522),
    shelfLine: Color(0x40FFC107),
    glowColor: Color(0x4DFFC107),
    inactiveText: Color(0xFFD9CCA8),
    inactiveIcon: Color(0xFFD9CCA8),
    activeText: Colors.white,
    activeIcon: Colors.white,
    dividerColor: Color(0x24D6A522),
    pageWashColors: [
      Color(0xFF171201),
      Color(0xFF171201),
      Color(0xFF3D2E04),
      Color(0xFF3D2E04),
      Color(0xFF2C2103),
      Color(0xFF1D1602),
      Color(0xFF100C01),
      Colors.transparent,
    ],
    pageWashStops: [0.0, 0.10, 0.18, 0.32, 0.48, 0.66, 0.84, 1.0],
    pageBloomColor: Color(0xFFFFC107),
  );

  /// 4. Catering (Emerald Mint / Deep Forest)
  static const ModeTheme catering = ModeTheme(
    mode: AppMode.catering,
    id: 'catering',
    primaryAccent: Color(0xFF10B981),
    upperBackgroundColor: Color(0xFF02160F),
    lowerBackgroundColor: Color(0xFF063B29),
    selectedFillColor: Color(0xFF063B29),
    unselectedFillColor: Color(0x3802160F),
    navBgTop: Color(0xFF02160F),
    navBgMiddle: Color(0xFF032217),
    navBgBottom: Color(0xFF063B29),
    tabFillTop: Color(0xFF0A4E36),
    tabFillMiddle: Color(0xFF08432E),
    tabFillBottom: Color(0xFF063B29),
    tabBorderApex: Color(0xFF6EE7B7),
    tabBorderSide: Color(0xFF10B981),
    shelfLine: Color(0x4010B981),
    glowColor: Color(0x4D10B981),
    inactiveText: Color(0xFFA6CFC3),
    inactiveIcon: Color(0xFFA6CFC3),
    activeText: Colors.white,
    activeIcon: Colors.white,
    dividerColor: Color(0x2410B981),
    pageWashColors: [
      Color(0xFF02160F),
      Color(0xFF02160F),
      Color(0xFF063B29),
      Color(0xFF063B29),
      Color(0xFF04291D),
      Color(0xFF031A12),
      Color(0xFF02100B),
      Colors.transparent,
    ],
    pageWashStops: [0.0, 0.10, 0.18, 0.32, 0.48, 0.66, 0.84, 1.0],
    pageBloomColor: Color(0xFF10B981),
  );

  /// 5. Food Planner (Royal Amethyst / Midnight Plum)
  static const ModeTheme foodPlanner = ModeTheme(
    mode: AppMode.foodPlanner,
    id: 'food_planner',
    primaryAccent: Color(0xFFA855F7),
    upperBackgroundColor: Color(0xFF140320),
    lowerBackgroundColor: Color(0xFF380C56),
    selectedFillColor: Color(0xFF380C56),
    unselectedFillColor: Color(0x38140320),
    navBgTop: Color(0xFF140320),
    navBgMiddle: Color(0xFF200632),
    navBgBottom: Color(0xFF380C56),
    tabFillTop: Color(0xFF4C1175),
    tabFillMiddle: Color(0xFF400E62),
    tabFillBottom: Color(0xFF380C56),
    tabBorderApex: Color(0xFFD8B4FE),
    tabBorderSide: Color(0xFFA855F7),
    shelfLine: Color(0x40A855F7),
    glowColor: Color(0x4DA855F7),
    inactiveText: Color(0xFFD0B6E6),
    inactiveIcon: Color(0xFFD0B6E6),
    activeText: Colors.white,
    activeIcon: Colors.white,
    dividerColor: Color(0x24A855F7),
    pageWashColors: [
      Color(0xFF140320),
      Color(0xFF140320),
      Color(0xFF380C56),
      Color(0xFF380C56),
      Color(0xFF28093E),
      Color(0xFF1B062A),
      Color(0xFF100319),
      Colors.transparent,
    ],
    pageWashStops: [0.0, 0.10, 0.18, 0.32, 0.48, 0.66, 0.84, 1.0],
    pageBloomColor: Color(0xFFA855F7),
  );

  static const List<ModeTheme> all = [
    orderFood,
    takeAway,
    reserveTable,
    catering,
    foodPlanner,
  ];

  static ModeTheme forMode(AppMode mode) {
    switch (mode) {
      case AppMode.orderFood:
        return orderFood;
      case AppMode.takeAway:
        return takeAway;
      case AppMode.reserveTable:
        return reserveTable;
      case AppMode.catering:
        return catering;
      case AppMode.foodPlanner:
        return foodPlanner;
    }
  }

  static ModeTheme forId(String id) {
    for (final t in all) {
      if (t.id == id) return t;
    }
    return orderFood;
  }

  /// Linearly interpolates between two [ModeTheme] instances.
  static ModeTheme lerp(ModeTheme a, ModeTheme b, double t) {
    final clampedT = t.clamp(0.0, 1.0);
    return ModeTheme(
      mode: clampedT < 0.5 ? a.mode : b.mode,
      id: clampedT < 0.5 ? a.id : b.id,
      primaryAccent: Color.lerp(a.primaryAccent, b.primaryAccent, clampedT)!,
      upperBackgroundColor: Color.lerp(a.upperBackgroundColor, b.upperBackgroundColor, clampedT)!,
      lowerBackgroundColor: Color.lerp(a.lowerBackgroundColor, b.lowerBackgroundColor, clampedT)!,
      selectedFillColor: Color.lerp(a.selectedFillColor, b.selectedFillColor, clampedT)!,
      unselectedFillColor: Color.lerp(a.unselectedFillColor, b.unselectedFillColor, clampedT)!,
      navBgTop: Color.lerp(a.navBgTop, b.navBgTop, clampedT)!,
      navBgMiddle: Color.lerp(a.navBgMiddle, b.navBgMiddle, clampedT)!,
      navBgBottom: Color.lerp(a.navBgBottom, b.navBgBottom, clampedT)!,
      tabFillTop: Color.lerp(a.tabFillTop, b.tabFillTop, clampedT)!,
      tabFillMiddle: Color.lerp(a.tabFillMiddle, b.tabFillMiddle, clampedT)!,
      tabFillBottom: Color.lerp(a.tabFillBottom, b.tabFillBottom, clampedT)!,
      tabBorderApex: Color.lerp(a.tabBorderApex, b.tabBorderApex, clampedT)!,
      tabBorderSide: Color.lerp(a.tabBorderSide, b.tabBorderSide, clampedT)!,
      shelfLine: Color.lerp(a.shelfLine, b.shelfLine, clampedT)!,
      glowColor: Color.lerp(a.glowColor, b.glowColor, clampedT)!,
      inactiveText: Color.lerp(a.inactiveText, b.inactiveText, clampedT)!,
      inactiveIcon: Color.lerp(a.inactiveIcon, b.inactiveIcon, clampedT)!,
      activeText: Color.lerp(a.activeText, b.activeText, clampedT)!,
      activeIcon: Color.lerp(a.activeIcon, b.activeIcon, clampedT)!,
      dividerColor: Color.lerp(a.dividerColor, b.dividerColor, clampedT)!,
      pageWashColors: List.generate(
        a.pageWashColors.length,
        (i) => Color.lerp(a.pageWashColors[i], b.pageWashColors[i], clampedT)!,
      ),
      pageWashStops: a.pageWashStops,
      pageBloomColor: Color.lerp(a.pageBloomColor, b.pageBloomColor, clampedT)!,
    );
  }
}
