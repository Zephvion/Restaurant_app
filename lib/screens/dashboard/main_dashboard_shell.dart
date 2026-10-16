import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../state/app_mode_controller.dart';
import '../../theme/app_colors.dart';
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
    AppModeController.instance.setMode(kAppModes[initialIndex].mode);
    _tabController.addListener(_onTabControllerChanged);
  }

  void _onTabControllerChanged() {
    if (_tabController.indexIsChanging && !_isManualSwitch) {
      _goToPage(_tabController.index);
    }
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

  @override
  void dispose() {
    _tabController.removeListener(_onTabControllerChanged);
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Persistent Top Header ─────────────────────────────────────────
            const MainTopHeader(),
            const SizedBox(height: 10),
            // ── Persistent Organic Flared Tab Bar ────────────────────────────
            TopModeSelector(
              controller: _tabController,
              backgroundColor: AppColors.background,
              canvasColor: AppColors.background,
              onModeChanged: (mode) {
                final idx = kAppModes.indexWhere((m) => m.mode == mode);
                if (idx >= 0 && idx != (_pageController.page?.round() ?? -1)) {
                  _goToPage(idx);
                }
              },
            ),
            // ── Smooth animated PageView of the 5 dashboards ────────────────
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
      ),
    );
  }
}
