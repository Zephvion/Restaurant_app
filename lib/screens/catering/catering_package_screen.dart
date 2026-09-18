import 'package:flutter/material.dart';

import '../../models/restaurant.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import 'catering_booking_screen.dart';

class CateringPackage {
  final String id;
  final String title;
  final double pricePerPlate;
  final String description;
  final List<String> highlights;
  final String tag;

  const CateringPackage({
    required this.id,
    required this.title,
    required this.pricePerPlate,
    required this.description,
    required this.highlights,
    required this.tag,
  });
}

/// Arguments passed from Package Screen to Notify / Venue screen.
class CateringPackageArgs {
  const CateringPackageArgs({
    this.restaurant,
    required this.date,
    required this.timeSlot,
    required this.guestRange,
    required this.eventType,
    required this.menuPackage,
    required this.pricePerPlate,
    required this.dietaryPreference,
    required this.needLiveCounters,
    required this.needServiceStaff,
  });

  final Restaurant? restaurant;
  final DateTime date;
  final String timeSlot;
  final String guestRange;
  final String eventType;
  final String menuPackage;
  final double pricePerPlate;
  final String dietaryPreference;
  final bool needLiveCounters;
  final bool needServiceStaff;
}

/// Step 3 of Catering: Menu Package Selection & Service Customization.
class CateringPackageScreen extends StatefulWidget {
  const CateringPackageScreen({super.key});

  @override
  State<CateringPackageScreen> createState() => _CateringPackageScreenState();
}

class _CateringPackageScreenState extends State<CateringPackageScreen> {
  static const List<CateringPackage> _packages = [
    CateringPackage(
      id: 'pkg_royal_malabar',
      title: 'Royal Malabar Feast',
      pricePerPlate: 550.0,
      tag: 'BESTSELLER',
      description: 'The pinnacle of authentic Kozhikodan grand hospitality.',
      highlights: [
        'Thalassery Mutton Biryani',
        'Kozhikode Chicken 65',
        'Fish Mango Curry',
        'Kerala Porotta (Hot Live)',
        'Ada Pradhaman & Palada Payasam',
        'Welcome Mocktails',
      ],
    ),
    CateringPackage(
      id: 'pkg_traditional_sadhya',
      title: 'Traditional Kerala Sadhya',
      pricePerPlate: 350.0,
      tag: 'PURE VEGETARIAN',
      description: '24 authentic pure vegetarian dishes served on banana leaf.',
      highlights: [
        'Kerala Red Matta Rice',
        'Parippu Ghee & Pappadam',
        'Avial, Thoran, Kalan & Olan',
        'Sambar & Rasam',
        '3 Varieties of Royal Payasam',
        'Banana & Sharkara Upperi',
      ],
    ),
    CateringPackage(
      id: 'pkg_executive_buffet',
      title: 'Executive Biryani & Grill Buffet',
      pricePerPlate: 480.0,
      tag: 'PREMIUM BUFFET',
      description: 'A lavish multi-cuisine spread suitable for corporate galas.',
      highlights: [
        'Paragon Special Chicken Biryani',
        'Grilled Fish Tikka & Kebabs',
        'Appam & Chicken Stew',
        'Fresh Continental Salad Bar',
        'Gulab Jamun & Ice Cream Sundae',
      ],
    ),
    CateringPackage(
      id: 'pkg_custom_gourmet',
      title: 'Custom Gourmet Selection',
      pricePerPlate: 420.0,
      tag: 'CUSTOMIZABLE',
      description: 'Tailored menu curated in direct consultation with Master Chefs.',
      highlights: [
        'Choice of 4 Starters & Soups',
        'Choice of 3 Rice & Bread Mains',
        'Live Seafood Cooking Stations',
        'Exclusive Dessert Platter',
      ],
    ),
  ];

  String _selectedPackageId = 'pkg_royal_malabar';
  String _dietaryPreference = 'Mixed (Non-Veg & Veg)';
  bool _needLiveCounters = true;
  bool _needServiceStaff = true;

  CateringBookingArgs get _args =>
      ModalRoute.of(context)!.settings.arguments as CateringBookingArgs;

  void _proceed() {
    final selectedPkg =
        _packages.firstWhere((p) => p.id == _selectedPackageId);
    final bookingArgs = _args;

    Navigator.of(context).pushNamed(
      AppRoutes.cateringNotify,
      arguments: CateringPackageArgs(
        restaurant: bookingArgs.restaurant,
        date: bookingArgs.date,
        timeSlot: bookingArgs.timeSlot,
        guestRange: bookingArgs.guestRange,
        eventType: bookingArgs.eventType,
        menuPackage: selectedPkg.title,
        pricePerPlate: selectedPkg.pricePerPlate,
        dietaryPreference: _dietaryPreference,
        needLiveCounters: _needLiveCounters,
        needServiceStaff: _needServiceStaff,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                // ── Top Header ──────────────────────────────────────────────
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: AppColors.textPrimary, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Step 3 of 4: Select Menu Package',
                            style: TextStyle(
                              color: AppColors.copper,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Catering Menu Packages',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Packages List ────────────────────────────────────────────
                for (final pkg in _packages) ...[
                  _PackageCard(
                    pkg: pkg,
                    isSelected: _selectedPackageId == pkg.id,
                    onTap: () => setState(() => _selectedPackageId = pkg.id),
                  ),
                  const SizedBox(height: 14),
                ],

                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 16),

                // ── Service Addons & Staff Options ───────────────────────────
                const Text(
                  'Event Service Add-ons',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                _switchTile(
                  title: 'Live Cooking Counters (Hot Dosa, Porotta & Grills)',
                  subtitle: 'Master chefs prep hot delicacies live at the event venue.',
                  value: _needLiveCounters,
                  onChanged: (v) => setState(() => _needLiveCounters = v),
                ),
                const SizedBox(height: 10),
                _switchTile(
                  title: 'Paragon Service Staff & Tableware',
                  subtitle: 'Uniformed catering crew, premium cutlery, and buffet setup.',
                  value: _needServiceStaff,
                  onChanged: (v) => setState(() => _needServiceStaff = v),
                ),
              ],
            ),

            // ── Persistent Proceed Button ────────────────────────────────────
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  elevation: 4,
                ),
                onPressed: _proceed,
                child: const Text(
                  'CONTINUE TO VENUE & CONFIRMATION',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.copper,
            activeTrackColor: AppColors.copper.withValues(alpha: 0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.pkg,
    required this.isSelected,
    required this.onTap,
  });

  final CateringPackage pkg;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentRed.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.accentRed : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.copper.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pkg.tag,
                    style: const TextStyle(
                      color: AppColors.copper,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Text(
                  '₹ ${pkg.pricePerPlate.toInt()} / Plate',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              pkg.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pkg.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: pkg.highlights.map((h) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check,
                          size: 12, color: Color(0xFF22C55E)),
                      const SizedBox(width: 4),
                      Text(
                        h,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

