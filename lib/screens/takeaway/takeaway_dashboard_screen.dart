import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/restaurant.dart';
import '../../routes/app_routes.dart';
import '../../state/takeaway_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/dashboard_tab_bar.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/primary_button.dart';
import 'takeaway_order_card.dart';

/// Dashboard screen for Take Away:
/// Domino's-style experience showing the nearest store with live GPS distance,
/// one-tap store switching, quick ordering CTA, and order tracking.
class TakeawayDashboardScreen extends StatelessWidget {
  const TakeawayDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: TakeawayController.instance,
        builder: (context, _) {
          final ctrl = TakeawayController.instance;
          final currentRest = ctrl.activeRestaurant;
          final distKm = ctrl.distanceToSelectedKm;

          return Column(
            children: [
              // ── Top Hero Image ──────────────────────────────────────────
              const _HeroHeader(),
              // ── Section Switcher ─────────────────────────────────────────
              const DashboardTabBar(activeId: 'take_away'),
              // ── Main Content ────────────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    // Domino's Style Store Card
                    _NearbyStoreCard(
                      restaurant: currentRest,
                      distanceKm: distKm,
                      onChangeStore: () => _goSelectRestaurant(context),
                      onOrderNow: () {
                        ctrl.selectRestaurant(currentRest);
                        Navigator.of(context).pushNamed(AppRoutes.takeawayMenu);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Active Orders or Takeaway Highlights
                    if (ctrl.orders.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Takeaway Orders',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
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
                    ] else ...[
                      _TakeawayHighlights(
                        onExploreMenu: () {
                          ctrl.selectRestaurant(currentRest);
                          Navigator.of(context).pushNamed(AppRoutes.takeawayMenu);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _goSelectRestaurant(BuildContext context) =>
      Navigator.of(context).pushNamed(AppRoutes.takeawaySelectRestaurant);
}

// ── Hero header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          const Positioned.fill(
            child: NetworkImageWithFallback(
              url: MockData.takeawayCounter,
              fit: BoxFit.cover,
              fallbackIcon: Icons.takeout_dining,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                  AppColors.background.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.home);
                      }
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: Colors.white),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.notifications),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Domino's Style Store Card ────────────────────────────────────────────────

class _NearbyStoreCard extends StatelessWidget {
  const _NearbyStoreCard({
    required this.restaurant,
    required this.distanceKm,
    required this.onChangeStore,
    required this.onOrderNow,
  });

  final Restaurant restaurant;
  final double distanceKm;
  final VoidCallback onChangeStore;
  final VoidCallback onOrderNow;

  @override
  Widget build(BuildContext context) {
    final distText = distanceKm < 100
        ? '${distanceKm.toStringAsFixed(1)} km away'
        : 'Nearby Outlet';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.copper.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.copper.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.copper.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storefront_rounded,
                        color: AppColors.copper, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'PICKUP STORE',
                      style: TextStyle(
                        color: AppColors.copper,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
                        color: Color(0xFF81C784), size: 13),
                    const SizedBox(width: 4),
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
              OutlinedButton.icon(
                onPressed: onChangeStore,
                icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                label: const Text('Change'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.copper,
                  side: BorderSide(color: AppColors.copper.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Timing & Pickup ETA Pills
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_filled_rounded,
                    color: Color(0xFF4CAF50), size: 16),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Open • Closes ${restaurant.closeTime}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 16,
                  color: AppColors.border,
                ),
                const SizedBox(width: 12),
                const Icon(Icons.electric_bolt_rounded,
                    color: AppColors.copper, size: 16),
                const SizedBox(width: 5),
                const Text(
                  'Ready in 15 mins',
                  style: TextStyle(
                    color: AppColors.copper,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Order Now CTA Button
          PrimaryButton(
            label: 'Order Takeaway from this Outlet',
            onPressed: onOrderNow,
          ),
        ],
      ),
    );
  }
}

// ── Takeaway Highlights ──────────────────────────────────────────────────────

class _TakeawayHighlights extends StatelessWidget {
  const _TakeawayHighlights({required this.onExploreMenu});
  final VoidCallback onExploreMenu;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why Order Paragon Takeaway?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        _buildFeatureTile(
          icon: Icons.flash_on_rounded,
          iconColor: Colors.amber,
          title: 'Express Priority Counter',
          subtitle: 'Skip the dining queue — your order is packed and waiting hot.',
        ),
        const SizedBox(height: 10),
        _buildFeatureTile(
          icon: Icons.money_off_csred_rounded,
          iconColor: const Color(0xFF4CAF50),
          title: 'Zero Delivery Fee',
          subtitle: 'Enjoy authentic Paragon delicacies at direct restaurant menu prices.',
        ),
        const SizedBox(height: 10),
        _buildFeatureTile(
          icon: Icons.soup_kitchen_rounded,
          iconColor: AppColors.copper,
          title: 'Piping Hot Handover',
          subtitle: 'Prepared fresh just minutes before your designated pickup time.',
        ),
      ],
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.7),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
