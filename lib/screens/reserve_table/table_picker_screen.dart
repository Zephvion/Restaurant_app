import 'package:flutter/material.dart';

import '../../models/payment_method.dart';
import '../../routes/app_routes.dart';
import '../../state/reservation_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/payment_gateway_sheet.dart';
import 'reservation_booking_screen.dart' show BookingArgs;

/// A restaurant table configuration with capacity, shape, section, and availability.
class RestaurantTable {
  final int number;
  final int capacity;
  final String title;
  final String section;
  final bool isAvailable;
  final String description;
  final List<String> perks;

  const RestaurantTable({
    required this.number,
    required this.capacity,
    required this.title,
    required this.section,
    this.isAvailable = true,
    required this.description,
    required this.perks,
  });
}

/// 10/10 Floor Plan & Table Allocation System.
/// Highlights standalone tables containing the exact required seats (e.g. 4-seater tables for 4 guests).
/// Automatically switches to smart multi-table combination ONLY when no standalone matching tables are available.
class TablePickerScreen extends StatefulWidget {
  const TablePickerScreen({super.key});

  @override
  State<TablePickerScreen> createState() => _TablePickerScreenState();
}

class _TablePickerScreenState extends State<TablePickerScreen> {
  final Set<int> _selectedTables = {};

  static final List<RestaurantTable> _allTables = [
    // 2-Seaters
    const RestaurantTable(
      number: 1,
      capacity: 2,
      title: 'Cozy Window Booth 1',
      section: 'Window View',
      isAvailable: true,
      description: 'Intimate setting with panoramic city skyline view.',
      perks: ['Window View', 'Dim Lighting', 'Couples Favorite'],
    ),
    const RestaurantTable(
      number: 2,
      capacity: 2,
      title: 'Cozy Window Booth 2',
      section: 'Window View',
      isAvailable: true,
      description: 'Quiet romantic table next to the glass facade.',
      perks: ['Window View', 'Soft Ambience'],
    ),
    const RestaurantTable(
      number: 3,
      capacity: 2,
      title: 'Garden Terrace 1',
      section: 'Terrace Garden',
      isAvailable: true,
      description: 'Open-air balcony dining with fresh natural breeze.',
      perks: ['Outdoor', 'Garden View', 'Quiet Zone'],
    ),
    const RestaurantTable(
      number: 4,
      capacity: 2,
      title: 'Garden Terrace 2',
      section: 'Terrace Garden',
      isAvailable: true,
      description: 'Comfortable terrace booth overlooking landscaped gardens.',
      perks: ['Outdoor', 'Garden Breeze'],
    ),

    // 4-Seaters (With 4 chairs on all 4 sides)
    const RestaurantTable(
      number: 5,
      capacity: 4,
      title: 'Family Dining A',
      section: 'Main Dining Floor',
      isAvailable: true,
      description: 'Spacious central 4-seat booth with 4 comfortable dining chairs.',
      perks: ['4 Chairs', 'Central AC', 'Best for 4 Guests'],
    ),
    const RestaurantTable(
      number: 6,
      capacity: 4,
      title: 'Family Dining B',
      section: 'Main Dining Floor',
      isAvailable: true,
      description: '4-seater dining booth with high backrests and central view.',
      perks: ['4 Chairs', 'Central AC', 'Family Choice'],
    ),
    const RestaurantTable(
      number: 7,
      capacity: 4,
      title: 'Family Dining C',
      section: 'Main Dining Floor',
      isAvailable: true,
      description: '4-seat table with direct, easy access to buffet stations.',
      perks: ['4 Chairs', 'Buffet Access', 'Spacious Seating'],
    ),
    const RestaurantTable(
      number: 8,
      capacity: 4,
      title: 'Family Dining D',
      section: 'Main Dining Floor',
      isAvailable: true,
      description: 'Quiet 4-seat corner table offering pleasant semi-private dining.',
      perks: ['4 Chairs', 'Semi-Private', 'Central AC'],
    ),

    // 6-Seaters
    const RestaurantTable(
      number: 9,
      capacity: 6,
      title: 'Banquet Lounge 1',
      section: 'Central Lounge',
      isAvailable: true,
      description: 'Circular banquet table with 6 cushioned chairs for groups.',
      perks: ['6 Chairs', 'Round Table', 'Lounge Cushions'],
    ),
    const RestaurantTable(
      number: 10,
      capacity: 6,
      title: 'Banquet Lounge 2',
      section: 'Central Lounge',
      isAvailable: true,
      description: 'Premium circular 6-seat dining booth for celebrations.',
      perks: ['6 Chairs', 'Round Table', 'Celebration Setup'],
    ),

    // 8-10 Seaters / VIP
    const RestaurantTable(
      number: 11,
      capacity: 8,
      title: 'Royal VIP Suite',
      section: 'VIP Private Lounge',
      isAvailable: true,
      description: 'Dedicated private dining area with 8 VIP chairs and butler service.',
      perks: ['8 Chairs', 'Dedicated Waiter', 'VIP Cutlery'],
    ),
    const RestaurantTable(
      number: 12,
      capacity: 10,
      title: 'Grand Executive Table',
      section: 'Penthouse Hall',
      isAvailable: true,
      description: 'Expansive boardroom-style long table with 10 chairs for large parties.',
      perks: ['10 Chairs', 'Chef Specials', 'Private Hall'],
    ),
  ];

  BookingArgs get _args =>
      ModalRoute.of(context)!.settings.arguments as BookingArgs;

  /// Check if there is any available standalone table that directly fits the requested party size
  bool get _hasDirectStandaloneMatch {
    final guests = _args.seats;
    return _allTables.any(
      (t) => t.isAvailable && t.capacity >= guests && t.capacity <= guests + 1,
    );
  }

  /// Whether a specific table is a direct match for the user's guest count
  bool _isDirectMatch(RestaurantTable table) {
    final guests = _args.seats;
    return table.isAvailable && table.capacity >= guests && table.capacity <= guests + 1;
  }

  int get _totalSelectedCapacity {
    int cap = 0;
    for (final num in _selectedTables) {
      final t = _allTables.firstWhere((tbl) => tbl.number == num);
      cap += t.capacity;
    }
    return cap;
  }

  void _onTableTap(RestaurantTable table) {
    if (!table.isAvailable) {
      AppBanner.showError(context, 'Table #${table.number} is already reserved for this slot.');
      return;
    }

    _showTableDetailsModal(table);
  }

  void _showTableDetailsModal(RestaurantTable table) {
    final guestCount = _args.seats;
    final isSelected = _selectedTables.contains(table.number);
    final isDirectMatch = _isDirectMatch(table);
    final hasDirectAvailable = _hasDirectStandaloneMatch;

    // Combining logic is ONLY triggered if there are NO standalone matching tables available
    // or if the chosen table has fewer seats than guestCount and no standalone matching table exists
    RestaurantTable? combinableCandidate;
    final capacityShortfall = guestCount - table.capacity;
    if (capacityShortfall > 0 && !hasDirectAvailable) {
      combinableCandidate = _allTables.firstWhere(
        (t) => t.number != table.number && t.isAvailable && !_selectedTables.contains(t.number),
        orElse: () => table,
      );
      if (combinableCandidate.number == table.number) combinableCandidate = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.border, width: 1.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Table #${table.number} — ${table.title}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Section: ${table.section}',
                        style: const TextStyle(
                          color: AppColors.copper,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDirectMatch
                        ? AppColors.copper.withValues(alpha: 0.25)
                        : AppColors.maroon.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDirectMatch ? AppColors.copper : AppColors.maroon,
                    ),
                  ),
                  child: Text(
                    '${table.capacity} CHAIRS',
                    style: TextStyle(
                      color: isDirectMatch ? AppColors.copper : AppColors.accentRed,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Direct Fit Announcement for Standalone Tables
            if (isDirectMatch) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Color(0xFF22C55E), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Perfect Match! Standalone table with ${table.capacity} chairs for your $guestCount guests.',
                        style: const TextStyle(
                          color: Color(0xFF22C55E),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            Text(
              table.description,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: table.perks.map((p) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    p,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Multi-Table Combination (ONLY if no standalone matching table exists)
            if (!hasDirectAvailable && capacityShortfall > 0 && combinableCandidate != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.copper.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.copper.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome, color: AppColors.copper, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'No Single Matching Table Free — Combine Tables',
                          style: TextStyle(
                            color: AppColors.copper,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Combine Table #${table.number} (${table.capacity} seats) + Table #${combinableCandidate.number} (${combinableCandidate.capacity} seats) for a total of ${table.capacity + combinableCandidate.capacity} seats.',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, height: 1.3),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.copper,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.link, size: 16),
                      label: Text(
                        'COMBINE TABLE #${table.number} + #${combinableCandidate.number}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedTables.add(table.number);
                          _selectedTables.add(combinableCandidate!.number);
                        });
                        Navigator.of(ctx).pop();
                        AppBanner.showSuccess(
                          context,
                          'Combined Table #${table.number} & #${combinableCandidate.number} (${table.capacity + combinableCandidate.capacity} seats)!',
                          title: 'Tables Combined',
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Select / Unselect Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? AppColors.surfaceLight : AppColors.maroon,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                setState(() {
                  if (isSelected) {
                    _selectedTables.remove(table.number);
                  } else {
                    _selectedTables.add(table.number);
                  }
                });
                Navigator.of(ctx).pop();
              },
              child: Text(
                isSelected ? 'REMOVE TABLE #${table.number}' : 'SELECT TABLE #${table.number}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _proceedToPaymentAndConfirm() async {
    final args = _args;
    final tableListStr = _selectedTables.toList()..sort();
    final tableDisplay = tableListStr.map((t) => '#$t').join(' & ');

    // Open Payment Gateway for reservation deposit (₹200)
    PaymentGatewaySheet.show(
      context: context,
      amount: 200.0,
      selectedMethod: PaymentMethod(
        id: 'upi_gpay',
        title: 'Google Pay',
        kind: PaymentKind.upi,
        assetKind: 'gpay',
      ),
      onPaymentSuccess: (txnId, mode) async {
        await ReservationController.instance.createReservation(
          restaurant: args.restaurant,
          date: args.date,
          timeSlot: args.timeSlot,
          seats: args.seats,
          tableNumber: _selectedTables.first,
        );

        if (mounted) {
          AppBanner.showSuccess(
            context,
            'Table $tableDisplay booked successfully for ${args.seats} guests! Txn: $txnId',
            title: 'Reservation Confirmed',
          );
          Navigator.of(context).pushNamed(AppRoutes.reservationSuccess);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = _args;
    final totalCap = _totalSelectedCapacity;
    final isEnoughCapacity = totalCap >= args.seats;
    final hasDirectMatch = _hasDirectStandaloneMatch;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary, size: 20),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose Your Table',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${args.restaurant.name} · ${args.seats} Guests · ${args.timeSlot}',
                          style: const TextStyle(
                            color: AppColors.copper,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Dynamic Recommendation Banner ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: hasDirectMatch
                      ? AppColors.copper.withValues(alpha: 0.14)
                      : AppColors.maroon.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasDirectMatch
                        ? AppColors.copper.withValues(alpha: 0.4)
                        : AppColors.maroon.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasDirectMatch ? Icons.stars_rounded : Icons.info_outline,
                      color: hasDirectMatch ? AppColors.copper : AppColors.accentRed,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        hasDirectMatch
                            ? 'Highlighted standalone ${args.seats}-seat tables below are ready for your party.'
                            : 'No single ${args.seats}-seat table is free. Tap tables to combine adjacent seats.',
                        style: TextStyle(
                          color: hasDirectMatch ? AppColors.textPrimary : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Capacity Category Filter / Legend ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _legendItem(AppColors.copper, 'Best Match (${args.seats}P)'),
                    _legendItem(const Color(0xFF22C55E), 'Available'),
                    _legendItem(AppColors.hint, 'Occupied'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Interactive Floor Plan ──────────────────────────────────
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.86,
                ),
                itemCount: _allTables.length,
                itemBuilder: (context, i) {
                  final table = _allTables[i];
                  final isSelected = _selectedTables.contains(table.number);
                  final isBestMatch = _isDirectMatch(table);

                  return _InteractiveTableTile(
                    table: table,
                    isSelected: isSelected,
                    isBestMatch: isBestMatch,
                    onTap: () => _onTableTap(table),
                  );
                },
              ),
            ),

            // ── Selected Summary Bar & Confirm Button ───────────────────
            if (_selectedTables.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: const Border(top: BorderSide(color: AppColors.border)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Table ${_selectedTables.map((n) => "#$n").join(" & ")}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Capacity: $totalCap seats (For ${args.seats} guests)',
                              style: TextStyle(
                                color: isEnoughCapacity ? const Color(0xFF22C55E) : AppColors.accentRed,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.copper.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Deposit: ₹200',
                            style: TextStyle(
                              color: AppColors.copper,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentRed,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _proceedToPaymentAndConfirm,
                      child: const Text(
                        'CONFIRM & PROCEED TO PAYMENT (₹200)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 1.1,
                        ),
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

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// An interactive graphical table widget showing realistic chairs around perimeter.
class _InteractiveTableTile extends StatelessWidget {
  const _InteractiveTableTile({
    required this.table,
    required this.isSelected,
    required this.isBestMatch,
    required this.onTap,
  });

  final RestaurantTable table;
  final bool isSelected;
  final bool isBestMatch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    if (isSelected) {
      borderColor = AppColors.copper;
    } else if (isBestMatch) {
      borderColor = AppColors.copper.withValues(alpha: 0.7);
    } else if (table.isAvailable) {
      borderColor = AppColors.border;
    } else {
      borderColor = AppColors.hint.withValues(alpha: 0.3);
    }

    Color bgColor;
    if (isSelected) {
      bgColor = AppColors.copper.withValues(alpha: 0.22);
    } else if (isBestMatch) {
      bgColor = AppColors.copper.withValues(alpha: 0.08);
    } else {
      bgColor = AppColors.surface;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.2 : (isBestMatch ? 1.6 : 1),
          ),
          boxShadow: isBestMatch || isSelected
              ? [
                  BoxShadow(
                    color: AppColors.copper.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Graphical chairs around table perimeter
            _buildChairsVisual(table.capacity, isSelected || isBestMatch),

            // Inner Table Surface
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: table.capacity >= 6 ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: table.capacity >= 6 ? BorderRadius.circular(12) : null,
                color: isSelected
                    ? AppColors.copper
                    : (isBestMatch ? AppColors.copper.withValues(alpha: 0.3) : AppColors.surfaceLight),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'T-${table.number}',
                    style: TextStyle(
                      color: isSelected ? Colors.black : AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${table.capacity} Chairs',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.black87
                          : (isBestMatch ? AppColors.copper : AppColors.textSecondary),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Top check indicator if selected or match badge
            if (isSelected)
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(Icons.check_circle, size: 16, color: AppColors.copper),
              )
            else if (isBestMatch)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.copper,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'MATCH',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChairsVisual(int capacity, bool isHighlighted) {
    final chairColor = isHighlighted
        ? AppColors.copper
        : AppColors.hint.withValues(alpha: 0.5);

    if (capacity == 2) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _chairDot(chairColor, horizontal: true),
          const Spacer(),
          _chairDot(chairColor, horizontal: true),
        ],
      );
    } else if (capacity == 4) {
      // 4 distinct chairs around table (Top, Bottom, Left, Right)
      return Stack(
        children: [
          Align(alignment: Alignment.topCenter, child: _chairDot(chairColor, horizontal: true)),
          Align(alignment: Alignment.bottomCenter, child: _chairDot(chairColor, horizontal: true)),
          Align(alignment: Alignment.centerLeft, child: _chairDot(chairColor, horizontal: false)),
          Align(alignment: Alignment.centerRight, child: _chairDot(chairColor, horizontal: false)),
        ],
      );
    } else {
      // 6 or 8+ chairs surrounding table
      return Stack(
        children: [
          Align(alignment: Alignment.topCenter, child: _chairDot(chairColor, horizontal: true)),
          Align(alignment: Alignment.bottomCenter, child: _chairDot(chairColor, horizontal: true)),
          Align(alignment: Alignment.centerLeft, child: _chairDot(chairColor, horizontal: false)),
          Align(alignment: Alignment.centerRight, child: _chairDot(chairColor, horizontal: false)),
          Align(alignment: Alignment.topLeft, child: _chairDot(chairColor, isSmall: true)),
          Align(alignment: Alignment.topRight, child: _chairDot(chairColor, isSmall: true)),
          Align(alignment: Alignment.bottomLeft, child: _chairDot(chairColor, isSmall: true)),
          Align(alignment: Alignment.bottomRight, child: _chairDot(chairColor, isSmall: true)),
        ],
      );
    }
  }

  Widget _chairDot(Color color, {bool horizontal = false, bool isSmall = false}) {
    return Container(
      margin: const EdgeInsets.all(4),
      width: isSmall ? 8 : (horizontal ? 18 : 6),
      height: isSmall ? 8 : (horizontal ? 6 : 18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
