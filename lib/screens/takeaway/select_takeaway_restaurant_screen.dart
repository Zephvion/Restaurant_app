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
  final List<String> _cities = [
    'All Cities',
    'Bengaluru',
    'Calicut',
    'Kochi',
    'Trivandrum',
  ];
  String _selectedCity = 'Bengaluru';
  Restaurant? _selectedRestaurant;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _detectInitialCityAndStore();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

    // Initialize with controller's selection if present
    _selectedRestaurant = TakeawayController.instance.selectedRestaurant;
    if (_selectedRestaurant != null) {
      _selectedCity = _selectedRestaurant!.city;
    }
  }

  List<Restaurant> get _filtered {
    final list = MockData.restaurants.where((r) {
      final matchesCity = _selectedCity == 'All Cities' ||
          r.city.toLowerCase() == _selectedCity.toLowerCase();
      if (!matchesCity) return false;
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase().trim();
      return r.name.toLowerCase().contains(q) ||
          r.address.toLowerCase().contains(q) ||
          r.city.toLowerCase().contains(q);
    }).toList();

    final userAddr = SessionManager.instance.getSelectedAddress() ??
        GpsDetectionService.instance.lastDetectedAddress;
    final uLat = userAddr?.lat ?? 12.9753;
    final uLng = userAddr?.lng ?? 77.5910;

    // Sort by proximity to customer (Nearest is always first)
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
                const SizedBox(height: 16),

                // Search Bar for Outlets
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search branches by name, locality...',
                      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 18),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── City chips ───────────────────────────────────────────
                const Text(
                  'Select City / Branch Area',
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
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.copper
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.copper
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
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // ── Restaurant list ─────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedCity == 'All Cities'
                            ? 'All Outlets (Nearest First)'
                            : 'Outlets in $_selectedCity (Nearest First)',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                if (filtered.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'No branches matching "$_searchQuery" in $_selectedCity.'
                            : 'No outlets found in $_selectedCity.',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  )
                else
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
                      final isSelected = _selectedRestaurant?.id == r.id;

                      return _RestaurantTile(
                        restaurant: r,
                        distanceKm: dist,
                        isNearest: isNearest,
                        selected: isSelected,
                        onTap: () => setState(() {
                          if (_selectedRestaurant?.id == r.id) {
                            _selectedRestaurant = null;
                            TakeawayController.instance.deselectRestaurant();
                          } else {
                            _selectedRestaurant = r;
                            TakeawayController.instance.selectRestaurant(r);
                          }
                        }),
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
                label: _selectedRestaurant != null
                    ? 'Confirm ${_selectedRestaurant!.name} & View Menu'
                    : 'Select an Outlet to Continue',
                backgroundColor: _selectedRestaurant != null
                    ? const Color(0xFFFF9500)
                    : AppColors.surfaceLight,
                foregroundColor: _selectedRestaurant != null
                    ? Colors.black
                    : AppColors.textSecondary,
                onPressed: _selectedRestaurant != null ? _next : null,
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
                ? const Color(0xFF10B981)
                : AppColors.border.withValues(alpha: 0.6),
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon + Name/Address + Rating Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF10B981).withValues(alpha: 0.18)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: selected
                        ? const Color(0xFF10B981)
                        : AppColors.textSecondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${restaurant.address}, ${restaurant.city}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(4),
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
                      const Icon(Icons.star, color: Colors.white, size: 10),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bottom Row: Telemetry (Nearest / Distance) + Select/Deselect Button
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9500)
                                .withValues(alpha: 0.18),
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
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      Row(
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
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Interactive Select / Deselect Button
                if (selected)
                  OutlinedButton.icon(
                    onPressed: onTap,
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
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.radio_button_unchecked,
                        size: 13, color: Colors.white),
                    label: const Text('Select'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.copper,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
