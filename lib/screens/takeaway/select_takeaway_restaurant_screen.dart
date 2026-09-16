import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/restaurant.dart';
import '../../routes/app_routes.dart';
import '../../state/takeaway_controller.dart';
import '../../theme/app_colors.dart';

/// Screen allowing the user to select city and restaurant branch for takeaway.
class SelectTakeawayRestaurantScreen extends StatefulWidget {
  const SelectTakeawayRestaurantScreen({super.key});

  @override
  State<SelectTakeawayRestaurantScreen> createState() =>
      _SelectTakeawayRestaurantScreenState();
}

class _SelectTakeawayRestaurantScreenState
    extends State<SelectTakeawayRestaurantScreen> {
  final List<String> _cities = ['Calicut', 'Kochi', 'Trivandrum'];
  String _selectedCity = 'Calicut';
  Restaurant? _selectedRestaurant;

  List<Restaurant> get _filtered => MockData.restaurants
      .where((r) => r.city == _selectedCity)
      .toList();

  void _next() {
    if (_selectedRestaurant == null) return;
    TakeawayController.instance.selectRestaurant(_selectedRestaurant!);
    Navigator.of(context).pushNamed(AppRoutes.takeawayMenu);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              children: [
                // ── Header ──────────────────────────────────────────────
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: AppColors.textPrimary, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.takeawayDashboard);
                        }
                      },
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.location_on,
                        color: AppColors.textPrimary, size: 22),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Select the restaurant',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded,
                          color: AppColors.textPrimary),
                      onPressed: () => Navigator.of(context)
                          .pushNamed(AppRoutes.notifications),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // ── City chips ───────────────────────────────────────────
                const Text(
                  'Select your city',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  children: _cities.map((city) {
                    final selected = city == _selectedCity;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedCity = city;
                        _selectedRestaurant = null;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.accentRed
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          city,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                // ── Restaurant list ─────────────────────────────────────
                const Text(
                  'Select the restaurant',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                ..._filtered.map((r) => _RestaurantTile(
                      restaurant: r,
                      selected: _selectedRestaurant?.id == r.id,
                      onTap: () =>
                          setState(() => _selectedRestaurant = r),
                    )),
              ],
            ),
            // ── NEXT button ──────────────────────────────────────────────
            if (_selectedRestaurant != null)
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: _NextButton(onTap: _next),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Restaurant tile ───────────────────────────────────────────────────────────

class _RestaurantTile extends StatelessWidget {
  const _RestaurantTile({
    required this.restaurant,
    required this.selected,
    required this.onTap,
  });
  final Restaurant restaurant;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF7B1010)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Logo / icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.restaurant,
                  color: AppColors.textSecondary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.address,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── NEXT button ───────────────────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        alignment: Alignment.center,
        child: const Text(
          'NEXT',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
