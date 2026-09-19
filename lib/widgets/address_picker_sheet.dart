import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/address.dart';
import '../services/auth_service.dart';
import '../services/gps_detection_service.dart';
import '../services/location_service.dart';
import '../services/session_manager.dart';
import '../theme/app_colors.dart';
import 'app_banner.dart';
import 'gps_location_picker_sheet.dart';

/// Interactive address & location chooser bottom sheet.
/// Supports saved address selection, custom address creation with full persistence,
/// and live simulated GPS location detection.
class AddressPickerSheet extends StatefulWidget {
  const AddressPickerSheet({
    super.key,
    required this.onAddressSelected,
  });

  final Function(Address address) onAddressSelected;

  static Future<void> show({
    required BuildContext context,
    required Function(Address address) onAddressSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddressPickerSheet(
        onAddressSelected: onAddressSelected,
      ),
    );
  }

  @override
  State<AddressPickerSheet> createState() => _AddressPickerSheetState();
}

class _AddressPickerSheetState extends State<AddressPickerSheet> {
  bool _isDetectingGps = false;
  final _flatNoCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  late final TextEditingController _areaCtrl;
  final _labelCtrl = TextEditingController(text: 'Home');
  bool _showAddCustom = false;

  @override
  void initState() {
    super.initState();
    final currentArea = SessionManager.instance.deliveryArea;
    final initialText = (!currentArea.toLowerCase().contains('palazhi') &&
            currentArea != 'Select Delivery Location')
        ? currentArea
        : '';
    _areaCtrl = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _flatNoCtrl.dispose();
    _landmarkCtrl.dispose();
    _areaCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  List<Address> _getLiveAddresses() {
    final user = AuthService.instance.currentUser;
    final savedInSession = SessionManager.instance.getSelectedAddress();
    final list = <Address>[];

    if (savedInSession != null && !savedInSession.details.toLowerCase().contains('palazhi')) {
      list.add(savedInSession);
    }
    if (user != null && user.savedAddresses.isNotEmpty) {
      for (final a in user.savedAddresses) {
        if (!list.any((existing) => existing.details == a.details)) {
          list.add(a);
        }
      }
    }
    if (list.isEmpty) {
      final lastGps = GpsDetectionService.instance.lastDetectedAddress;
      if (lastGps != null) {
        list.add(lastGps);
      } else {
        list.addAll(MockData.addresses);
      }
    }
    return list;
  }

  Future<void> _select(Address addr) async {
    await SessionManager.instance.saveSelectedAddress(addr);
    await LocationService.instance.updateDeliveryArea('${addr.label} - ${addr.details.split(',').first}');
    if (mounted) {
      Navigator.of(context).pop();
      widget.onAddressSelected(addr);
    }
  }

  Future<void> _detectCurrentLocation() async {
    setState(() => _isDetectingGps = true);
    try {
      final result = await GpsDetectionService.instance.detectLiveLocation();
      final currentGpsAddr = result.toAddress();

      // Save to user profile if logged in
      final user = AuthService.instance.currentUser;
      if (user != null) {
        final updatedList = List<Address>.from(user.savedAddresses)..insert(0, currentGpsAddr);
        await AuthService.instance.updateProfile(user.copyWith(savedAddresses: updatedList));
      }

      if (mounted) {
        setState(() => _isDetectingGps = false);
        AppBanner.showSuccess(
          context,
          'GPS Location resolved: ${currentGpsAddr.label} (${currentGpsAddr.details.split(',').take(2).join(', ')})',
          title: 'Location Detected',
        );
        _select(currentGpsAddr);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDetectingGps = false);
        AppBanner.showError(
          context,
          'Failed to detect GPS location. Please choose on map.',
          title: 'Detection Error',
        );
      }
    }
  }

  Future<void> _saveCustomAddress() async {
    final flat = _flatNoCtrl.text.trim();
    final landmark = _landmarkCtrl.text.trim();
    final area = _areaCtrl.text.trim();
    final label = _labelCtrl.text.trim();

    if (flat.isEmpty || area.isEmpty) {
      AppBanner.showError(context, 'Please enter flat/house number and area.');
      return;
    }

    final fullDetails = [
      flat,
      if (landmark.isNotEmpty) 'Near $landmark',
      area,
    ].join(', ');

    final customAddr = Address(
      id: 'addr_custom_${DateTime.now().millisecondsSinceEpoch}',
      label: label.isNotEmpty ? label : 'Other',
      details: fullDetails,
      lat: 11.2595,
      lng: 75.7820,
    );

    // Save to UserProfile
    final user = AuthService.instance.currentUser;
    if (user != null) {
      final updatedList = List<Address>.from(user.savedAddresses)..add(customAddr);
      await AuthService.instance.updateProfile(user.copyWith(savedAddresses: updatedList));
    }

    if (mounted) {
      AppBanner.showSuccess(
        context,
        'Saved "$label" address successfully!',
        title: 'Address Saved',
      );
      _select(customAddr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSelected = SessionManager.instance.getSelectedAddress();
    final addresses = _getLiveAddresses();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.2),
          left: BorderSide(color: AppColors.border, width: 1.2),
          right: BorderSide(color: AppColors.border, width: 1.2),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Drag pill
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.accentRed, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Select Delivery Location',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border, height: 1),

              // Interactive GPS Route Map Picker Button
              InkWell(
                onTap: () async {
                  Navigator.of(context).pop();
                  await GpsLocationPickerSheet.show(
                    context: context,
                    onAddressSelected: widget.onAddressSelected,
                    initialAddress: currentSelected,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.copper.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.map_rounded, color: AppColors.copper, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select on Map & Live GPS Route',
                              style: TextStyle(
                                color: AppColors.copper,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Pinpoint live location & view driving route from Paragon',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.copper),
                    ],
                  ),
                ),
              ),

              const Divider(color: AppColors.border, height: 1),

              // GPS Button
              InkWell(
                onTap: _isDetectingGps ? null : _detectCurrentLocation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accentRed.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: _isDetectingGps
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
                                ),
                              )
                            : const Icon(Icons.my_location, color: AppColors.accentRed, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Use Current GPS Location',
                              style: TextStyle(
                                color: AppColors.accentRed,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Hilite Mall Road, Palazhi, Calicut',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.hint),
                    ],
                  ),
                ),
              ),

              const Divider(color: AppColors.border, height: 1),

              // Saved Addresses
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Text(
                  'SAVED ADDRESSES',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              for (final addr in addresses) ...[
                _buildAddressTile(addr, isSelected: currentSelected?.label == addr.label),
              ],

              const Divider(color: AppColors.border, height: 1),

              // Add custom address toggle / form
              if (!_showAddCustom)
                InkWell(
                  onTap: () => setState(() => _showAddCustom = true),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Row(
                      children: [
                        Icon(Icons.add_location_alt_outlined,
                            color: AppColors.copper, size: 22),
                        SizedBox(width: 14),
                        Text(
                          'Add New Delivery Address',
                          style: TextStyle(
                            color: AppColors.copper,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Enter Full Address Details',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _labelChip('Home'),
                            const SizedBox(width: 8),
                            _labelChip('Office'),
                            const SizedBox(width: 8),
                            _labelChip('Other'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _flatNoCtrl,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Flat / House / Apartment No.',
                            labelStyle: const TextStyle(color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.backgroundElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _landmarkCtrl,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Landmark (e.g. Near Metro, Behind Temple)',
                            labelStyle: const TextStyle(color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.backgroundElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _areaCtrl,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'City / Area',
                            labelStyle: const TextStyle(color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.backgroundElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => setState(() => _showAddCustom = false),
                              child: const Text('Cancel',
                                  style: TextStyle(color: AppColors.textSecondary)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _saveCustomAddress,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.maroon,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('SAVE & SELECT',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labelChip(String label) {
    final selected = _labelCtrl.text == label;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.copper,
      backgroundColor: AppColors.backgroundElevated,
      labelStyle: TextStyle(
        color: selected ? Colors.black : AppColors.textPrimary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      onSelected: (val) {
        if (val) setState(() => _labelCtrl.text = label);
      },
    );
  }

  Widget _buildAddressTile(Address addr, {required bool isSelected}) {
    IconData iconData = Icons.location_on_outlined;
    if (addr.label.toLowerCase() == 'home') iconData = Icons.home_outlined;
    if (addr.label.toLowerCase() == 'office') iconData = Icons.business_outlined;

    return InkWell(
      onTap: () => _select(addr),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              iconData,
              color: isSelected ? AppColors.copper : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addr.label,
                    style: TextStyle(
                      color: isSelected ? AppColors.copper : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    addr.details,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.copper, size: 20),
          ],
        ),
      ),
    );
  }
}
