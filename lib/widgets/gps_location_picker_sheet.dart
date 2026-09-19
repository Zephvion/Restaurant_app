import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/address.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/map_route_service.dart';
import '../services/session_manager.dart';
import '../theme/app_colors.dart';
import 'app_banner.dart';
import 'interactive_map_view.dart';
import 'primary_button.dart';

/// Interactive GPS Live Location & Route Picker.
/// Allows the customer to detect live GPS location, tap on map, preview real driving route,
/// view distance & delivery fee, and confirm their delivery address.
class GpsLocationPickerSheet extends StatefulWidget {
  const GpsLocationPickerSheet({
    super.key,
    required this.onAddressSelected,
    this.initialAddress,
  });

  final ValueChanged<Address> onAddressSelected;
  final Address? initialAddress;

  static Future<Address?> show({
    required BuildContext context,
    required ValueChanged<Address> onAddressSelected,
    Address? initialAddress,
  }) async {
    return showModalBottomSheet<Address>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GpsLocationPickerSheet(
        onAddressSelected: onAddressSelected,
        initialAddress: initialAddress,
      ),
    );
  }

  @override
  State<GpsLocationPickerSheet> createState() => _GpsLocationPickerSheetState();
}

class _GpsLocationPickerSheetState extends State<GpsLocationPickerSheet> {
  late Address _currentAddress;
  DeliveryRoute? _route;
  bool _isLoadingRoute = true;
  bool _isDetectingGps = false;

  final _flatNoCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  String _selectedTag = 'Home';

  // Popular Calicut delivery neighborhoods
  static final List<Address> _neighborhoodPresets = [
    const Address(
      id: 'preset_palazhi',
      label: 'Palazhi (Hilite Mall)',
      details: 'Hilite City, Near Cyberpark, Palazhi, Calicut - 673014',
      lat: 11.2562,
      lng: 75.8335,
    ),
    const Address(
      id: 'preset_cyberpark',
      label: 'Cyberpark',
      details: 'IT Park SEZ, Nellikode, Calicut - 673016',
      lat: 11.2825,
      lng: 75.8611,
    ),
    const Address(
      id: 'preset_mavoor',
      label: 'Mavoor Road',
      details: 'Mavoor Road Junction, Calicut - 673004',
      lat: 11.2612,
      lng: 75.7950,
    ),
    const Address(
      id: 'preset_beach',
      label: 'Calicut Beach',
      details: 'Beach Road, Near Old Pier, Calicut - 673032',
      lat: 11.2635,
      lng: 75.7680,
    ),
    const Address(
      id: 'preset_mananchira',
      label: 'Mananchira',
      details: 'Mananchira Square, Town Hall, Calicut - 673001',
      lat: 11.2514,
      lng: 75.7801,
    ),
    const Address(
      id: 'preset_medcollege',
      label: 'Medical College',
      details: 'Govt Medical College Hospital, Calicut - 673008',
      lat: 11.2721,
      lng: 75.8368,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentAddress = widget.initialAddress ??
        SessionManager.instance.getSelectedAddress() ??
        MockData.addresses.first;
    _updateRoute();
  }

  @override
  void dispose() {
    _flatNoCtrl.dispose();
    _landmarkCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateRoute() async {
    setState(() => _isLoadingRoute = true);
    final route = await MapRouteService.instance.getDeliveryRoute(
      destination: _currentAddress,
    );
    if (mounted) {
      setState(() {
        _route = route;
        _isLoadingRoute = false;
      });
    }
  }

  Future<void> _detectLiveLocation() async {
    setState(() => _isDetectingGps = true);
    await Future.delayed(const Duration(milliseconds: 700));

    // Simulated high-precision device GPS fix
    final liveAddr = Address(
      id: 'gps_${DateTime.now().millisecondsSinceEpoch}',
      label: 'Live GPS Location',
      details: 'Hilite Mall Bypass Road, Palazhi, Calicut - 673014',
      lat: 11.2588 + (math.Random().nextDouble() * 0.006 - 0.003),
      lng: 75.8300 + (math.Random().nextDouble() * 0.006 - 0.003),
      isDefault: true,
    );

    if (mounted) {
      setState(() {
        _currentAddress = liveAddr;
        _isDetectingGps = false;
      });
      _updateRoute();
      AppBanner.showSuccess(
        context,
        'GPS Locked: ${liveAddr.details}',
        title: 'Location Acquired',
      );
    }
  }

  Future<void> _confirmLocation() async {
    var details = _currentAddress.details;
    if (_flatNoCtrl.text.trim().isNotEmpty) {
      details = 'Flat ${_flatNoCtrl.text.trim()}, $details';
    }
    if (_landmarkCtrl.text.trim().isNotEmpty) {
      details = '$details (Near ${_landmarkCtrl.text.trim()})';
    }

    final finalAddress = _currentAddress.copyWith(
      label: _selectedTag,
      details: details,
    );

    await SessionManager.instance.saveSelectedAddress(finalAddress);
    await LocationService.instance.updateDeliveryArea(
      '${finalAddress.label} - ${finalAddress.details.split(',').first}',
    );

    final user = AuthService.instance.currentUser;
    if (user != null) {
      final updatedAddresses = List<Address>.from(user.savedAddresses);
      updatedAddresses.insert(0, finalAddress);
      await AuthService.instance.updateProfile(
        user.copyWith(savedAddresses: updatedAddresses),
      );
    }

    if (mounted) {
      Navigator.of(context).pop(finalAddress);
      widget.onAddressSelected(finalAddress);
      AppBanner.showSuccess(
        context,
        'Delivery location set to ${finalAddress.label} (${finalAddress.details})',
        title: 'Location Confirmed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final distKm = _route?.totalDistanceKm ??
        LocationService.instance.calculateDistanceKm(
          startLat: LocationService.restaurantLat,
          startLng: LocationService.restaurantLng,
          endLat: _currentAddress.lat,
          endLng: _currentAddress.lng,
        );
    final deliveryFee = LocationService.instance.calculateDeliveryFee(_currentAddress);
    final etaMinutes = _route?.estimatedMinutes ?? math.max(12, (distKm * 2.8).round());

    final maxH = MediaQuery.of(context).size.height * 0.88;

    return Container(
      height: maxH,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ── Header Bar ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.share_location_rounded,
                    color: AppColors.copper, size: 24),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Select Live Delivery Location',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // ── Interactive Map View with Live GPS Route ──────────────────
          SizedBox(
            height: 240,
            child: Stack(
              children: [
                InteractiveMapView(
                  destination: _currentAddress,
                  isSelectingLocation: true,
                  showControls: true,
                  showTelemetry: false,
                  onLocationPicked: (newAddr) {
                    setState(() => _currentAddress = newAddr);
                    _updateRoute();
                  },
                ),

                // "Detect Live Location" Floating Button
                Positioned(
                  left: 16,
                  bottom: 14,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.copper,
                      elevation: 4,
                      side: BorderSide(
                        color: AppColors.copper.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    onPressed: _isDetectingGps ? null : _detectLiveLocation,
                    icon: _isDetectingGps
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.copper,
                            ),
                          )
                        : const Icon(Icons.my_location, size: 18),
                    label: Text(
                      _isDetectingGps ? 'Locking GPS...' : 'Detect Live Location',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Route Telemetry Bar ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundElevated,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _metricTile(
                    icon: Icons.directions_car_rounded,
                    label: 'Distance',
                    value: _isLoadingRoute
                        ? '...'
                        : '${distKm.toStringAsFixed(1)} km',
                  ),
                ),
                _metricDivider(),
                Expanded(
                  child: _metricTile(
                    icon: Icons.access_time_rounded,
                    label: 'Delivery ETA',
                    value: _isLoadingRoute ? '...' : '$etaMinutes mins',
                  ),
                ),
                _metricDivider(),
                Expanded(
                  child: _metricTile(
                    icon: Icons.local_shipping_rounded,
                    label: 'Delivery Fee',
                    value: '₹${deliveryFee.round()}',
                  ),
                ),
              ],
            ),
          ),

          // ── Address Selection & Form Body ────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'POPULAR DELIVERY HUBS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _neighborhoodPresets.map((preset) {
                      final selected = _currentAddress.lat == preset.lat &&
                          _currentAddress.lng == preset.lng;
                      return ChoiceChip(
                        label: Text(preset.label),
                        selected: selected,
                        selectedColor: AppColors.copper,
                        backgroundColor: AppColors.backgroundElevated,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: selected
                              ? AppColors.copper
                              : AppColors.border.withValues(alpha: 0.6),
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() => _currentAddress = preset);
                            _updateRoute();
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'SELECTED ADDRESS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on,
                            color: AppColors.copper, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentAddress.label,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _currentAddress.details,
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
                  const SizedBox(height: 16),

                  // Flat / House & Landmark Inputs
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _flatNoCtrl,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Flat / House No.',
                            labelStyle: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                            filled: true,
                            fillColor: AppColors.backgroundElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _landmarkCtrl,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Landmark (optional)',
                            labelStyle: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                            filled: true,
                            fillColor: AppColors.backgroundElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tag (Home / Work / Other)
                  Row(
                    children: ['Home', 'Work', 'Other'].map((tag) {
                      final selected = _selectedTag == tag;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(tag),
                          selected: selected,
                          selectedColor: AppColors.copper,
                          backgroundColor: AppColors.backgroundElevated,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          onSelected: (_) => setState(() => _selectedTag = tag),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    key: const Key('confirm_location_btn'),
                    label: 'Confirm Live Location & Route',
                    onPressed: _confirmLocation,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.copper, size: 18),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricDivider() {
    return Container(
      width: 1,
      height: 24,
      color: AppColors.border.withValues(alpha: 0.6),
    );
  }
}
