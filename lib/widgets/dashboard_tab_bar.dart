import 'package:flutter/material.dart';

import '../state/app_mode_controller.dart';
import 'top_mode_selector.dart';

/// A persistent top mode selector for the 5 main dashboards:
/// Order Food, Take Away, Reserve Table, Catering, and Food Planner.
///
/// Highlights the current [activeId] section with an organic arched flared tab.
/// Tapping any other tab directly switches to that section's main dashboard with [Navigator.pushReplacementNamed].
class DashboardTabBar extends StatelessWidget {
  const DashboardTabBar({
    super.key,
    required this.activeId,
    this.padding = EdgeInsets.zero,
    this.onModeChanged,
  });

  /// One of: 'order_food', 'take_away', 'reserve_table', 'catering', 'food_planner'
  final String activeId;

  final EdgeInsetsGeometry padding;
  final ValueChanged<AppMode>? onModeChanged;

  @override
  Widget build(BuildContext context) {
    final accentColor = getModeAccentColor(activeId);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TopModeSelector(
          activeId: activeId,
          padding: padding,
          onModeChanged: (mode) {
            if (onModeChanged != null) {
              onModeChanged!(mode);
              return;
            }
            final target = kAppModes.firstWhere((m) => m.mode == mode);
            if (target.id != activeId) {
              Navigator.of(context).pushReplacementNamed(target.route);
            }
          },
        ),
        const SizedBox(height: 3),
        // Luminous subtle horizontal color accent glow line beneath active mode
        Container(
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                accentColor.withValues(alpha: 0.45),
                accentColor.withValues(alpha: 0.95),
                accentColor.withValues(alpha: 0.45),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.35),
                blurRadius: 6,
                spreadRadius: 0.5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
