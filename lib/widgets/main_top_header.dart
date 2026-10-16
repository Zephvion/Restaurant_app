import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/session_manager.dart';
import '../theme/app_colors.dart';
import 'address_picker_sheet.dart';
import 'network_image_with_fallback.dart';

/// The unified top header matching the Order Food home screen:
/// - Back navigation arrow
/// - User profile avatar / initial
/// - Delivery address dropdown ("Deliver to" + location pin + address name)
/// - Live Order tracking icon with active status indicator
/// - Notifications bell icon
class MainTopHeader extends StatefulWidget {
  const MainTopHeader({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(8, 4, 12, 0),
    this.accentColor,
  });

  final EdgeInsetsGeometry padding;
  final Color? accentColor;

  @override
  State<MainTopHeader> createState() => _MainTopHeaderState();
}

class _MainTopHeaderState extends State<MainTopHeader> {
  void _openAddressPicker() {
    AddressPickerSheet.show(
      context: context,
      onAddressSelected: (addr) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentArea = LocationService.instance.currentDeliveryArea;
    final user = AuthService.instance.currentUser;
    final userInitial = user?.displayName.trim().isNotEmpty == true
        ? user!.displayName.trim()[0].toUpperCase()
        : (user?.email.isNotEmpty == true ? user!.email[0].toUpperCase() : 'G');
    final effectiveAccent = widget.accentColor ?? AppColors.accentRed;

    return Padding(
      padding: widget.padding,
      child: Row(
        children: [
          IconButton(
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: const Icon(Icons.arrow_back_ios_new, size: 19),
            color: AppColors.textPrimary,
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              }
            },
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.account),
            child: ClipOval(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.maroon,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: effectiveAccent.withValues(alpha: 0.85),
                    width: 1.8,
                  ),
                ),
                alignment: Alignment.center,
                child: (user?.photoUrl.trim().isNotEmpty == true)
                    ? NetworkImageWithFallback(
                        url: user!.photoUrl.trim(),
                        fallbackIcon: Icons.person,
                      )
                    : Text(
                        userInitial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: _openAddressPicker,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deliver to',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: effectiveAccent, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          (currentArea.isNotEmpty &&
                                  !currentArea.toLowerCase().contains('palazhi'))
                              ? currentArea
                              : (SessionManager.instance
                                      .getSelectedAddress()
                                      ?.label ??
                                  'Current Location'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.textPrimary, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Dedicated Track Live Order Button
          IconButton(
            tooltip: 'Track Live Order',
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.delivery_dining_outlined,
                    color: AppColors.copper, size: 23),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: effectiveAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.trackOrder),
          ),
          IconButton(
            tooltip: 'Notifications',
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: const Icon(Icons.notifications_none_rounded,
                color: AppColors.textPrimary, size: 23),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.notifications),
          ),
        ],
      ),
    );
  }
}

