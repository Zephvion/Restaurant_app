import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_data.dart';
import '../../models/catering_order.dart';
import '../../routes/app_routes.dart';
import '../../state/catering_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/dashboard_tab_bar.dart';
import '../../widgets/network_image_with_fallback.dart';

/// Dashboard screen for Catering.
class CateringDashboardScreen extends ConsumerWidget {
  const CateringDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(cateringOrdersAsyncProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _HeroHeader(),
          const DashboardTabBar(activeId: 'catering'),
          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Unable to load catering orders.',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(cateringOrdersAsyncProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (orders) => orders.isEmpty
                  ? _EmptyState(onAdd: () => _goNotice(context))
                  : _OrdersList(
                      orders: orders,
                      onAdd: () => _goNotice(context),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _goNotice(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.cateringNotice);
  }
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
              url: MockData.cateringTable,
              fit: BoxFit.cover,
              fallbackIcon: Icons.room_service,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
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
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AppRoutes.notifications),
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

// ── Empty state ──────────────────────────────────────────────────────────────

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
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No catering orders yet',
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

// ── Orders list ──────────────────────────────────────────────────────────────

class _OrdersList extends StatelessWidget {
  const _OrdersList({
    required this.orders,
    required this.onAdd,
  });

  final List<CateringOrder> orders;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      children: [
        const Text(
          'Hello, Arti!',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your catering orders',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),
        ...orders.map(
          (order) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _CateringOrderCard(order: order),
          ),
        ),
        const SizedBox(height: 16),
        Center(child: _AddButton(onTap: onAdd)),
      ],
    );
  }
}

// ── Catering order card ──────────────────────────────────────────────────────

class _CateringOrderCard extends StatelessWidget {
  const _CateringOrderCard({required this.order});

  final CateringOrder order;

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
              Expanded(
                child: Text(
                  order.statusLabel,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _ProgressStepper(status: order.status),
          const SizedBox(height: 24),
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
                    const SnackBar(
                      content: Text('Calling Paragon Catering...'),
                      duration: Duration(seconds: 2),
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
                    Icon(
                      Icons.phone,
                      color: AppColors.accentRed,
                      size: 16,
                    ),
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

// ── Progress stepper ─────────────────────────────────────────────────────────

class _ProgressStepper extends StatelessWidget {
  const _ProgressStepper({required this.status});

  final CateringStatus status;

  @override
  Widget build(BuildContext context) {
    final isNotifiedDone = status == CateringStatus.notifiedParagon ||
        status == CateringStatus.call ||
        status == CateringStatus.bookingConfirmed;

    final isCallDone = status == CateringStatus.call ||
        status == CateringStatus.bookingConfirmed;

    final isBookingDone = status == CateringStatus.bookingConfirmed;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _stepItem(label: 'Notified Paragon', active: isNotifiedDone),
        _divider(active: isCallDone),
        _stepItem(label: 'Call', active: isCallDone),
        _divider(active: isBookingDone),
        _stepItem(label: 'Booking Confirmed', active: isBookingDone),
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
            color: active ? const Color(0xFF4CAF50) : AppColors.surfaceLight,
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
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 10,
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
                color:
                    active ? const Color(0xFF4CAF50) : AppColors.surfaceLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Add button ───────────────────────────────────────────────────────────────

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
        child: const Icon(
          Icons.add,
          color: AppColors.textPrimary,
          size: 28,
        ),
      ),
    );
  }
}