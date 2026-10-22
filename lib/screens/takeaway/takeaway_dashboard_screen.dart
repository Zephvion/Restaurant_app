import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/restaurant.dart';
import '../../routes/app_routes.dart';
import '../../services/location_service.dart';
import '../../state/takeaway_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/dashboard_tab_bar.dart';
import '../../widgets/main_top_header.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/themed_page_background.dart';
import 'takeaway_order_card.dart';

/// Dashboard screen for Take Away:
/// experience showing the nearest store with live GPS distance,
/// one-tap store switching, quick ordering CTA, and order tracking.
class TakeawayDashboardScreen extends StatefulWidget {
  const TakeawayDashboardScreen({super.key, this.isEmbedded = false});

  final bool isEmbedded;

  @override
  State<TakeawayDashboardScreen> createState() =>
      _TakeawayDashboardScreenState();
}

class _TakeawayDashboardScreenState extends State<TakeawayDashboardScreen>
    with AutomaticKeepAliveClientMixin {
  final List<String> _cities = const [
    'All Branches',
    'Bengaluru',
    'Calicut',
    'Kochi',
    'Trivandrum',
  ];
  String _selectedCity = 'All Branches';

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final content = AnimatedBuilder(
      animation: TakeawayController.instance,
      builder: (context, _) {
        final ctrl = TakeawayController.instance;
        final currentRest = ctrl.activeRestaurant;
        final distKm = ctrl.distanceToSelectedKm;
        final hasSelection = ctrl.hasExplicitSelection;

        return Column(
          children: [
            if (!widget.isEmbedded) ...[
              const MainTopHeader(accentColor: Color(0xFFFF9500)),
              const SizedBox(height: 10),
              const DashboardTabBar(activeId: 'take_away'),
            ],
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                    20, 16, 20, 32 + MediaQuery.paddingOf(context).bottom),
                children: [
                    // Domino's Style Store Card
                    _NearbyStoreCard(
                      restaurant: currentRest,
                      distanceKm: distKm,
                      hasSelection: hasSelection,
                      onChangeStore: () => _goSelectRestaurant(context),
                      onDeselectStore: () => ctrl.deselectRestaurant(),
                      onOrderNow: () {
                        ctrl.selectRestaurant(currentRest);
                        Navigator.of(context).pushNamed(AppRoutes.takeawayMenu);
                      },
                    ),
                    // Active Orders
                    if (ctrl.orders.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Your Takeaway Orders',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${ctrl.orders.length} active',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...ctrl.orders.map((order) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TakeawayOrderCard(order: order),
                          )),
                    ],

                    // Nearby Paragon Outlets
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Choose Branch for Takeaway',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _goSelectRestaurant(context),
                          icon: const Icon(Icons.tune_rounded, size: 14, color: AppColors.copper),
                          label: const Text(
                            'All Outlets',
                            style: TextStyle(
                              color: AppColors.copper,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // City Filter Tabs (Bengaluru, Calicut, Kochi, Trivandrum, All)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _cities.map((city) {
                          final isSel = city == _selectedCity;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedCity = city),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.copper : AppColors.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSel ? AppColors.copper : AppColors.border,
                                    width: isSel ? 1.4 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSel) ...[
                                      const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      city,
                                      style: TextStyle(
                                        color: isSel ? Colors.white : AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Outlets list with Nearest first & Select/Deselect buttons
                    ...(() {
                      final outlets = MockData.restaurants.where((r) {
                        if (_selectedCity == 'All Branches') return true;
                        return r.city.toLowerCase() == _selectedCity.toLowerCase();
                      }).toList();

                      // Ensure nearest is always first
                      outlets.sort((a, b) {
                        final distA = LocationService.instance.getDistanceToRestaurant(a);
                        final distB = LocationService.instance.getDistanceToRestaurant(b);
                        return distA.compareTo(distB);
                      });

                      final displayList = outlets.take(6).toList();

                      return displayList.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final outlet = entry.value;
                        final isSelected = ctrl.isSelected(outlet);
                        final dist = LocationService.instance.getDistanceToRestaurant(outlet);
                        final isNearest = (idx == 0 && dist < 50);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _NearbyOutletTile(
                            outlet: outlet,
                            distanceKm: dist,
                            isNearest: isNearest,
                            isSelected: isSelected,
                            onToggle: () {
                              ctrl.toggleRestaurant(outlet);
                            },
                          ),
                        );
                      });
                    })(),
                  ],
                ),
              ),
            ],
          );
        },
      );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: widget.isEmbedded
          ? content
          : ThemedPageBackground(
              accentColor: const Color(0xFFFF9500),
              child: SafeArea(
                bottom: false,
                child: content,
              ),
            ),
    );
  }

  void _goSelectRestaurant(BuildContext context) =>
      Navigator.of(context).pushNamed(AppRoutes.takeawaySelectRestaurant);
}


// ── Domino's Style Store Card ────────────────────────────────────────────────

class _NearbyStoreCard extends StatelessWidget {
  const _NearbyStoreCard({
    required this.restaurant,
    required this.distanceKm,
    required this.hasSelection,
    required this.onChangeStore,
    required this.onDeselectStore,
    required this.onOrderNow,
  });

  final Restaurant restaurant;
  final double distanceKm;
  final bool hasSelection;
  final VoidCallback onChangeStore;
  final VoidCallback onDeselectStore;
  final VoidCallback onOrderNow;

  @override
  Widget build(BuildContext context) {
    final distText = distanceKm < 100
        ? '${distanceKm.toStringAsFixed(1)} km away'
        : 'Nearby Outlet';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E23),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasSelection ? const Color(0xFF10B981) : const Color(0xFF303036),
          width: hasSelection ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: hasSelection
                ? const Color(0xFF10B981).withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Badges Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: (hasSelection ? const Color(0xFF10B981) : const Color(0xFFFF9500))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (hasSelection ? const Color(0xFF10B981) : const Color(0xFFFF9500))
                          .withValues(alpha: 0.5),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasSelection ? Icons.check_circle_rounded : Icons.storefront_rounded,
                        color: hasSelection ? const Color(0xFF10B981) : const Color(0xFFFF9500),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          hasSelection ? 'PICKUP OUTLET' : 'NEAREST OUTLET',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: hasSelection ? const Color(0xFF10B981) : const Color(0xFFFF9500),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.near_me_rounded,
                        color: Color(0xFF81C784), size: 12),
                    const SizedBox(width: 3),
                    Text(
                      distText,
                      style: const TextStyle(
                        color: Color(0xFF81C784),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Restaurant Name & City
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${restaurant.address}, ${restaurant.city}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasSelection) ...[
                    OutlinedButton(
                      onPressed: onDeselectStore,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Deselect'),
                    ),
                    const SizedBox(width: 6),
                  ],
                  OutlinedButton.icon(
                    onPressed: onChangeStore,
                    icon: const Icon(Icons.swap_horiz_rounded, size: 15),
                    label: const Text('Change'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.copper,
                      side: BorderSide(color: AppColors.copper.withValues(alpha: 0.6)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Timing & Pickup ETA Pills
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_filled_rounded,
                    color: Color(0xFF4CAF50), size: 14),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Open • Closes ${restaurant.closeTime}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    width: 1,
                    height: 14,
                    color: AppColors.border,
                  ),
                ),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.electric_bolt_rounded,
                        color: AppColors.copper, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Ready in 15m',
                      style: TextStyle(
                        color: AppColors.copper,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Order Now CTA Button
          PrimaryButton(
            label: hasSelection
                ? 'Order Takeaway from this Outlet'
                : 'Order from Nearest Restaurant',
            icon: hasSelection ? Icons.shopping_bag_rounded : Icons.storefront_rounded,
            uppercase: false,
            backgroundColor: const Color(0xFFFF9500),
            foregroundColor: Colors.black,
            onPressed: onOrderNow,
          ),
        ],
      ),
    );
  }
}

// ── Nearby Outlet List Tile ──────────────────────────────────────────────────

class _NearbyOutletTile extends StatelessWidget {
  const _NearbyOutletTile({
    required this.outlet,
    required this.distanceKm,
    required this.isNearest,
    required this.isSelected,
    required this.onToggle,
  });

  final Restaurant outlet;
  final double distanceKm;
  final bool isNearest;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final distText = distanceKm < 100
        ? '${distanceKm.toStringAsFixed(1)} km away'
        : 'Nearby Outlet';

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.surface.withValues(alpha: 0.95)
              : const Color(0xFF1E1E23),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981)
                : const Color(0xFF303036),
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Icon + Name / Address + Rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF10B981).withValues(alpha: 0.18)
                        : const Color(0xFF26262C),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: isSelected ? const Color(0xFF10B981) : const Color(0xFF9A9AA5),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outlet.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${outlet.address}, ${outlet.city}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        outlet.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.star, color: Colors.white, size: 10),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: Telemetry Badges + Select / Deselect Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (isNearest)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9500).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFFFF9500).withValues(alpha: 0.6),
                              width: 0.6,
                            ),
                          ),
                          child: const Text(
                            'NEAREST',
                            style: TextStyle(
                              color: Color(0xFFFF9500),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.near_me_rounded,
                              color: Color(0xFF81C784), size: 12),
                          const SizedBox(width: 3),
                          Text(
                            distText,
                            style: const TextStyle(
                              color: Color(0xFF81C784),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '• Closes ${outlet.closeTime}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Select / Deselect Button
                if (isSelected)
                  OutlinedButton.icon(
                    onPressed: onToggle,
                    icon: const Icon(Icons.check_circle_rounded,
                        size: 14, color: Color(0xFF10B981)),
                    label: const Text('Deselect'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      backgroundColor:
                          const Color(0xFF10B981).withValues(alpha: 0.12),
                      side: const BorderSide(
                        color: Color(0xFF10B981),
                        width: 1.2,
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: onToggle,
                    icon: const Icon(Icons.radio_button_unchecked,
                        size: 13, color: Colors.white),
                    label: const Text('Select'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.copper,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

