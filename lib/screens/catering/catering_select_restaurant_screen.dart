import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/restaurant.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/network_image_with_fallback.dart';

/// Step 1 of Catering Booking: Lists Paragon restaurant branches
/// for the user to choose which branch handles their catering event.
class CateringSelectRestaurantScreen extends StatefulWidget {
  const CateringSelectRestaurantScreen({super.key});

  @override
  State<CateringSelectRestaurantScreen> createState() =>
      _CateringSelectRestaurantScreenState();
}

class _CateringSelectRestaurantScreenState
    extends State<CateringSelectRestaurantScreen> {
  final List<String> _cities = ['Calicut', 'Kochi', 'Trivandrum', 'Bangalore'];
  String _selectedCity = 'Calicut';
  Restaurant? _selectedRestaurant;

  List<Restaurant> get _filteredRestaurants {
    final list = MockData.restaurants
        .where((r) => r.city.toLowerCase() == _selectedCity.toLowerCase())
        .toList();
    if (list.isEmpty) {
      return MockData.restaurants.take(3).toList();
    }
    return list;
  }

  void _proceed() {
    if (_selectedRestaurant == null) return;
    Navigator.of(context).pushNamed(
      AppRoutes.cateringBooking,
      arguments: _selectedRestaurant,
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = _filteredRestaurants;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                // ── Top Header ──────────────────────────────────────────────
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
                              .pushReplacementNamed(AppRoutes.cateringDashboard);
                        }
                      },
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Step 1 of 4: Select Branch',
                            style: TextStyle(
                              color: AppColors.copper,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Choose Catering Restaurant',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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
                const SizedBox(height: 20),

                // ── City Filter Chips ─────────────────────────────────────────
                const Text(
                  'Select City',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _cities.map((city) {
                      final isSelected = city == _selectedCity;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCity = city;
                            _selectedRestaurant = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accentRed
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accentRed
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            city,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Restaurant Branch Cards ──────────────────────────────────
                const Text(
                  'Available Catering Hubs',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                for (final rest in restaurants) ...[
                  _RestaurantBranchCard(
                    restaurant: rest,
                    isSelected: _selectedRestaurant?.id == rest.id,
                    onTap: () {
                      setState(() {
                        _selectedRestaurant = rest;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            ),

            // ── Persistent Proceed Button ────────────────────────────────────
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedRestaurant != null
                      ? AppColors.accentRed
                      : AppColors.surface,
                  foregroundColor: _selectedRestaurant != null
                      ? Colors.white
                      : AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  elevation: _selectedRestaurant != null ? 4 : 0,
                ),
                onPressed: _selectedRestaurant != null ? _proceed : null,
                child: Text(
                  _selectedRestaurant != null
                      ? 'CONTINUE TO EVENT DETAILS'
                      : 'SELECT A RESTAURANT BRANCH',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantBranchCard extends StatelessWidget {
  const _RestaurantBranchCard({
    required this.restaurant,
    required this.isSelected,
    required this.onTap,
  });

  final Restaurant restaurant;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentRed.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.accentRed : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: NetworkImageWithFallback(
                  url: restaurant.imageUrl ?? '',
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.restaurant,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: AppColors.accentRed, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.copper, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.address,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _badge('⭐ ${restaurant.rating}'),
                      _badge('Capacity: 50–1500+ Guests'),
                      _badge('Malabar & Kerala'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
