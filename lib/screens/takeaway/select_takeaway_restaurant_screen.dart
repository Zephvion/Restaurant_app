import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/restaurant.dart';
import '../../routes/app_routes.dart';
import '../../services/gps_detection_service.dart';
import '../../services/location_service.dart';
import '../../services/session_manager.dart';
import '../../state/takeaway_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';

/// Screen allowing the user to select city and restaurant branch for takeaway in Domino's style:
/// - Automatically detects closest city & branch
/// - Displays real-time GPS distance badges
/// - Sorts outlets by proximity
/// - Shows operating hours & pickup preparation time
class SelectTakeawayRestaurantScreen extends StatefulWidget {
  const SelectTakeawayRestaurantScreen({super.key});

  @override
  State<SelectTakeawayRestaurantScreen> createState() =>
      _SelectTakeawayRestaurantScreenState();
}

class _SelectTakeawayRestaurantScreenState
    extends State<SelectTakeawayRestaurantScreen> {
  final List<String> _cities = ['Bengaluru', 'Calicut', 'Kochi', 'Trivandrum'];
  String _selectedCity = 'Bengaluru';
  Restaurant? _selectedRestaurant;

  @override
  void initState() {
    super.initState();
    _detectInitialCityAndStore();
  }

  void _detectInitialCityAndStore() {
    final userAddr = SessionManager.instance.getSelectedAddress() ??
        GpsDetectionService.instance.lastDetectedAddress;
    final cityText = '${userAddr?.label} ${userAddr?.details}'.toLowerCase();

    if (cityText.contains('bengaluru') || cityText.contains('bangalore')) {
      _selectedCity = 'Bengaluru';
    } else if (cityText.contains('kochi') || cityText.contains('cochin') || cityText.contains('ernakulam')) {
      _selectedCity = 'Kochi';
    } else if (cityText.contains('trivandrum') || cityText.contains('thiruvananthapuram')) {
      _selectedCity = 'Trivandrum';
    } else if (cityText.contains('calicut') || cityText.contains('kozhikode')) {
      _selectedCity = 'Calicut';
    } else {
      _selectedCity = 'Bengaluru';
    }

    final active = TakeawayController.instance.activeRestaurant;
    _selectedRestaurant = active.city.toLowerCase() == _selectedCity.toLowerCase()
        ? active
        : _filtered.firstOrNull;
  }

  List<Restaurant> get _filtered {
    final list = MockData.restaurants
        .where((r) => r.city.toLowerCase() == _selectedCity.toLowerCase())
        .toList();

    final userAddr = SessionManager.instance.getSelectedAddress() ??
        GpsDetectionService.instance.lastDetectedAddress;
    final uLat = userAddr?.lat ?? 12.9753;
    final uLng = userAddr?.lng ?? 77.5910;

    // Sort by proximity to customer
    list.sort((a, b) {
      final dA = LocationService.instance.calculateDistanceKm(
        startLat: uLat,
        startLng: uLng,
        endLat: a.lat,
        endLng: a.lng,
      );
      final dB = LocationService.instance.calculateDistanceKm(
        startLat: uLat,
        startLng: uLng,
        endLat: b.lat,
        endLng: b.lng,
      );
      return dA.compareTo(dB);
    });

    return list;
  }

  void _next() {
    if (_selectedRestaurant == null) return;
    TakeawayController.instance.selectRestaurant(_selectedRestaurant!);
    Navigator.of(context).pushNamed(AppRoutes.takeawayMenu);
  }

  @override
  Widget build(BuildContext context) {
    final userAddr = SessionManager.instance.getSelectedAddress() ??
        GpsDetectionService.instance.lastDetectedAddress;
    final uLat = userAddr?.lat ?? 12.9753;
    final uLng = userAddr?.lng ?? 77.5910;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
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
                    const Icon(Icons.storefront_rounded,
                        color: AppColors.copper, size: 22),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Select Pickup Outlet',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // GPS Location Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.copper.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location_rounded,
                          color: AppColors.copper, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your Location: ${userAddr?.label ?? 'Bengaluru'} (${userAddr?.details.split(',').first ?? 'Live GPS'})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── City chips ───────────────────────────────────────────
                const Text(
                  'Select City',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _cities.map((city) {
                    final selected = city == _selectedCity;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedCity = city;
                        _selectedRestaurant = _filtered.firstOrNull;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 11),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.accentRed
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.accentRed
                                : AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          city,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // ── Restaurant list ─────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Outlets in $_selectedCity',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${filtered.length} available',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                for (int i = 0; i < filtered.length; i++) ...[
                  () {
                    final r = filtered[i];
                    final dist = LocationService.instance.calculateDistanceKm(
                      startLat: uLat,
                      startLng: uLng,
                      endLat: r.lat,
                      endLng: r.lng,
                    );
                    final isNearest = (i == 0 && dist < 50);

                    return _RestaurantTile(
                      restaurant: r,
                      distanceKm: dist,
                      isNearest: isNearest,
                      selected: (_selectedRestaurant?.id == r.id) ||
                          (_selectedRestaurant == null && i == 0),
                      onTap: () => setState(() => _selectedRestaurant = r),
                    );
                  }(),
                ],
              ],
            ),

            // ── Fixed Bottom Button ──────────────────────────────────────
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: PrimaryButton(
                label: 'Confirm Store & View Menu',
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Domino's Restaurant Tile ──────────────────────────────────────────────────

class _RestaurantTile extends StatelessWidget {
  const _RestaurantTile({
    required this.restaurant,
    required this.distanceKm,
    required this.isNearest,
    required this.selected,
    required this.onTap,
  });

  final Restaurant restaurant;
  final double distanceKm;
  final bool isNearest;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final distText = distanceKm < 100
        ? '${distanceKm.toStringAsFixed(1)} km away'
        : 'Outlet';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.surface.withValues(alpha: 0.95)
              : AppColors.backgroundElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.copper
                : AppColors.border.withValues(alpha: 0.6),
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.copper.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.copper.withValues(alpha: 0.18)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.restaurant_rounded,
                    color: selected ? AppColors.copper : AppColors.textSecondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              restaurant.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${restaurant.rating}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.star,
                                    color: Colors.white, size: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${restaurant.address}, ${restaurant.city}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Telemetry Badges Row
            Row(
              children: [
                if (isNearest) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.copper.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.copper.withValues(alpha: 0.5),
                        width: 0.7,
                      ),
                    ),
                    child: const Text(
                      'NEAREST OUTLET',
                      style: TextStyle(
                        color: AppColors.copper,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.near_me_rounded,
                          color: Color(0xFF81C784), size: 11),
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
                ),
                const Spacer(),
                Text(
                  'Open till ${restaurant.closeTime}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
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
