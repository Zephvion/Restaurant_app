import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/network_image_with_fallback.dart';

/// Arguments passed from Booking Screen to the Notify Screen.
class CateringBookingArgs {
  const CateringBookingArgs({
    required this.date,
    required this.guestRange,
  });

  final DateTime date;
  final String guestRange;
}

/// Screen allowing the user to select the catering event date and expected number of guests.
class CateringBookingScreen extends StatefulWidget {
  const CateringBookingScreen({super.key});

  @override
  State<CateringBookingScreen> createState() => _CateringBookingScreenState();
}

class _CateringBookingScreenState extends State<CateringBookingScreen> {
  late DateTime _weekStart;
  int? _selectedDayOffset; // 0..6
  String? _selectedGuestRange;

  final List<String> _guestRanges = [
    'Less than 50',
    'Less than 100',
    'Less than 250',
    '250+',
  ];

  @override
  void initState() {
    super.initState();
    // Default to at least 2 days in advance (starts at today + 2 days)
    final now = DateTime.now().add(const Duration(days: 2));
    _weekStart = now.subtract(Duration(days: now.weekday % 7));
  }

  bool get _canProceed =>
      _selectedDayOffset != null && _selectedGuestRange != null;

  void _nextWeek() => setState(() {
        _weekStart = _weekStart.add(const Duration(days: 7));
        _selectedDayOffset = null;
      });

  void _proceed() {
    if (!_canProceed) return;
    final selectedDate = _weekStart.add(Duration(days: _selectedDayOffset!));
    Navigator.of(context).pushNamed(
      AppRoutes.cateringNotify,
      arguments: CateringBookingArgs(
        date: selectedDate,
        guestRange: _selectedGuestRange!,
      ),
    );
  }

  String _weekLabel() {
    final end = _weekStart.add(const Duration(days: 6));
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[_weekStart.month - 1]} ${_weekStart.day} - ${end.day}';
  }

  @override
  Widget build(BuildContext context) {
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
                      url: MockData.cateringTable,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.room_service,
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white, size: 20),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const Spacer(),
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
                    const Text('Hello, Arti!',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 6),
                    const Text(
                      'Place catering\norders with us.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // ── Date selector row ─────────────────────────────────
                    Row(
                      children: [
                        const Text(
                          'Select the date for reservation',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
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
                    const SizedBox(height: 14),
                    _DateStrip(
                      weekStart: _weekStart,
                      selectedOffset: _selectedDayOffset,
                      onSelect: (i) =>
                          setState(() => _selectedDayOffset = i),
                    ),
                    const SizedBox(height: 32),
                    // ── Expected number of people ─────────────────────────
                    const Text(
                      'Expected number of people',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    _GuestRangeRow(
                      ranges: _guestRanges,
                      selected: _selectedGuestRange,
                      onSelect: (r) =>
                          setState(() => _selectedGuestRange = r),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // ── NEXT button ────────────────────────────────────────────────
          if (_canProceed)
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: GestureDetector(
                onTap: _proceed,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'NEXT',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 1.5,
                    ),
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
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (selected)
                    Text(
                      days[date.weekday % 7],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
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

// ── Guest Range Row ───────────────────────────────────────────────────────────

class _GuestRangeRow extends StatelessWidget {
  const _GuestRangeRow({
    required this.ranges,
    required this.selected,
    required this.onSelect,
  });

  final List<String> ranges;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ranges.map((range) {
          final isSelected = range == selected;
          return GestureDetector(
            onTap: () => onSelect(range),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentRed : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                range,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
