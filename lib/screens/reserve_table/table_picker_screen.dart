import 'dart:async';
import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/table_lock_service.dart';
import '../../state/reservation_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
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

/// Dynamic Table Allocation Tiers based on requested party size and real-time inventory.
enum TableAllocationTier {
  /// Standalone exact match for requested seats (e.g. 2-seater for 2 guests, 4-seater for 3-4 guests).
  perfectMatch,

  /// Acceptable seating within +2 chairs buffer (e.g. 4-seater for 2 guests).
  acceptable,

  /// Overcapacity large table (6-12 seats) while suitable 2-4 seaters are currently available.
  /// Blocked from casual selection to prevent massive seat wastage.
  groupReserved,

  /// Overcapacity large table that is DYNAMICALLY UNLOCKED as a complimentary upgrade
  /// because all 2-4 seaters are booked/locked for this dining slot.
  courtesyUpgrade,

  /// Table has fewer seats than party size (e.g. 2-seater when party is 4).
  underCapacity,
}

/// 10/10 Floor Plan, Dynamic Smart Priority Allocation, and Race-Condition Table Locking System.
/// - Highlights standalone tables containing the exact required seats (e.g. 2-seater for 2 guests).
/// - Dynamic Smart Allocation: Blocks 6-12 seaters for small parties when 2-4 seaters are available.
/// - Courtesy Upgrade: Automatically unlocks 12-seaters as complimentary upgrades if smaller tables are full.
/// - 5-Minute Exclusive Hold Lock with automatic countdown timer and queue auto-transfer upon expiry.
/// - 100% Free Table Reservations (No payment deposit required).
class TablePickerScreen extends StatefulWidget {
  const TablePickerScreen({super.key});

  @override
  State<TablePickerScreen> createState() => _TablePickerScreenState();
}

class _TablePickerScreenState extends State<TablePickerScreen> {
  final Set<int> _selectedTables = {};
  bool _isSubmitting = false;
  StreamSubscription<String>? _lockNotificationSub;

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
      capacity: 12,
      title: 'Grand Executive Banquet',
      section: 'Penthouse Hall',
      isAvailable: true,
      description: 'Expansive banquet-style long table with 12 chairs for large celebrations and gatherings.',
      perks: ['12 Chairs', 'Chef Specials', 'Private Hall'],
    ),
  ];

  BookingArgs get _args =>
      ModalRoute.of(context)!.settings.arguments as BookingArgs;

  @override
  void initState() {
    super.initState();
    _lockNotificationSub = TableLockService.instance.notifications.listen((msg) {
      if (mounted) {
        AppBanner.showSuccess(context, msg, title: 'Table Update');
      }
    });
  }

  @override
  void dispose() {
    _lockNotificationSub?.cancel();
    super.dispose();
  }

  /// Evaluates real-time allocation tier for a table given the requested guest count.
  TableAllocationTier _getTableTier(RestaurantTable table) {
    final guests = _args.seats;
    final lockService = TableLockService.instance;

    // Check if table has fewer seats than the party (e.g. 2-seater for 4 guests)
    if (table.capacity < guests) {
      return TableAllocationTier.underCapacity;
    }

    // Exact match: table directly accommodates party without seat waste (capacity <= guests + 1)
    if (table.capacity <= guests + 1) {
      return TableAllocationTier.perfectMatch;
    }

    // Acceptable buffer: slight excess of +2 seats (e.g. 4-seater for 2 guests)
    if (table.capacity <= guests + 2) {
      return TableAllocationTier.acceptable;
    }

    // Large table (capacity > guests + 2, e.g. 6, 8, 12 seats for 2 guests):
    // Check if any suitable smaller table (perfect match or acceptable buffer) is currently available
    final hasSuitableSmallerTable = _allTables.any((t) {
      if (t.number == table.number) return false;
      final isOccupied = lockService.isTableReserved(t.number) ||
          lockService.isTableHeldByOther(t.number) ||
          !t.isAvailable;
      if (isOccupied) return false;
      return t.capacity >= guests && t.capacity <= guests + 2;
    });

    if (hasSuitableSmallerTable) {
      // Suitable 2-4 seaters exist -> Protect large 6-12 seat table from small party
      return TableAllocationTier.groupReserved;
    } else {
      // All 2-4 seaters are booked or held -> Dynamically unlock as complimentary upgrade!
      return TableAllocationTier.courtesyUpgrade;
    }
  }

  /// Whether a specific table is a direct match for the user's guest count
  bool _isDirectMatch(RestaurantTable table) {
    return _getTableTier(table) == TableAllocationTier.perfectMatch;
  }

  /// Check if there is any available standalone table that directly fits the requested party size
  bool get _hasDirectStandaloneMatch {
    final guests = _args.seats;
    final lockService = TableLockService.instance;
    return _allTables.any(
      (t) =>
          t.isAvailable &&
          !lockService.isTableReserved(t.number) &&
          !lockService.isTableHeldByOther(t.number) &&
          t.capacity >= guests &&
          t.capacity <= guests + 1,
    );
  }

  /// Best available smaller table recommended for this guest party
  RestaurantTable? get _bestAvailableSmallerTable {
    final guests = _args.seats;
    final lockService = TableLockService.instance;
    return _allTables.where((t) =>
        t.isAvailable &&
        !lockService.isTableReserved(t.number) &&
        !lockService.isTableHeldByOther(t.number) &&
        t.capacity >= guests &&
        t.capacity <= guests + 1
    ).firstOrNull ?? _allTables.where((t) =>
        t.isAvailable &&
        !lockService.isTableReserved(t.number) &&
        !lockService.isTableHeldByOther(t.number) &&
        t.capacity >= guests &&
        t.capacity <= guests + 2
    ).firstOrNull;
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
    final lockService = TableLockService.instance;

    // Check if table is permanently reserved
    if (lockService.isTableReserved(table.number) || !table.isAvailable) {
      _showReservedTableModal(table);
      return;
    }

    // Check if table is currently locked by another person
    if (lockService.isTableHeldByOther(table.number)) {
      _showLockedConflictModal(table);
      return;
    }

    // Toggle off if already selected
    if (_selectedTables.contains(table.number)) {
      setState(() {
        _selectedTables.remove(table.number);
        lockService.releaseLock(table.number);
      });
      return;
    }

    // Evaluate allocation tier
    final tier = _getTableTier(table);

    // ── 1. Group Reserved Guard (Blocks 2 people from taking 12-seater when small tables exist) ──
    if (tier == TableAllocationTier.groupReserved) {
      _showGroupTableRestrictedModal(table);
      return;
    }

    // ── 2. Courtesy Upgrade (All smaller tables are booked!) ──
    if (tier == TableAllocationTier.courtesyUpgrade) {
      _showCourtesyUpgradeModal(table);
      return;
    }

    // ── 3. Under-capacity Guard (e.g. 2-seater clicked for 4 guests when standalone 4-seaters exist) ──
    if (tier == TableAllocationTier.underCapacity && _hasDirectStandaloneMatch) {
      _showUnderCapacityWarningModal(table);
      return;
    }

    // ── 4. Seat-cap guard: prevent selecting more tables than needed ────────────
    if (_totalSelectedCapacity >= _args.seats) {
      AppBanner.showError(
        context,
        'You already have enough seats ($_totalSelectedCapacity) for ${_args.seats} guests. '
        'Deselect a table first to swap it.',
        title: 'Seat Limit Reached',
      );
      return;
    }

    // Acquire lock and select
    final result = lockService.acquireLock(table.number);
    if (result.isSuccess) {
      setState(() {
        _selectedTables.add(table.number);
      });
    } else {
      _showLockedConflictModal(table);
    }
  }

  void _showReservedTableModal(RestaurantTable table) {
    showModalBottomSheet(
      context: context,
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
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.table_restaurant, color: AppColors.accentRed, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Table #${table.number} (${table.title})',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Currently Reserved / Occupied',
                        style: TextStyle(
                          color: AppColors.accentRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'This table is currently reserved for this dining slot. Please select another available table or combine adjacent tables to accommodate your party.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'OK, Got It',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLockedConflictModal(RestaurantTable table) {
    final lock = TableLockService.instance.getLock(table.number);
    final isQueued = lock.waitlist.any(
      (w) => w.userId == TableLockService.instance.activeUserId,
    );
    final queuePos = lock.waitlist.indexWhere(
          (w) => w.userId == TableLockService.instance.activeUserId,
        ) +
        1;

    showModalBottomSheet(
      context: context,
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
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_clock, color: Color(0xFFF59E0B), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Table #${table.number} is Temporarily Held',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Held by ${lock.holderUserName ?? "another guest"} (5-min reservation hold)',
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
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Color(0xFFF59E0B), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Remaining Hold Countdown',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                        Text(
                          '${lock.remainingFormatted} before lock expires',
                          style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'If the guest completes the booking, the table will be confirmed. If they abandon or timeout after 5 minutes, it automatically transfers to the next person in line.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 20),
            if (!isQueued) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.queue_play_next, size: 18),
                label: Text(
                  'JOIN PRIORITY WAITLIST (POSITION #${lock.waitlist.length + 1})',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
                onPressed: () {
                  TableLockService.instance.joinWaitlist(table.number);
                  Navigator.of(ctx).pop();
                  AppBanner.showSuccess(
                    context,
                    'You are in the priority waitlist for Table #${table.number}. If released, it will auto-assign to you!',
                    title: 'Waitlist Joined',
                  );
                },
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF22C55E)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'You are in position #$queuePos in the Priority Queue.',
                      style: const TextStyle(
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showGroupTableRestrictedModal(RestaurantTable table) {
    final bestTable = _bestAvailableSmallerTable;
    final guests = _args.seats;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Icon(Icons.groups_rounded,
                      color: Color(0xFFF59E0B), size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Table #${table.number} (${table.title})',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Reserved for Large Dining Parties (6+ Guests)',
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'This large table features ${table.capacity} chairs and is reserved for groups of 6 or more guests.\n\n'
                'To ensure fair seating for everyone, we kindly request small parties of $guests to select our dedicated cozy tables, which are open for you right now.',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13, height: 1.45),
              ),
            ),
            const SizedBox(height: 18),
            if (bestTable != null) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.copper,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: Text(
                  'SWITCH TO TABLE #${bestTable.number} (${bestTable.capacity} SEATS)',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.5),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  final lockService = TableLockService.instance;
                  final res = lockService.acquireLock(bestTable.number);
                  if (res.isSuccess) {
                    setState(() {
                      _selectedTables.clear();
                      _selectedTables.add(bestTable.number);
                    });
                    AppBanner.showSuccess(
                      context,
                      'Selected Table #${bestTable.number} (${bestTable.title}) for your party of $guests!',
                      title: 'Optimal Table Selected',
                    );
                  } else {
                    _showLockedConflictModal(bestTable);
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Browse Other Tables',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCourtesyUpgradeModal(RestaurantTable table) {
    final guests = _args.seats;
    final lockService = TableLockService.instance;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.copper.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.copper),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded,
                      color: AppColors.copper, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Complimentary Table Upgrade!',
                        style: TextStyle(
                          color: AppColors.copper,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Table #${table.number} · ${table.capacity} Seats Unlocked',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppColors.copper.withValues(alpha: 0.3)),
              ),
              child: Text(
                'All standard 2-seat and 4-seat tables are currently reserved for this dining slot.\n\n'
                'As our special courtesy, Table #${table.number} (${table.capacity} seats) in the ${table.section} has been unlocked for your party of $guests at no extra charge!',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13, height: 1.45),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.copper,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                final res = lockService.acquireLock(table.number);
                if (res.isSuccess) {
                  setState(() {
                    _selectedTables.clear();
                    _selectedTables.add(table.number);
                  });
                  AppBanner.showSuccess(
                    context,
                    'Courtesy upgrade applied! Table #${table.number} reserved for your party.',
                    title: 'Upgrade Confirmed',
                  );
                } else {
                  _showLockedConflictModal(table);
                }
              },
              child: Text(
                'ACCEPT UPGRADE & RESERVE TABLE #${table.number}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnderCapacityWarningModal(RestaurantTable table) {
    final guests = _args.seats;
    final bestTable = _bestAvailableSmallerTable;

    showModalBottomSheet(
      context: context,
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
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: AppColors.accentRed, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Table #${table.number} has only ${table.capacity} seats',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your party has $guests guests',
                        style: const TextStyle(
                          color: AppColors.accentRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'A single $guests-seat standalone table is already available for you. '
                'Please select a table with at least $guests chairs so everyone can be comfortably seated.',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
            if (bestTable != null) ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.copper,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  final lockService = TableLockService.instance;
                  final res = lockService.acquireLock(bestTable.number);
                  if (res.isSuccess) {
                    setState(() {
                      _selectedTables.clear();
                      _selectedTables.add(bestTable.number);
                    });
                    AppBanner.showSuccess(
                      context,
                      'Selected Table #${bestTable.number} (${bestTable.title}) for your party of $guests!',
                      title: 'Table Selected',
                    );
                  }
                },
                child: Text(
                  'SELECT TABLE #${bestTable.number} (${bestTable.capacity} SEATS)',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 10),
            ],
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK, Got It',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  void _showTableDetailsModal(RestaurantTable table) {
    final guestCount = _args.seats;
    final isSelected = _selectedTables.contains(table.number);
    final isDirectMatch = _isDirectMatch(table);
    final hasDirectAvailable = _hasDirectStandaloneMatch;

    RestaurantTable? combinableCandidate;
    final capacityShortfall = guestCount - table.capacity;
    if (capacityShortfall > 0 && !hasDirectAvailable) {
      final availableCandidates = _allTables.where(
        (t) => t.number != table.number && t.isAvailable && !_selectedTables.contains(t.number),
      );
      // Prefer candidate that meets or exceeds the shortfall
      combinableCandidate = availableCandidates.where((t) => t.capacity >= capacityShortfall).firstOrNull ??
          availableCandidates.firstOrNull;
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

            // 5-Min Hold Notice
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  const Icon(Icons.timer, color: Color(0xFF22C55E), size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '5-Minute Exclusive Hold Active for you. Free reservation!',
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (isDirectMatch) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.copper.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.copper.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.copper, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Perfect Match! Standalone table with ${table.capacity} chairs for your $guestCount guests.',
                        style: const TextStyle(
                          color: AppColors.copper,
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
              Builder(
                builder: (context) {
                  final cand = combinableCandidate!;
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.copper.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.copper.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
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
                          'Combine Table #${table.number} (${table.capacity} seats) + Table #${cand.number} (${cand.capacity} seats) for a total of ${table.capacity + cand.capacity} seats.',
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
                            'COMBINE TABLE #${table.number} + #${cand.number}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedTables.add(table.number);
                              _selectedTables.add(cand.number);
                            });
                            TableLockService.instance.acquireLock(table.number);
                            TableLockService.instance.acquireLock(cand.number);
                            Navigator.of(ctx).pop();
                            AppBanner.showSuccess(
                              context,
                              'Combined Table #${table.number} & #${cand.number} (${table.capacity + cand.capacity} seats)!',
                              title: 'Tables Combined',
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
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
                if (!isSelected) {
                  final tier = _getTableTier(table);
                  if (tier == TableAllocationTier.groupReserved) {
                    Navigator.of(ctx).pop();
                    _showGroupTableRestrictedModal(table);
                    return;
                  }
                  if (tier == TableAllocationTier.courtesyUpgrade) {
                    Navigator.of(ctx).pop();
                    _showCourtesyUpgradeModal(table);
                    return;
                  }
                  if (tier == TableAllocationTier.underCapacity && _hasDirectStandaloneMatch) {
                    Navigator.of(ctx).pop();
                    _showUnderCapacityWarningModal(table);
                    return;
                  }
                  if (_totalSelectedCapacity >= _args.seats) {
                    // Seat cap reached — block and inform
                    Navigator.of(ctx).pop();
                    AppBanner.showError(
                      context,
                      'You already have enough seats ($_totalSelectedCapacity) for ${_args.seats} guests. '
                      'Deselect a table first to swap it.',
                      title: 'Seat Limit Reached',
                    );
                    return;
                  }
                }
                setState(() {
                  if (isSelected) {
                    _selectedTables.remove(table.number);
                    TableLockService.instance.releaseLock(table.number);
                  } else {
                    _selectedTables.add(table.number);
                    TableLockService.instance.acquireLock(table.number);
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

  Future<void> _confirmReservation() async {
    if (_isSubmitting || _selectedTables.isEmpty) return;
    setState(() => _isSubmitting = true);

    try {
      final args = _args;
      final tableListStr = _selectedTables.toList()..sort();
      final tableDisplay = tableListStr.map((t) => '#$t').join(' & ');

      // 100% Free Table Reservation — No payment required
      await ReservationController.instance.createReservation(
        restaurant: args.restaurant,
        date: args.date,
        timeSlot: args.timeSlot,
        seats: args.seats,
        tableNumber: _selectedTables.first,
        tableNumbers: tableListStr,
      );

      // Commit locks for all selected tables
      for (final num in _selectedTables) {
        TableLockService.instance.commitReservation(num);
      }

      if (mounted) {
        AppBanner.showSuccess(
          context,
          'Table $tableDisplay confirmed for ${args.seats} guests!',
          title: 'Reservation Confirmed',
        );
        // Direct clean redirect to Reserve Dashboard where the reservation is displayed
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.reserveDashboard,
          (route) => route.settings.name == AppRoutes.home || route.isFirst,
        );
      }
    } catch (e) {
      debugPrint('Error confirming table reservation: $e');
      if (mounted) {
        AppBanner.showError(
          context,
          'Could not complete reservation. Please try again.',
          title: 'Reservation Error',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = _args;
    final totalCap = _totalSelectedCapacity;
    final isEnoughCapacity = totalCap >= args.seats;
    final hasDirectMatch = _hasDirectStandaloneMatch;

    return AnimatedBuilder(
      animation: TableLockService.instance,
      builder: (context, _) {
        final lockService = TableLockService.instance;
        final isHoldingAny = _selectedTables.isNotEmpty;
        final primaryHoldLock = _selectedTables.isNotEmpty
            ? lockService.getLock(_selectedTables.first)
            : null;

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
                const SizedBox(height: 8),

                // ── Active Reservation Banner (if user already booked) ──────
                AnimatedBuilder(
                  animation: ReservationController.instance,
                  builder: (context, _) {
                    final existing = ReservationController.instance.reservations;
                    if (existing.isEmpty) return const SizedBox.shrink();
                    final latest = existing.first;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Active Booking: Table #${latest.tableNumber}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${latest.formattedDate} · ${latest.timeSlot} · ${latest.seats} Guests',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'RESERVED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // ── Active Hold Countdown Banner (if table selected) ───────
                if (isHoldingAny && primaryHoldLock != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF22C55E)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.hourglass_bottom, color: Color(0xFF22C55E), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Table held for you! Complete in: ${primaryHoldLock.remainingFormatted}',
                              style: const TextStyle(
                                color: Color(0xFF22C55E),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // ── Recommendation Banner ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Builder(
                    builder: (context) {
                      final hasCourtesyUpgrade = _allTables.any(
                        (t) => _getTableTier(t) == TableAllocationTier.courtesyUpgrade,
                      );

                      Color bannerBg;
                      Color bannerBorder;
                      IconData bannerIcon;
                      Color bannerIconColor;
                      String bannerText;

                      if (hasCourtesyUpgrade) {
                        bannerBg = const Color(0xFFEAB308).withValues(alpha: 0.12);
                        bannerBorder = const Color(0xFFEAB308).withValues(alpha: 0.4);
                        bannerIcon = Icons.auto_awesome_rounded;
                        bannerIconColor = const Color(0xFFEAB308);
                        bannerText =
                            'Courtesy Upgrade Unlocked: All ${args.seats}-seat tables are booked, so large group tables are open for your party!';
                      } else if (hasDirectMatch) {
                        bannerBg = AppColors.copper.withValues(alpha: 0.12);
                        bannerBorder = AppColors.copper.withValues(alpha: 0.3);
                        bannerIcon = Icons.stars_rounded;
                        bannerIconColor = AppColors.copper;
                        bannerText =
                            'Dedicated ${args.seats}-seat tables are highlighted. Group tables (6–12 seats) are reserved for larger parties.';
                      } else {
                        bannerBg = AppColors.maroon.withValues(alpha: 0.12);
                        bannerBorder = AppColors.maroon.withValues(alpha: 0.3);
                        bannerIcon = Icons.info_outline;
                        bannerIconColor = AppColors.accentRed;
                        bannerText =
                            'No single ${args.seats}-seat table is free. Tap tables to combine adjacent seats.';
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: bannerBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: bannerBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(bannerIcon, color: bannerIconColor, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                bannerText,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // ── Legend ───────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _legendItem(AppColors.copper, 'Perfect (${args.seats}P)'),
                          const SizedBox(width: 10),
                          _legendItem(const Color(0xFF22C55E), 'Available'),
                          const SizedBox(width: 10),
                          _legendItem(AppColors.hint, 'Group (6+P)'),
                          const SizedBox(width: 10),
                          _legendItem(const Color(0xFFEAB308), 'Upgrade'),
                          const SizedBox(width: 10),
                          _legendItem(const Color(0xFFF59E0B), 'Held'),
                          const SizedBox(width: 10),
                          _legendItem(AppColors.hint.withValues(alpha: 0.4), 'Booked'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Interactive Floor Plan ──────────────────────────────────
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.84,
                    ),
                    itemCount: _allTables.length,
                    itemBuilder: (context, i) {
                      final table = _allTables[i];
                      final isSelected = _selectedTables.contains(table.number);
                      final isBestMatch = _isDirectMatch(table);
                      final isHeldByOther = lockService.isTableHeldByOther(table.number);
                      final isReserved = lockService.isTableReserved(table.number);
                      final lock = lockService.getLock(table.number);
                      final tier = _getTableTier(table);

                      return _InteractiveTableTile(
                        table: table,
                        tier: tier,
                        isSelected: isSelected,
                        isBestMatch: isBestMatch,
                        isHeldByOther: isHeldByOther,
                        isReserved: isReserved,
                        remainingLockText: isHeldByOther ? lock.remainingFormatted : null,
                        onTap: () => _onTableTap(table),
                        onLongPress: () => _showTableDetailsModal(table),
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
                                color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Free Booking',
                                style: TextStyle(
                                  color: Color(0xFF22C55E),
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
                            backgroundColor: _isSubmitting
                                ? AppColors.accentRed.withValues(alpha: 0.6)
                                : AppColors.accentRed,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: _isSubmitting ? null : _confirmReservation,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  isEnoughCapacity
                                      ? 'CONFIRM TABLE RESERVATION'
                                      : 'CONFIRM TABLE #${_selectedTables.join(' & ')} ($totalCap/${args.seats} SEATS)',
                                  style: const TextStyle(
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
      },
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// An interactive graphical table widget showing realistic chairs around perimeter.
class _InteractiveTableTile extends StatelessWidget {
  const _InteractiveTableTile({
    required this.table,
    required this.tier,
    required this.isSelected,
    required this.isBestMatch,
    required this.isHeldByOther,
    required this.isReserved,
    this.remainingLockText,
    required this.onTap,
    this.onLongPress,
  });

  final RestaurantTable table;
  final TableAllocationTier tier;
  final bool isSelected;
  final bool isBestMatch;
  final bool isHeldByOther;
  final bool isReserved;
  final String? remainingLockText;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    Color chairColor;

    if (isSelected) {
      borderColor = AppColors.copper;
      bgColor = AppColors.copper.withValues(alpha: 0.22);
      chairColor = AppColors.copper;
    } else if (isHeldByOther) {
      borderColor = const Color(0xFFF59E0B);
      bgColor = const Color(0xFFF59E0B).withValues(alpha: 0.15);
      chairColor = const Color(0xFFF59E0B);
    } else if (isReserved) {
      borderColor = AppColors.hint.withValues(alpha: 0.25);
      bgColor = AppColors.backgroundElevated;
      chairColor = AppColors.hint.withValues(alpha: 0.25);
    } else {
      switch (tier) {
        case TableAllocationTier.courtesyUpgrade:
          borderColor = const Color(0xFFEAB308);
          bgColor = const Color(0xFFEAB308).withValues(alpha: 0.12);
          chairColor = const Color(0xFFEAB308);
          break;
        case TableAllocationTier.perfectMatch:
          borderColor = AppColors.copper.withValues(alpha: 0.9);
          bgColor = AppColors.copper.withValues(alpha: 0.12);
          chairColor = AppColors.copper;
          break;
        case TableAllocationTier.acceptable:
          borderColor = const Color(0xFF22C55E).withValues(alpha: 0.7);
          bgColor = const Color(0xFF22C55E).withValues(alpha: 0.08);
          chairColor = const Color(0xFF22C55E);
          break;
        case TableAllocationTier.groupReserved:
          borderColor = AppColors.border.withValues(alpha: 0.4);
          bgColor = AppColors.surface.withValues(alpha: 0.5);
          chairColor = AppColors.hint.withValues(alpha: 0.35);
          break;
        case TableAllocationTier.underCapacity:
          borderColor = AppColors.border.withValues(alpha: 0.5);
          bgColor = AppColors.surface.withValues(alpha: 0.6);
          chairColor = AppColors.hint.withValues(alpha: 0.4);
          break;
      }
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : (tier == TableAllocationTier.courtesyUpgrade ? 1.8 : 1.2),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.copper.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : (tier == TableAllocationTier.courtesyUpgrade && !isReserved
                  ? [
                      BoxShadow(
                        color: const Color(0xFFEAB308).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Physical Chairs around table
            _buildChairsLayout(table.capacity, chairColor),

            // Table Center Surface
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'T-${table.number}',
                  style: TextStyle(
                    color: isReserved ? AppColors.hint : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tier == TableAllocationTier.groupReserved && !isReserved
                      ? '${table.capacity} Seats (6+)'
                      : '${table.capacity} Seats',
                  style: TextStyle(
                    color: isHeldByOther
                        ? const Color(0xFFF59E0B)
                        : (tier == TableAllocationTier.courtesyUpgrade && !isReserved
                            ? const Color(0xFFEAB308)
                            : (isBestMatch ? AppColors.copper : AppColors.textSecondary)),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isHeldByOther && remainingLockText != null) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '🔒 $remainingLockText',
                      style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Match / Held / Booked / Upgrade Badge
            _buildBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    if (isReserved) {
      return Positioned(
        top: 4,
        right: 4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.hint.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'BOOKED',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    if (isHeldByOther) {
      return Positioned(
        top: 4,
        right: 4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'HELD',
            style: TextStyle(
              color: Colors.black,
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }

    if (isSelected) {
      return Positioned(
        top: 4,
        right: 4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.copper,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'SELECTED',
            style: TextStyle(
              color: Colors.black,
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }

    switch (tier) {
      case TableAllocationTier.courtesyUpgrade:
        return Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xFFEAB308),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '⭐ UPGRADE',
              style: TextStyle(
                color: Colors.black,
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      case TableAllocationTier.perfectMatch:
        return Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.copper,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'PERFECT (${table.capacity}P)',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      case TableAllocationTier.groupReserved:
        return Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.hint.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'GROUP (${table.capacity}P)',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      case TableAllocationTier.acceptable:
        return Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'AVAILABLE',
              style: TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 7.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      case TableAllocationTier.underCapacity:
        return Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.hint.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${table.capacity}P',
              style: const TextStyle(
                color: AppColors.hint,
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
    }
  }

  Widget _buildChairsLayout(int capacity, Color color) {
    if (capacity == 2) {
      return Stack(
        children: [
          Align(alignment: Alignment.topCenter, child: _chair(color, isHorizontal: true, width: 14)),
          Align(alignment: Alignment.bottomCenter, child: _chair(color, isHorizontal: true, width: 14)),
        ],
      );
    } else if (capacity == 4) {
      return Stack(
        children: [
          Align(alignment: Alignment.topCenter, child: _chair(color, isHorizontal: true, width: 14)),
          Align(alignment: Alignment.bottomCenter, child: _chair(color, isHorizontal: true, width: 14)),
          Align(alignment: Alignment.centerLeft, child: _chair(color, isHorizontal: false, height: 14)),
          Align(alignment: Alignment.centerRight, child: _chair(color, isHorizontal: false, height: 14)),
        ],
      );
    } else if (capacity == 6) {
      return Stack(
        children: [
          Align(alignment: const Alignment(-0.5, -1.0), child: _chair(color, isHorizontal: true, width: 13)),
          Align(alignment: const Alignment(0.5, -1.0), child: _chair(color, isHorizontal: true, width: 13)),
          Align(alignment: const Alignment(-0.5, 1.0), child: _chair(color, isHorizontal: true, width: 13)),
          Align(alignment: const Alignment(0.5, 1.0), child: _chair(color, isHorizontal: true, width: 13)),
          Align(alignment: Alignment.centerLeft, child: _chair(color, isHorizontal: false, height: 14)),
          Align(alignment: Alignment.centerRight, child: _chair(color, isHorizontal: false, height: 14)),
        ],
      );
    } else if (capacity == 8) {
      return Stack(
        children: [
          Align(alignment: const Alignment(-0.65, -1.0), child: _chair(color, isHorizontal: true, width: 11)),
          Align(alignment: const Alignment(0.0, -1.0), child: _chair(color, isHorizontal: true, width: 11)),
          Align(alignment: const Alignment(0.65, -1.0), child: _chair(color, isHorizontal: true, width: 11)),
          Align(alignment: const Alignment(-0.65, 1.0), child: _chair(color, isHorizontal: true, width: 11)),
          Align(alignment: const Alignment(0.0, 1.0), child: _chair(color, isHorizontal: true, width: 11)),
          Align(alignment: const Alignment(0.65, 1.0), child: _chair(color, isHorizontal: true, width: 11)),
          Align(alignment: Alignment.centerLeft, child: _chair(color, isHorizontal: false, height: 13)),
          Align(alignment: Alignment.centerRight, child: _chair(color, isHorizontal: false, height: 13)),
        ],
      );
    } else if (capacity == 10) {
      return Stack(
        children: [
          Align(alignment: const Alignment(-0.75, -1.0), child: _chair(color, isHorizontal: true, width: 9)),
          Align(alignment: const Alignment(-0.25, -1.0), child: _chair(color, isHorizontal: true, width: 9)),
          Align(alignment: const Alignment(0.25, -1.0), child: _chair(color, isHorizontal: true, width: 9)),
          Align(alignment: const Alignment(0.75, -1.0), child: _chair(color, isHorizontal: true, width: 9)),
          Align(alignment: const Alignment(-0.75, 1.0), child: _chair(color, isHorizontal: true, width: 9)),
          Align(alignment: const Alignment(-0.25, 1.0), child: _chair(color, isHorizontal: true, width: 9)),
          Align(alignment: const Alignment(0.25, 1.0), child: _chair(color, isHorizontal: true, width: 9)),
          Align(alignment: const Alignment(0.75, 1.0), child: _chair(color, isHorizontal: true, width: 9)),
          Align(alignment: Alignment.centerLeft, child: _chair(color, isHorizontal: false, height: 12)),
          Align(alignment: Alignment.centerRight, child: _chair(color, isHorizontal: false, height: 12)),
        ],
      );
    } else {
      // 12 chairs: 5 top, 5 bottom, 1 left, 1 right
      return Stack(
        children: [
          Align(alignment: const Alignment(-0.8, -1.0), child: _chair(color, isHorizontal: true, width: 8)),
          Align(alignment: const Alignment(-0.4, -1.0), child: _chair(color, isHorizontal: true, width: 8)),
          Align(alignment: const Alignment(0.0, -1.0), child: _chair(color, isHorizontal: true, width: 8)),
          Align(alignment: const Alignment(0.4, -1.0), child: _chair(color, isHorizontal: true, width: 8)),
          Align(alignment: const Alignment(0.8, -1.0), child: _chair(color, isHorizontal: true, width: 8)),
          Align(alignment: const Alignment(-0.8, 1.0), child: _chair(color, isHorizontal: true, width: 8)),
          Align(alignment: const Alignment(-0.4, 1.0), child: _chair(color, isHorizontal: true, width: 8)),
          Align(alignment: const Alignment(0.0, 1.0), child: _chair(color, isHorizontal: true, width: 8)),
          Align(alignment: const Alignment(0.4, 1.0), child: _chair(color, isHorizontal: true, width: 8)),
          Align(alignment: const Alignment(0.8, 1.0), child: _chair(color, isHorizontal: true, width: 8)),
          Align(alignment: Alignment.centerLeft, child: _chair(color, isHorizontal: false, height: 12)),
          Align(alignment: Alignment.centerRight, child: _chair(color, isHorizontal: false, height: 12)),
        ],
      );
    }
  }

  Widget _chair(Color color, {required bool isHorizontal, double width = 14, double height = 14}) {
    return Container(
      margin: const EdgeInsets.all(4),
      width: isHorizontal ? width : 5,
      height: isHorizontal ? 5 : height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }
}
