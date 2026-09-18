import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/takeaway_order.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../state/takeaway_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/dashboard_tab_bar.dart';
import '../../widgets/network_image_with_fallback.dart';
import 'takeaway_order_card.dart';

/// Dashboard screen for Take Away:
/// Shows empty state ("No orders yet") or active order cards with progress stepper.
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
          return Column(
            children: [
              // ── Top Hero Image ──────────────────────────────────────────
              const _HeroHeader(),
              // ── Swiggy-style Section Switcher ───────────────────────────
              const DashboardTabBar(activeId: 'take_away'),
              // ── Main Content ────────────────────────────────────────────
              Expanded(
                child: ctrl.hasNoOrders
                    ? _EmptyState(onAdd: () => _goSelectRestaurant(context))
                    : _OrdersList(
                        orders: ctrl.orders,
                        onAdd: () => _goSelectRestaurant(context),
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
      height: 260,
      child: Stack(
        children: [
          const Positioned.fill(
            child: NetworkImageWithFallback(
              url: MockData.takeawayCounter,
              fit: BoxFit.cover,
              fallbackIcon: Icons.takeout_dining,
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
                    icon: const Icon(Icons.location_on_outlined,
                        color: Colors.white),
                    onPressed: () {},
                  ),
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final name = (user?.displayName != null && user!.displayName.isNotEmpty)
        ? user.displayName.split(' ').first
        : 'Arti';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          Text(
            'Hello, $name!',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 6),
          const Text(
            'No orders yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Center(child: _AddButton(onTap: onAdd)),
          const Spacer(),
        ],
      ),
    );
  }
}

// ── Orders list ───────────────────────────────────────────────────────────────

class _OrdersList extends StatelessWidget {
  const _OrdersList({required this.orders, required this.onAdd});
  final List<TakeawayOrder> orders;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final name = (user?.displayName != null && user!.displayName.isNotEmpty)
        ? user.displayName.split(' ').first
        : 'Arti';

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      children: [
        Text(
          'Hello, $name!',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 6),
        const Text(
          'Takeaway orders',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),
        ...orders.map((order) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TakeawayOrderCard(order: order),
            )),
        const SizedBox(height: 16),
        Center(child: _AddButton(onTap: onAdd)),
      ],
    );
  }
}

// ── Add button ────────────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: AppColors.textPrimary, size: 28),
      ),
    );
  }
}
