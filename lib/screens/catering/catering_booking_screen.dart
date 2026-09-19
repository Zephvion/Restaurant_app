import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/restaurant.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/network_image_with_fallback.dart';

/// Arguments passed from Booking Screen to the Package Screen.
class CateringBookingArgs {
  const CateringBookingArgs({
    this.restaurant,
    required this.date,
    required this.timeSlot,
    required this.guestRange,
    required this.eventType,
  });

  final Restaurant? restaurant;
  final DateTime date;
  final String timeSlot;
  final String guestRange;
  final String eventType;
}

/// Step 2 of Catering: Event date, time slot, expected guests, and event type.
class CateringBookingScreen extends StatefulWidget {
  const CateringBookingScreen({super.key});

  @override
  State<CateringBookingScreen> createState() => _CateringBookingScreenState();
}

class _CateringBookingScreenState extends State<CateringBookingScreen> {
  late DateTime _weekStart;
  int? _selectedDayOffset; // 0..6
  String _selectedTimeSlot = 'Lunch (12:00 PM – 3:30 PM)';
  String? _selectedGuestRange;
  String _selectedEventType = 'Corporate Buffet';

  final List<String> _timeSlots = [
    'Lunch (12:00 PM – 3:30 PM)',
    'High Tea (4:00 PM – 6:30 PM)',
    'Dinner (7:00 PM – 11:00 PM)',
  ];

  final List<String> _guestRanges = [
    '25 - 50 Guests',
    '50 - 100 Guests',
    '100 - 250 Guests',
    '250 - 500 Guests',
    '500+ Guests',
  ];

  final List<String> _eventTypes = [
    'Corporate Buffet',
    'Wedding Reception',
    'Birthday Feast',
    'Housewarming',
    'Social Gathering',
  ];

  @override
  void initState() {
    super.initState();
    // Default to at least 2 days in advance from today
    final minDate = DateTime.now().add(const Duration(days: 2));
    _weekStart = DateTime(minDate.year, minDate.month, minDate.day);
    _selectedDayOffset = 0;
  }

  bool get _canProceed =>
      _selectedDayOffset != null && _selectedGuestRange != null;

  Restaurant? get _restaurant {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Restaurant) return args;
    return MockData.restaurants.first;
  }

  void _nextWeek() => setState(() {
        _weekStart = _weekStart.add(const Duration(days: 7));
        _selectedDayOffset = null;
      });

  void _proceed() {
    if (!_canProceed) return;
    final selectedDate = _weekStart.add(Duration(days: _selectedDayOffset!));
    Navigator.of(context).pushNamed(
      AppRoutes.cateringPackage,
      arguments: CateringBookingArgs(
        restaurant: _restaurant,
        date: selectedDate,
        timeSlot: _selectedTimeSlot,
        guestRange: _selectedGuestRange!,
        eventType: _selectedEventType,
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
    final restaurant = _restaurant ?? MockData.restaurants.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              // ── Hero Image ─────────────────────────────────────────────
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
                              onPressed: () {
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context).pushReplacementNamed(
                                      AppRoutes.cateringSelectRestaurant);
                                }
                              },
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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Step 2 of 4: Schedule & Scale',
                      style: TextStyle(
                        color: AppColors.copper,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Catering by ${restaurant.name}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Date Row ─────────────────────────────────────────
                    Row(
                      children: [
                        const Text(
                          'Select Event Date',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _nextWeek,
                          child: Row(
                            children: [
                              Text(
                                _weekLabel(),
                                style: const TextStyle(
                                  color: AppColors.copper,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 12, color: AppColors.copper),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _DateStrip(
                      weekStart: _weekStart,
                      selectedOffset: _selectedDayOffset,
                      onSelect: (i) => setState(() => _selectedDayOffset = i),
                    ),
                    const SizedBox(height: 24),

                    // ── Time Slot ────────────────────────────────────────
                    const Text(
                      'Service Time Slot',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _timeSlots.map((slot) {
                        final isSelected = slot == _selectedTimeSlot;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTimeSlot = slot),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accentRed
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accentRed
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              slot,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // ── Event Type ───────────────────────────────────────
                    const Text(
                      'Event Type',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _eventTypes.map((type) {
                          final isSelected = type == _selectedEventType;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedEventType = type),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accentRed
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accentRed
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Guest Count Range ────────────────────────────────
                    const Text(
                      'Expected Guest Count',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _guestRanges.map((range) {
                        final isSelected = range == _selectedGuestRange;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedGuestRange = range),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accentRed
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accentRed
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              range,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
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
                backgroundColor: _canProceed
                    ? AppColors.accentRed
                    : AppColors.surface,
                foregroundColor: _canProceed
                    ? Colors.white
                    : AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                elevation: _canProceed ? 4 : 0,
              ),
              onPressed: _canProceed ? _proceed : null,
              child: Text(
                _canProceed
                    ? 'CHOOSE CATERING MENU PACKAGE'
                    : 'SELECT DATE & GUEST COUNT',
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

// ── Date Strip Component ─────────────────────────────────────────────────────

class _DateStrip extends StatelessWidget {
  const _DateStrip({
    required this.weekStart,
    required this.selectedOffset,
    required this.onSelect,
  });

  final DateTime weekStart;
  final int? selectedOffset;
  final ValueChanged<int> onSelect;

  static const _days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        final date = weekStart.add(Duration(days: i));
        final isSelected = i == selectedOffset;

        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentRed : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.accentRed : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _days[date.weekday % 7],
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
