import 'package:flutter/material.dart';

import '../../state/app_mode_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/mode_theme.dart';
import '../../widgets/main_top_header.dart';
import '../../widgets/top_mode_selector.dart';
import '../catering/catering_dashboard_screen.dart';
import '../food_planner/food_planner_shell_screen.dart';
import '../order_food/food_home_screen.dart';
import '../reserve_table/reserve_dashboard_screen.dart';
import '../takeaway/takeaway_dashboard_screen.dart';

/// Unified main dashboard shell housing the 5 core modes:
/// 1. Order Food
/// 2. Take Away
/// 3. Reserve Table
/// 4. Catering
/// 5. Food Planner
///
/// Features:
/// - Persistent top delivery header ([MainTopHeader])
/// - Persistent organic curved flared tab bar ([TopModeSelector])
/// - Silky smooth 550ms easeInOutCubic transitions matching the Home page
/// - Horizontal swipeable [PageView] with scroll position preservation
class MainDashboardShell extends StatefulWidget {
  const MainDashboardShell({
    super.key,
    this.initialTab = 'order_food',
  });

  final String initialTab;

  @override
  State<MainDashboardShell> createState() => _MainDashboardShellState();
}

class _MainDashboardShellState extends State<MainDashboardShell>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _pageController;
  bool _isManualSwitch = false;

  int _indexForTab(String tabId) {
    final idx = kAppModes.indexWhere((m) => m.id == tabId);
    return idx >= 0 ? idx : 0;
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = _indexForTab(widget.initialTab);
    _tabController = TabController(
      length: kAppModes.length,
      initialIndex: initialIndex,
      vsync: this,
    );
    _pageController = PageController(initialPage: initialIndex);
    _pageController.addListener(_onPageControllerScroll);
    AppModeController.instance.setMode(kAppModes[initialIndex].mode);
    _tabController.addListener(_onTabControllerChanged);
  }

  void _onPageControllerScroll() {
    if (mounted) setState(() {});
  }

  void _onTabControllerChanged() {
    if (_tabController.indexIsChanging && !_isManualSwitch) {
      _goToPage(_tabController.index);
    }
    if (mounted) setState(() {});
  }

  void _goToPage(int index) {
    if (!_pageController.hasClients) return;
    _isManualSwitch = true;
    _pageController
        .animateToPage(
      index,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
    )
        .then((_) {
      if (mounted) {
        _isManualSwitch = false;
      }
    });
  }

  ModeTheme _getActiveTheme() {
    double pos = _tabController.index.toDouble();
    if (_pageController.hasClients && _pageController.page != null) {
      pos = _pageController.page!;
    }
    final lower = pos.floor().clamp(0, kAppModes.length - 1);
    final upper = pos.ceil().clamp(0, kAppModes.length - 1);
    final t = (pos - lower).clamp(0.0, 1.0);
    return ModeTheme.lerp(
      kAppModes[lower].theme,
      kAppModes[upper].theme,
      t,
    );
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageControllerScroll);
    _tabController.removeListener(_onTabControllerChanged);
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = _getActiveTheme();
    final activeColor = activeTheme.primaryAccent;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Cascading Vertical Ambient Color Wash ────────────────────────
          // Starts from behind the top status bar / header / mode tabs, flows down
          // through the upper half of the screen (~680px), and gracefully fades out.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 680,
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: activeTheme.pageWashColors,
                    stops: activeTheme.pageWashStops,
                  ),
                ),
              ),
            ),
          ),


          // ── Shell Content ───────────────────────────────────────────
          Column(
            children: [
              // ── Unified Top Masthead (Header + 5-Mode Navigation) ─────────────────
              // Top bar and unselected mode buttons share the exact same surface color.
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                color: activeTheme.upperBackgroundColor,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MainTopHeader(accentColor: activeColor),
                      TopModeSelector(
                        controller: _tabController,
                        theme: activeTheme,
                        backgroundColor: Colors.transparent,
                        canvasColor: Colors.transparent,
                        onModeChanged: (mode) {
                          final idx = kAppModes.indexWhere((m) => m.mode == mode);
                          if (idx >= 0 && idx != (_pageController.page?.round() ?? -1)) {
                            _goToPage(idx);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ── Smooth animated PageView of the 5 dashboards ────────────
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    if (_tabController.index != index) {
                      _isManualSwitch = true;
                      _tabController.animateTo(
                        index,
                        duration: const Duration(milliseconds: 550),
                        curve: Curves.easeInOutCubic,
                      );
                      AppModeController.instance.setMode(kAppModes[index].mode);
                      Future.delayed(const Duration(milliseconds: 580), () {
                        if (mounted) {
                          _isManualSwitch = false;
                        }
                      });
                    }
                  },
                  children: const [
                    FoodHomeScreen(isEmbedded: true),
                    TakeawayDashboardScreen(isEmbedded: true),
                    ReserveDashboardScreen(isEmbedded: true),
                    CateringDashboardScreen(isEmbedded: true),
                    FoodPlannerShellScreen(isEmbedded: true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
