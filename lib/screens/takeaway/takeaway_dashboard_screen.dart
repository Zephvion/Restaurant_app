import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/takeaway_order.dart';
import '../../routes/app_routes.dart';
import '../../state/takeaway_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/dashboard_tab_bar.dart';
import '../../widgets/network_image_with_fallback.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          const Text(
            'Hello, Arti!',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      children: [
        const Text(
          'Hello, Arti!',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
              child: _TakeawayOrderCard(order: order),
            )),
        const SizedBox(height: 16),
        Center(child: _AddButton(onTap: onAdd)),
      ],
    );
  }
}

// ── Takeaway Order Card ───────────────────────────────────────────────────────

class _TakeawayOrderCard extends StatelessWidget {
  const _TakeawayOrderCard({required this.order});
  final TakeawayOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status row with dot ──────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.accentRed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                order.statusLabel,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // ── Progress Stepper ────────────────────────────────────────────
          _ProgressStepper(status: order.status),
          const SizedBox(height: 24),
          // ── Order ID & Call Action ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ORDER ID : ${order.id}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling ${order.restaurant.name}...'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      'Call the restaurant',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.phone, color: AppColors.accentRed, size: 16),
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

// ── Progress Stepper ──────────────────────────────────────────────────────────

class _ProgressStepper extends StatelessWidget {
  const _ProgressStepper({required this.status});
  final TakeawayStatus status;

  @override
  Widget build(BuildContext context) {
    final isPreparingDone = status == TakeawayStatus.preparing ||
        status == TakeawayStatus.packing ||
        status == TakeawayStatus.readyForTakeaway ||
        status == TakeawayStatus.taken;

    final isPackingDone = status == TakeawayStatus.packing ||
        status == TakeawayStatus.readyForTakeaway ||
        status == TakeawayStatus.taken;

    final isTakenDone = status == TakeawayStatus.taken;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _stepItem(label: 'Preparing', active: isPreparingDone),
        _divider(active: isPackingDone),
        _stepItem(label: 'Packing', active: isPackingDone),
        _divider(active: isTakenDone),
        _stepItem(label: 'Taken', active: isTakenDone),
      ],
    );
  }

  Widget _stepItem({required String label, required bool active}) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? const Color(0xFF4CAF50)
                : AppColors.surfaceLight,
          ),
          child: Icon(
            Icons.check,
            size: 14,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _divider({required bool active}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: List.generate(
            6,
            (index) => Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                color: active
                    ? const Color(0xFF4CAF50)
                    : AppColors.surfaceLight,
              ),
            ),
          ),
        ),
      ),
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
