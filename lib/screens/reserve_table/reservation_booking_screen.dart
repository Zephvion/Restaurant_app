import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/restaurant.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/network_image_with_fallback.dart';

/// Date / time slot / guest count selection screen.
/// Receives a [Restaurant] as route argument.
/// Passes a [_BookingArgs] object to the Table Picker screen.
class ReservationBookingScreen extends StatefulWidget {
  const ReservationBookingScreen({super.key});

  @override
  State<ReservationBookingScreen> createState() =>
      _ReservationBookingScreenState();
}

class _ReservationBookingScreenState extends State<ReservationBookingScreen> {
  // Week state
  late DateTime _weekStart;
  int? _selectedDayOffset; // 0–6 relative to _weekStart

  // Time + guests
  String? _selectedTime;
  int? _selectedGuests;

  @override
  void initState() {
    super.initState();
    // Start from today
    final now = DateTime.now();
    _weekStart = DateTime(now.year, now.month, now.day);
    _selectedDayOffset = 0;
    _selectedGuests = 2;
    _validateSelectedTime();
  }

  DateTime get _selectedDate {
    return _weekStart.add(Duration(days: _selectedDayOffset ?? 0));
  }

  bool get _isTodaySelected {
    final now = DateTime.now();
    final sel = _selectedDate;
    return sel.year == now.year && sel.month == now.month && sel.day == now.day;
  }

  static ({int hour, int minute})? _parseTimeSlot(String slot) {
    final cleaned = slot.replaceAll(' ', '').toUpperCase();
    final isPm = cleaned.contains('PM');
    final isAm = cleaned.contains('AM');
    final numPart = cleaned.replaceAll('AM', '').replaceAll('PM', '');
    final parts = numPart.split(':');
    if (parts.isEmpty) return null;
    int hour = int.tryParse(parts[0]) ?? 12;
    int min = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    if (isPm && hour < 12) hour += 12;
    if (isAm && hour == 12) hour = 0;
    return (hour: hour, minute: min);
  }

  List<String> get _availableTimeSlots {
    final allSlots = MockData.reservationTimeSlots;
    if (!_isTodaySelected) {
      // Future dates (tomorrow, day after, etc.): All morning/evening slots are available!
      return allSlots;
    }

    final now = DateTime.now();
    // For today, only show slots strictly after current time (with 15-minute buffer)
    return allSlots.where((slot) {
      final parsed = _parseTimeSlot(slot);
      if (parsed == null) return false;
      final slotDateTime =
          DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);
      return slotDateTime.isAfter(now.add(const Duration(minutes: 15)));
    }).toList();
  }

  void _validateSelectedTime() {
    final slots = _availableTimeSlots;
    if (_selectedTime == null || !slots.contains(_selectedTime)) {
      _selectedTime = slots.isNotEmpty ? slots.first : null;
    }
  }

  void _onDaySelected(int i) {
    setState(() {
      _selectedDayOffset = i;
      _validateSelectedTime();
    });
  }

  bool get _canProceed =>
      _selectedDayOffset != null &&
      _selectedTime != null &&
      _selectedGuests != null;

  Restaurant get _restaurant =>
      ModalRoute.of(context)!.settings.arguments as Restaurant;

  void _nextWeek() => setState(() {
        _weekStart = _weekStart.add(const Duration(days: 7));
        _selectedDayOffset = 0;
        _validateSelectedTime();
      });

  void _proceed() {
    if (!_canProceed) return;
    final date = _weekStart.add(Duration(days: _selectedDayOffset!));
    Navigator.of(context).pushNamed(
      AppRoutes.tablePicker,
      arguments: _BookingArgs(
        restaurant: _restaurant,
        date: date,
        timeSlot: _selectedTime!,
        seats: _selectedGuests!,
      ),
    );
  }

  String _weekLabel() {
    final end = _weekStart.add(const Duration(days: 6));
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final startMonth = months[_weekStart.month - 1];
    final endMonth = months[end.month - 1];
    if (startMonth == endMonth) {
      return '$startMonth ${_weekStart.day} - ${end.day}, ${_weekStart.year}';
    } else {
      return '$startMonth ${_weekStart.day} - $endMonth ${end.day}, ${_weekStart.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = _restaurant;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              // ── Hero image ─────────────────────────────────────────────
              SizedBox(
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const NetworkImageWithFallback(
                      url: MockData.reserveTableInterior,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.restaurant,
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white, size: 20),
                              onPressed: () {
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context)
                                      .pushReplacementNamed(AppRoutes.selectRestaurant);
                                }
                              },
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.location_on_outlined,
                                  color: Colors.white),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Colors.white),
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.notifications),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Content ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${AuthService.instance.currentUser?.displayName.trim().isNotEmpty == true ? AuthService.instance.currentUser!.displayName.trim() : "Guest"}!',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Reserve a table\nat ${restaurant.name.split(' ').first}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // ── Date row ─────────────────────────────────────────
                    Row(
                      children: [
                        const Spacer(),
                        GestureDetector(
                          onTap: _nextWeek,
                          child: Row(
                            children: [
                              Text(
                                _weekLabel(),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 12,
                                  color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Select a date to reserve your table',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    _DateStrip(
                      weekStart: _weekStart,
                      selectedOffset: _selectedDayOffset,
                      onSelect: _onDaySelected,
                    ),
                    const SizedBox(height: 28),
                    // ── Time slots ────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Choose a time for reservation',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                        if (_isTodaySelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.copper.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'LIVE TODAY SLOTS',
                              style: TextStyle(
                                color: AppColors.copper,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _TimeSlotRow(
                      slots: _availableTimeSlots,
                      isToday: _isTodaySelected,
                      selectedTime: _selectedTime,
                      onSelect: (t) => setState(() => _selectedTime = t),
                    ),
                    const SizedBox(height: 28),
                    // ── Guest count ───────────────────────────────────────
                    const Text(
                      'Number of people',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    _GuestRow(
                      selected: _selectedGuests,
                      onSelect: (g) => setState(() => _selectedGuests = g),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // ── Persistent Proceed Button ────────────────────────────────────
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _canProceed ? AppColors.accentRed : AppColors.surface,
                foregroundColor: _canProceed ? Colors.white : AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: _canProceed ? 4 : 0,
              ),
              onPressed: _canProceed ? _proceed : null,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(
                _canProceed ? 'PROCEED TO TABLE SELECTION' : 'SELECT DATE, TIME & GUESTS',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Date strip ────────────────────────────────────────────────────────────────

class _DateStrip extends StatelessWidget {
  const _DateStrip({
    required this.weekStart,
    required this.selectedOffset,
    required this.onSelect,
  });
  final DateTime weekStart;
  final int? selectedOffset;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(7, (i) {
          final date = weekStart.add(Duration(days: i));
          final selected = selectedOffset == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              width: 52,
              height: 64,
              decoration: BoxDecoration(
                color: selected ? AppColors.accentRed : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    days[date.weekday % 7],
                    style: TextStyle(
                      color: selected
                          ? Colors.white.withOpacity(0.9)
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Time slot row ─────────────────────────────────────────────────────────────

class _TimeSlotRow extends StatefulWidget {
  const _TimeSlotRow({
    required this.slots,
    required this.isToday,
    required this.selectedTime,
    required this.onSelect,
  });

  final List<String> slots;
  final bool isToday;
  final String? selectedTime;
  final ValueChanged<String> onSelect;

  @override
  State<_TimeSlotRow> createState() => _TimeSlotRowState();
}

class _TimeSlotRowState extends State<_TimeSlotRow> {
  // 0: Lunch, 1: Dinner, 2: Morning
  int _activeSession = 0;

  static int _slotHour(String slot) {
    final cleaned = slot.replaceAll(' ', '').toUpperCase();
    final isPm = cleaned.contains('PM');
    final numPart = cleaned.replaceAll('AM', '').replaceAll('PM', '');
    final parts = numPart.split(':');
    if (parts.isEmpty) return 12;
    int hour = int.tryParse(parts[0]) ?? 12;
    if (isPm && hour < 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return hour;
  }

  @override
  void initState() {
    super.initState();
    _autoSelectInitialSession();
  }

  @override
  void didUpdateWidget(covariant _TimeSlotRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTime != null &&
        widget.selectedTime != oldWidget.selectedTime) {
      _syncSessionToSelectedTime(widget.selectedTime!);
    }
  }

  void _autoSelectInitialSession() {
    if (widget.selectedTime != null) {
      _syncSessionToSelectedTime(widget.selectedTime!);
      return;
    }
    final now = DateTime.now();
    if (widget.isToday && now.hour >= 16) {
      _activeSession = 1; // Dinner
    } else {
      _activeSession = 0; // Lunch
    }
  }

  void _syncSessionToSelectedTime(String slot) {
    final h = _slotHour(slot);
    if (h < 12) {
      _activeSession = 2; // Morning
    } else if (h < 17) {
      _activeSession = 0; // Lunch
    } else {
      _activeSession = 1; // Dinner
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.maroon.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.maroon.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.accentRed, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'All dining slots for today have concluded. Please select tomorrow to reserve a table.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final lunchSlots = widget.slots.where((s) {
      final h = _slotHour(s);
      return h >= 12 && h < 17;
    }).toList();

    final dinnerSlots = widget.slots.where((s) {
      final h = _slotHour(s);
      return h >= 17;
    }).toList();

    final morningSlots = widget.slots.where((s) {
      final h = _slotHour(s);
      return h < 12;
    }).toList();

    List<String> currentSlots;
    if (_activeSession == 0) {
      currentSlots = lunchSlots.isNotEmpty ? lunchSlots : widget.slots;
    } else if (_activeSession == 1) {
      currentSlots = dinnerSlots.isNotEmpty ? dinnerSlots : widget.slots;
    } else {
      currentSlots = morningSlots.isNotEmpty ? morningSlots : widget.slots;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meal Session Toggle Chips (Lunch / Dinner / Morning)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSessionFilter(
                index: 0,
                label: '☀️ Lunch',
                count: lunchSlots.length,
              ),
              const SizedBox(width: 8),
              _buildSessionFilter(
                index: 1,
                label: '🌙 Dinner',
                count: dinnerSlots.length,
              ),
              if (morningSlots.isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildSessionFilter(
                  index: 2,
                  label: '🌅 Morning',
                  count: morningSlots.length,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Time Slot Chips
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: currentSlots.map((slot) {
            final selected = slot == widget.selectedTime;
            return GestureDetector(
              onTap: () => widget.onSelect(slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accentRed : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? AppColors.accentRed
                        : Colors.white.withValues(alpha: 0.08),
                    width: selected ? 1.5 : 1.0,
                  ),
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSessionFilter({
    required int index,
    required String label,
    required int count,
  }) {
    final isSelected = _activeSession == index;
    final isAvailable = count > 0;

    return GestureDetector(
      onTap: isAvailable ? () => setState(() => _activeSession = index) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.copper.withValues(alpha: 0.18)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.copper
                : Colors.white.withValues(alpha: 0.06),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.copper
                    : (isAvailable
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withValues(alpha: 0.5)),
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.copper.withValues(alpha: 0.25)
                    : Colors.white10,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color:
                      isSelected ? AppColors.copper : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Guest row ─────────────────────────────────────────────────────────────────

class _GuestRow extends StatelessWidget {
  const _GuestRow({required this.selected, required this.onSelect});
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(12, (i) {
          final count = i + 1; // 1..12 guests (supports odd numbers 1, 3, 5, 7, 9, 11)
          final isSelected = count == selected;
          return GestureDetector(
            onTap: () => onSelect(count),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentRed : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentRed
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Args passed to table picker ───────────────────────────────────────────────

class _BookingArgs {
  const _BookingArgs({
    required this.restaurant,
    required this.date,
    required this.timeSlot,
    required this.seats,
  });
  final Restaurant restaurant;
  final DateTime date;
  final String timeSlot;
  final int seats;
}

/// Public typedef so table_picker_screen.dart can import and cast the argument.
typedef BookingArgs = _BookingArgs;
