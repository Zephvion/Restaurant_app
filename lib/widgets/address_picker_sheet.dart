import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/address.dart';
import '../services/location_service.dart';
import '../services/session_manager.dart';
import '../theme/app_colors.dart';

/// Interactive address & location chooser bottom sheet.
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
  final _customAddressCtrl = TextEditingController();
  final _labelCtrl = TextEditingController(text: 'Other');
  bool _showAddCustom = false;

  @override
  void dispose() {
    _customAddressCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  void _select(Address addr) async {
    await SessionManager.instance.saveSelectedAddress(addr);
    await LocationService.instance.updateDeliveryArea('${addr.label} - ${addr.details.split(',').first}');
    if (mounted) {
      Navigator.of(context).pop();
      widget.onAddressSelected(addr);
    }
  }

  Future<void> _detectCurrentLocation() async {
    setState(() => _isDetectingGps = true);
    await Future.delayed(const Duration(milliseconds: 700));

    final currentGpsAddr = Address(
      label: 'Current Location',
      details: 'Mavoor Road, Near KSRTC Terminal, Calicut, 673001',
      lat: 11.2590,
      lng: 75.7865,
    );

    if (mounted) {
      setState(() => _isDetectingGps = false);
      _select(currentGpsAddr);
    }
  }

  void _saveCustomAddress() {
    if (_customAddressCtrl.text.trim().isEmpty) return;
    final customAddr = Address(
      label: _labelCtrl.text.trim().isNotEmpty ? _labelCtrl.text.trim() : 'Custom',
      details: _customAddressCtrl.text.trim(),
      lat: 11.2600,
      lng: 75.7800,
    );
    _select(customAddr);
  }

  @override
  Widget build(BuildContext context) {
    final currentSelected = SessionManager.instance.getSelectedAddress();

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: const [
                    Icon(Icons.location_on, color: AppColors.accentRed, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Choose Delivery Location',
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Use Current Location',
                              style: TextStyle(
                                color: AppColors.accentRed,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Using GPS / Device Geolocation',
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
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: const Text(
                  'SAVED ADDRESSES',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              for (final addr in MockData.addresses) ...[
                _buildAddressTile(addr, isSelected: currentSelected?.label == addr.label),
              ],

              const Divider(color: AppColors.border, height: 1),

              // Add custom address toggle / form
              if (!_showAddCustom)
                InkWell(
                  onTap: () => setState(() => _showAddCustom = true),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Row(
                      children: const [
                        Icon(Icons.add_location_alt_outlined,
                            color: AppColors.copper, size: 22),
                        SizedBox(width: 14),
                        Text(
                          'Add New Delivery Address',
                          style: TextStyle(
                            color: AppColors.copper,
                            fontWeight: FontWeight.w600,
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
                          'Enter New Address',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _labelCtrl,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Label (e.g. Friends House, Hotel)',
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
                          controller: _customAddressCtrl,
                          maxLines: 2,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Full Address Details',
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

