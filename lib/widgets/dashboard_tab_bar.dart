import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class _SectionTab {
  const _SectionTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
  });
  final String id;
  final String label;
  final IconData icon;
  final String route;
}

const _kSectionTabs = [
  _SectionTab(
    id: 'order_food',
    label: 'Order Food',
    icon: Icons.restaurant_menu_rounded,
    route: AppRoutes.foodHome,
  ),
  _SectionTab(
    id: 'take_away',
    label: 'Take Away',
    icon: Icons.shopping_bag_rounded,
    route: AppRoutes.takeawayDashboard,
  ),
  _SectionTab(
    id: 'reserve_table',
    label: 'Reserve Table',
    icon: Icons.table_restaurant_rounded,
    route: AppRoutes.reserveDashboard,
  ),
  _SectionTab(
    id: 'food_planner',
    label: 'Food Planner',
    icon: Icons.calendar_month_rounded,
    route: AppRoutes.foodPlanner,
  ),
  _SectionTab(
    id: 'catering',
    label: 'Catering',
    icon: Icons.room_service_rounded,
    route: AppRoutes.cateringDashboard,
  ),
];

/// A persistent Swiggy-style horizontal category switcher for the 5 main dashboards:
/// Order Food, Take Away, Reserve Table, Food Planner, and Catering.
///
/// Highlights the current [activeId] section. Tapping any other tab directly switches
/// to that section's main dashboard with [Navigator.pushReplacementNamed].
class DashboardTabBar extends StatelessWidget {
  const DashboardTabBar({
    super.key,
    required this.activeId,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  /// One of: 'order_food', 'take_away', 'reserve_table', 'food_planner', 'catering'
  final String activeId;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _kSectionTabs.map((tab) {
            final isActive = tab.id == activeId;
            return _TabChip(
              tab: tab,
              isActive: isActive,
              onTap: isActive
                  ? null
                  : () => Navigator.of(context).pushReplacementNamed(tab.route),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  final _SectionTab tab;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: isActive ? AppColors.accentRed : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isActive ? AppColors.accentRed : AppColors.border,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tab.icon,
                  size: 16,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
