import 'package:flutter/material.dart';

import '../routes/app_routes.dart';

// ─── Tab definitions (matches home_screen.dart tabs) ─────────────────────────

class _Tab {
  const _Tab({
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

const _kTabs = [
  _Tab(
    id: 'order_food',
    label: 'Order Food',
    icon: Icons.restaurant_menu_rounded,
    route: AppRoutes.orderFood,
  ),
  _Tab(
    id: 'take_away',
    label: 'Take Away',
    icon: Icons.shopping_bag_rounded,
    route: AppRoutes.takeaway,
  ),
  _Tab(
    id: 'reserve_table',
    label: 'Reserve Table',
    icon: Icons.table_restaurant_rounded,
    route: AppRoutes.reserveTable,
  ),
  _Tab(
    id: 'food_planner',
    label: 'Food Planner',
    icon: Icons.calendar_month_rounded,
    route: AppRoutes.foodPlannerIntro,
  ),
  _Tab(
    id: 'catering',
    label: 'Catering',
    icon: Icons.room_service_rounded,
    route: AppRoutes.catering,
  ),
];

/// A Swiggy-style horizontal tab bar placed at the top of each service intro
/// screen. The [activeId] chip is highlighted; tapping any other chip
/// replaces the current route with that service's intro screen.
///
/// Usage — pass the current service id, e.g.:
/// ```dart
/// ServiceTabBar(activeId: 'order_food')
/// ```
class ServiceTabBar extends StatelessWidget {
  const ServiceTabBar({super.key, required this.activeId});

  /// One of: 'order_food', 'take_away', 'reserve_table', 'food_planner', 'catering'
  final String activeId;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Semi-transparent dark backdrop so tabs are readable over any hero photo
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC000000), Colors.transparent],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
          child: Row(
            children: _kTabs.map((tab) {
              final isActive = tab.id == activeId;
              return _Chip(
                tab: tab,
                isActive: isActive,
                onTap: isActive
                    ? null // already here — no-op
                    : () => Navigator.of(context)
                        .pushReplacementNamed(tab.route),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Individual chip ──────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  final _Tab tab;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.45),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab.icon,
              size: 15,
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.65),
            ),
            const SizedBox(width: 5),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.65),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
