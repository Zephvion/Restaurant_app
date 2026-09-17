import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/address.dart';
import '../../models/user_profile.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/paragon_bottom_nav.dart';

/// Account — profile header plus an accordion of settings sections (address,
/// order history, payments, table reservation, food planner, contact, logout).
/// Account — live profile header, saved addresses, and settings sections.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  void _soon(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceLight,
          content: Text('$what — coming soon'),
        ),
      );
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _headerRow(context),
            const SizedBox(height: 22),
            _profile(context),
            const SizedBox(height: 26),
            _AccountExpansion(
              icon: Icons.location_on_outlined,
              title: 'Address',
    return StreamBuilder<UserProfile?>(
      stream: AuthService.instance.authStateChanges,
      initialData: AuthService.instance.currentUser,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final displayName = profile?.displayName.isNotEmpty == true
            ? profile!.displayName
            : MockData.userName;
        final phone = profile?.phone.isNotEmpty == true
            ? profile!.phone
            : MockData.userPhone;
        final email = profile?.email.isNotEmpty == true
            ? profile!.email
            : MockData.userEmail;
        final photoUrl = profile?.photoUrl.isNotEmpty == true
            ? profile!.photoUrl
            : MockData.userAvatar;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                for (final a in MockData.addresses) _addressItem(a),
                _headerRow(context),
                const SizedBox(height: 22),
                _profile(
                  context,
                  name: displayName,
                  phone: phone,
                  email: email,
                  photoUrl: photoUrl,
                ),
                const SizedBox(height: 26),
                _AccountExpansion(
                  icon: Icons.location_on_outlined,
                  title: 'Address',
                  children: [
                    for (final a in MockData.addresses) _addressItem(a),
                  ],
                ),
                _AccountLink(
                  icon: Icons.receipt_long_outlined,
                  title: 'Order history',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.previousOrder),
                ),
                _AccountLink(
                  icon: Icons.credit_card,
                  title: 'Payments',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.paymentMethods),
                ),
                _AccountExpansion(
                  icon: Icons.event_seat_outlined,
                  title: 'Table Reservation',
                  children: [_reservationItem()],
                ),
                _AccountExpansion(
                  icon: Icons.restaurant_menu,
                  title: 'Food Planner',
                  children: [
                    _plannerItem(context, 'Today'),
                    _plannerItem(context, 'This Week'),
                    _plannerItem(context, 'Next Week'),
                  ],
                ),
                _AccountExpansion(
                  icon: Icons.headset_mic_outlined,
                  title: 'Contact Us',
                  children: [
                    _contactLine(Icons.call, MockData.deliveryPartnerPhone),
                    const SizedBox(height: 10),
                    _contactLine(Icons.email_outlined, 'support@paragon.com'),
                  ],
                ),
                _AccountLink(
                  icon: Icons.logout,
                  title: 'Logout',
                  danger: true,
                  onTap: () => _logout(context),
                ),
              ],
            ),
            _AccountLink(
              icon: Icons.receipt_long_outlined,
              title: 'Order history',
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.previousOrder),
            ),
            _AccountLink(
              icon: Icons.credit_card,
              title: 'Payments',
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.paymentMethods),
            ),
            _AccountExpansion(
              icon: Icons.event_seat_outlined,
              title: 'Table Reservation',
              children: [_reservationItem()],
            ),
            _AccountExpansion(
              icon: Icons.restaurant_menu,
              title: 'Food Planner',
              children: [
                _plannerItem(context, 'Today'),
                _plannerItem(context, 'This Week'),
                _plannerItem(context, 'Next Week'),
              ],
            ),
            _AccountExpansion(
              icon: Icons.headset_mic_outlined,
              title: 'Contact Us',
              children: [
                _contactLine(Icons.call, MockData.deliveryPartnerPhone),
                const SizedBox(height: 10),
                _contactLine(Icons.email_outlined, 'support@paragon.com'),
              ],
            ),
            _AccountLink(
              icon: Icons.logout,
              title: 'Logout',
              danger: true,
              onTap: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.login, (r) => false),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          const ParagonBottomNav(current: ParagonTab.account),
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

  Widget _profile(BuildContext context) {
  Widget _profile(
    BuildContext context, {
    required String name,
    required String phone,
    required String email,
    required String photoUrl,
  }) {
    return Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: 76,
            height: 76,
            child: NetworkImageWithFallback(
              url: MockData.userAvatar,
              url: photoUrl,
              fallbackIcon: Icons.person,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(MockData.userName,
                  style: Theme.of(context).textTheme.titleLarge),
              Text(name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              _editableLine(MockData.userPhone),
              _editableLine(phone),
              const SizedBox(height: 4),
              _editableLine(MockData.userEmail),
              _editableLine(email),
            ],
          ),
        ),
      ],
    );
  }

  Widget _editableLine(String value) {
    return Row(
      children: [
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.edit_outlined, size: 13, color: AppColors.copper),
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

  Widget _reservationItem() {
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
            child: const Text(
              '6',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Upcoming reservation',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              SizedBox(height: 3),
              Text('January 2, 2023',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _plannerItem(BuildContext context, String label) {
    return InkWell(
      onTap: () => _soon(context, label),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _contactLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.copper),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        ),
      ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
      ),
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
    );
  }
}

/// A single tappable settings row (navigates rather than expands).
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
      ),
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
    );
  }
}
