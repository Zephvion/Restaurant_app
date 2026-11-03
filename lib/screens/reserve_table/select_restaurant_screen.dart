import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/restaurant.dart';
import '../../routes/app_routes.dart';
import '../../services/location_service.dart';
import '../../theme/app_colors.dart';

/// Screen allowing the user to select restaurant branch for table reservations:
/// - Automatically detects user state and city (e.g. Bengaluru, Karnataka)
/// - Shows only branches for the detected state/city
/// - Automatically orders branches from nearest to farthest
class SelectRestaurantScreen extends StatefulWidget {
  const SelectRestaurantScreen({super.key});

  @override
  State<SelectRestaurantScreen> createState() => _SelectRestaurantScreenState();
}

class _SelectRestaurantScreenState extends State<SelectRestaurantScreen> {
  Restaurant? _selectedRestaurant;

  String get _detectedCity => LocationService.instance.detectedCity;
  String get _detectedState => LocationService.instance.detectedState;

  List<Restaurant> get _filtered {
    final city = _detectedCity.toLowerCase();
    final list = MockData.restaurants
        .where((r) => r.city.toLowerCase() == city)
        .toList();

    final userCoords = LocationService.instance.userCoordinates;
    final uLat = userCoords['lat'] ?? LocationService.defaultLat;
    final uLng = userCoords['lng'] ?? LocationService.defaultLng;

    // Automatic Nearest-to-Farthest sort
    list.sort((a, b) {
      final distA = LocationService.instance.calculateDistanceKm(
        startLat: uLat,
        startLng: uLng,
        endLat: a.lat,
        endLng: a.lng,
      );
      final distB = LocationService.instance.calculateDistanceKm(
        startLat: uLat,
        startLng: uLng,
        endLat: b.lat,
        endLng: b.lng,
      );
      return distA.compareTo(distB);
    });

    return list.isNotEmpty ? list : MockData.restaurants.take(3).toList();
  }

  void _next() {
    if (_selectedRestaurant == null) return;
    Navigator.of(context).pushNamed(
      AppRoutes.reservationBooking,
      arguments: _selectedRestaurant,
    );
  }

  @override
  Widget build(BuildContext context) {
    final outlets = _filtered;

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
                              .pushReplacementNamed(AppRoutes.reserveDashboard);
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
                const SizedBox(height: 24),

                // ── Detected Location Badge ──────────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9500).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFF9500).withValues(alpha: 0.5),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.my_location_rounded,
                            size: 13, color: Color(0xFFFF9500)),
                        const SizedBox(width: 5),
                        Text(
                          '$_detectedCity ($_detectedState)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Restaurant list ─────────────────────────────────────
                const Text(
                  'Select the restaurant',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                ...outlets.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final r = entry.value;
                  final userCoords = LocationService.instance.userCoordinates;
                  final distKm = LocationService.instance.calculateDistanceKm(
                    startLat: userCoords['lat'] ?? LocationService.defaultLat,
                    startLng: userCoords['lng'] ?? LocationService.defaultLng,
                    endLat: r.lat,
                    endLng: r.lng,
                  );

                  return _RestaurantTile(
                    restaurant: r,
                    distanceKm: distKm,
                    isNearest: idx == 0,
                    selected: _selectedRestaurant?.id == r.id,
                    onTap: () => setState(() => _selectedRestaurant =
                        (_selectedRestaurant?.id == r.id ? null : r)),
                  );
                }),
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
    required this.distanceKm,
    this.isNearest = false,
  });
  final Restaurant restaurant;
  final bool selected;
  final VoidCallback onTap;
  final double distanceKm;
  final bool isNearest;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7B1010) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: selected
              ? Border.all(color: AppColors.accentRed, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            // Logo placeholder
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.near_me_rounded,
                        size: 11,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${distanceKm.toStringAsFixed(1)} km away',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isNearest) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFF9500).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFFFF9500)
                                  .withValues(alpha: 0.6),
                              width: 0.6,
                            ),
                          ),
                          child: const Text(
                            'NEAREST',
                            style: TextStyle(
                              color: Color(0xFFFF9500),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
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
