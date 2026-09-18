import 'package:flutter/material.dart';

import 'top_mode_selector.dart';

/// A persistent Swiggy-style top mode selector for the 5 main dashboards:
/// Order Food, Take Away, Reserve Table, Catering, and Food Planner.
///
/// Highlights the current [activeId] section with an organic arched flared tab.
/// Tapping any other tab directly switches to that section's main dashboard with [Navigator.pushReplacementNamed].
class DashboardTabBar extends StatelessWidget {
  const DashboardTabBar({
    super.key,
    required this.activeId,
    this.padding = EdgeInsets.zero,
  });

  /// One of: 'order_food', 'take_away', 'reserve_table', 'catering', 'food_planner'
  final String activeId;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return TopModeSelector(
      activeId: activeId,
      padding: padding,
      onModeChanged: (mode) {
        final target = kAppModes.firstWhere((m) => m.mode == mode);
        if (target.id != activeId) {
          Navigator.of(context).pushReplacementNamed(target.route);
        }
      },
    );
  }
}

