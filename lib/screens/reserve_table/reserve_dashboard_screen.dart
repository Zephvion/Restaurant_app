import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/reservation.dart';
import '../../routes/app_routes.dart';
import '../../state/reservation_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/dashboard_tab_bar.dart';
import '../../widgets/network_image_with_fallback.dart';

/// Shows the user's existing reservations (empty state or a list of cards)
/// with a ＋ button to start a new reservation.
class ReserveDashboardScreen extends StatelessWidget {
  const ReserveDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: ReservationController.instance,
        builder: (context, _) {
          final ctrl = ReservationController.instance;
          return Column(
            children: [
              // ── top hero image ──────────────────────────────────────────
              _HeroHeader(),
              // ── Swiggy-style Section Switcher ───────────────────────────
              const DashboardTabBar(activeId: 'reserve_table'),
              // ── content ────────────────────────────────────────────────
              Expanded(
                child: ctrl.isEmpty
                    ? _EmptyState(onAdd: () => _goAdd(context))
                    : _ReservationList(
                        reservations: ctrl.reservations,
                        onAdd: () => _goAdd(context),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _goAdd(BuildContext context) =>
      Navigator.of(context).pushNamed(AppRoutes.selectRestaurant);
}

// ── Hero header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          const Positioned.fill(
            child: NetworkImageWithFallback(
              url: MockData.reserveTableHero,
              fit: BoxFit.cover,
              fallbackIcon: Icons.restaurant,
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
            'No reservations yet',
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

// ── Reservation list ──────────────────────────────────────────────────────────

class _ReservationList extends StatelessWidget {
  const _ReservationList({required this.reservations, required this.onAdd});
  final List<Reservation> reservations;
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
          'Your reservations',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),
        ...reservations.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ReservationCard(reservation: r),
            )),
        const SizedBox(height: 16),
        Center(child: _AddButton(onTap: onAdd)),
      ],
    );
  }
}

// ── Reservation card ──────────────────────────────────────────────────────────

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.reservation});
  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table icon (coloured circles pattern)
          _TableIcon(tableNumber: reservation.tableNumber),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${reservation.restaurant.name}, '
                        '${reservation.restaurant.city}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.edit_outlined,
                        size: 16, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 10),
                _InfoRow(label: 'Date', value: reservation.formattedDate),
                _InfoRow(label: 'Time', value: reservation.timeSlot),
                _InfoRow(label: 'Seats', value: '${reservation.seats}'),
                _InfoRow(label: 'Table', value: '${reservation.tableNumber}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative table icon with overlapping coloured circles (matches Figma card).
class _TableIcon extends StatelessWidget {
  const _TableIcon({required this.tableNumber});
  final int tableNumber;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Four seat circles at corners
          _circle(top: 0, left: 0, color: AppColors.accentRed.withValues(alpha: 0.7)),
          _circle(top: 0, right: 0, color: Colors.grey.shade700),
          _circle(bottom: 0, left: 0, color: AppColors.accentRed.withValues(alpha: 0.7)),
          _circle(bottom: 0, right: 0, color: Colors.grey.shade700),
          // Table surface
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$tableNumber',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle({
    double? top, double? bottom, double? left, double? right,
    required Color color,
  }) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
