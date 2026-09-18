import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../state/cart_controller.dart';
import '../theme/app_colors.dart';
import 'address_picker_sheet.dart';

/// Which tab is currently active in the floating bottom navigation bar.
enum ParagonTab { home, location, cart, account }

/// The floating rounded navigation bar used across the Order Food screens.
///
/// The active tab is drawn as a lifted pill; the cart tab carries a live badge
/// sourced from [CartController].
class ParagonBottomNav extends StatelessWidget {
  const ParagonBottomNav({super.key, required this.current});

  final ParagonTab current;

  void _go(BuildContext context, ParagonTab tab) {
    if (tab == current) return;
    switch (tab) {
      case ParagonTab.home:
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.foodHome,
          (route) => route.settings.name == AppRoutes.home ||
              route.isFirst,
        );
        break;
      case ParagonTab.location:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.surfaceLight,
              content: Text('Choose a delivery location'),
            ),
          );
        AddressPickerSheet.show(
          context: context,
          onAddressSelected: (addr) {
            CartController.instance.selectAddress(addr);
          },
        );
        break;
      case ParagonTab.cart:
        Navigator.of(context).pushNamed(AppRoutes.cart);
        break;
      case ParagonTab.account:
        Navigator.of(context).pushNamed(AppRoutes.account);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.backgroundElevated,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  active: current == ParagonTab.home,
                  onTap: () => _go(context, ParagonTab.home),
                ),
                _NavItem(
                  icon: Icons.location_on_outlined,
                  active: current == ParagonTab.location,
                  onTap: () => _go(context, ParagonTab.location),
                ),
                _CartNavItem(
                  active: current == ParagonTab.cart,
                  onTap: () => _go(context, ParagonTab.cart),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  label: current == ParagonTab.account ? 'Account' : null,
                  active: current == ParagonTab.account,
                  onTap: () => _go(context, ParagonTab.account),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.active,
    required this.onTap,
    this.label,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.textPrimary : AppColors.hint;
    return Material(
      color: active ? AppColors.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: label != null ? 16 : 14,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null) ...[
                Text(
                  label!,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(icon, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartNavItem extends StatelessWidget {
  const _CartNavItem({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.textPrimary : AppColors.hint;
    return Material(
      color: active ? AppColors.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: AnimatedBuilder(
            animation: CartController.instance,
            builder: (context, _) {
              final count = CartController.instance.totalQuantity;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.shopping_cart_outlined, color: color, size: 24),
                  if (count > 0)
                    Positioned(
                      top: -6,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints:
                            const BoxConstraints(minWidth: 17, minHeight: 17),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.accentRed,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
