import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/address.dart';
import '../../models/user_profile.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../state/catering_controller.dart';
import '../../state/reservation_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/address_picker_sheet.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/edit_profile_sheet.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/paragon_bottom_nav.dart';

/// Account — live registered user profile, saved addresses, reservations, and settings.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.instance.signOut();
    await CateringController.instance.reload();
    if (context.mounted) {
      AppBanner.showInfo(
        context,
        'You have been logged out.',
        title: 'Logged Out',
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  void _openAddressPicker(BuildContext context) {
    AddressPickerSheet.show(
      context: context,
      onAddressSelected: (addr) {
        AppBanner.showSuccess(
          context,
          'Selected delivery address: ${addr.label}',
          title: 'Address Updated',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: AuthService.instance.authStateChanges,
      initialData: AuthService.instance.currentUser,
      builder: (context, snapshot) {
        final profile = snapshot.data ?? AuthService.instance.currentUser;
        
        // Priority: Registered user name -> Email user part -> 'Valued Guest'
        final String displayName;
        if (profile != null && profile.displayName.trim().isNotEmpty) {
          displayName = profile.displayName.trim();
        } else if (profile != null && profile.email.contains('@')) {
          displayName = profile.email.split('@').first;
        } else {
          displayName = 'Valued Guest';
        }

        final phone = (profile != null && profile.phone.trim().isNotEmpty)
            ? profile.phone.trim()
            : '+91 9874563210';
        final email = (profile != null && profile.email.trim().isNotEmpty)
            ? profile.email.trim()
            : 'guest@paragon.com';
        final photoUrl = (profile != null && profile.photoUrl.trim().isNotEmpty)
            ? profile.photoUrl.trim()
            : MockData.userAvatar;

        final savedAddresses = (profile != null && profile.savedAddresses.isNotEmpty)
            ? profile.savedAddresses
            : MockData.addresses;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _headerRow(context),
                const SizedBox(height: 22),
                _profile(
                  context,
                  profile: profile,
                  name: displayName,
                  phone: phone,
                  email: email,
                  photoUrl: photoUrl,
                ),
                const SizedBox(height: 26),

                // ── Addresses ────────────────────────────────────────────────
                _AccountExpansion(
                  icon: Icons.location_on_outlined,
                  title: 'Saved Delivery Addresses',
                  children: [
                    for (final a in savedAddresses) _addressItem(a),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _openAddressPicker(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.copper.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.copper.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_location_alt_outlined, color: AppColors.copper, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Add / Change Delivery Location',
                              style: TextStyle(
                                color: AppColors.copper,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Order History ────────────────────────────────────────────
                _AccountLink(
                  icon: Icons.receipt_long_outlined,
                  title: 'Order History',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.previousOrder),
                ),

                // ── Payments ─────────────────────────────────────────────────
                _AccountLink(
                  icon: Icons.credit_card,
                  title: 'Payment Methods & Cards',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.paymentMethods),
                ),

                // ── Table Reservations ───────────────────────────────────────
                _AccountExpansion(
                  icon: Icons.event_seat_outlined,
                  title: 'Table Reservations',
                  children: [
                    _reservationSection(context),
                  ],
                ),

                // ── Food Planner ─────────────────────────────────────────────
                _AccountExpansion(
                  icon: Icons.restaurant_menu,
                  title: 'Food Planner & Diet Schedules',
                  children: [
                    _plannerItem(context, 'Today\'s Meal Plan', 'View current daily macros'),
                    _plannerItem(context, 'Weekly Food Schedule', 'Plan breakfast, lunch & dinner'),
                    _plannerItem(context, 'Calorie Calculator', 'Calculate personal target macros'),
                  ],
                ),

                // ── Contact Us ───────────────────────────────────────────────
                _AccountExpansion(
                  icon: Icons.headset_mic_outlined,
                  title: 'Customer Support & Hotline',
                  children: [
                    _contactLine(
                      context,
                      Icons.call,
                      'Hotline: +91 98470 12345',
                      onTap: () => AppBanner.showInfo(
                        context,
                        'Connecting to Paragon customer helpline...',
                        title: 'Support Call',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _contactLine(
                      context,
                      Icons.email_outlined,
                      'Email: care@paragonrestaurant.com',
                      onTap: () => AppBanner.showInfo(
                        context,
                        'Opening email client for care@paragonrestaurant.com',
                        title: 'Email Support',
                      ),
                    ),
                  ],
                ),

                // ── Logout ───────────────────────────────────────────────────
                _AccountLink(
                  icon: Icons.logout,
                  title: 'Logout',
                  danger: true,
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
          bottomNavigationBar:
              const ParagonBottomNav(current: ParagonTab.account),
        );
      },
    );
  }

  Widget _headerRow(BuildContext context) {
    return Row(
      children: [
        Text('My Account', style: Theme.of(context).textTheme.headlineSmall),
        const Spacer(),
        Material(
          color: AppColors.maroon,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.foodHome),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.restaurant, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Order Food',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _profile(
    BuildContext context, {
    required UserProfile? profile,
    required String name,
    required String phone,
    required String email,
    required String photoUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: NetworkImageWithFallback(
                    url: photoUrl,
                    fallbackIcon: Icons.person,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => EditProfileSheet.show(context, profile: profile),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.copper,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    child: const Icon(Icons.edit, size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
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
                        name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => EditProfileSheet.show(context, profile: profile),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.copper.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.copper.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_outlined, size: 12, color: AppColors.copper),
                            SizedBox(width: 4),
                            Text(
                              'Edit',
                              style: TextStyle(
                                color: AppColors.copper,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _displayLine(phone, Icons.phone_android),
                const SizedBox(height: 4),
                _displayLine(email, Icons.email_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _displayLine(String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.copper),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _addressItem(Address a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.accentRed,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a.details,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.3,
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

  Widget _reservationSection(BuildContext context) {
    final reservations = ReservationController.instance.reservations;
    if (reservations.isNotEmpty) {
      final latest = reservations.first;
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.maroon,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                '${latest.seats}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Table #${latest.tableNumber} · ${latest.timeSlot}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 3),
                  Text(
                    '${latest.restaurant.name} · ${latest.seats} Guests',
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
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'No upcoming reservations',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.maroon,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.reserveDashboard),
          child: const Text('Book Table',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _plannerItem(BuildContext context, String label, String subtitle) {
    return InkWell(
      onTap: () {
        AppBanner.showSuccess(
          context,
          'Opening $label...',
          title: 'Food Planner',
        );
        Navigator.of(context).pushNamed(AppRoutes.foodPlanner);
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.copper.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_month, size: 16, color: AppColors.copper),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _contactLine(BuildContext context, IconData icon, String text, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.copper),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              ),
            ),
            const Icon(Icons.open_in_new, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// A collapsible settings section with an icon, title and expandable body.
class _AccountExpansion extends StatelessWidget {
  const _AccountExpansion({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            iconColor: AppColors.copper,
            collapsedIconColor: AppColors.textSecondary,
            leading: Icon(icon, color: AppColors.copper, size: 22),
            title: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            children: children,
          ),
        ),
      ),
    );
  }
}

/// A single tappable settings row.
class _AccountLink extends StatelessWidget {
  const _AccountLink({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final Color accent = danger ? AppColors.accentRed : AppColors.copper;
    final Color textColor =
        danger ? AppColors.accentRed : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: accent, size: 22),
          title: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing:
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
