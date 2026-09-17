import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../state/reservation_controller.dart';
import '../../theme/app_colors.dart';
import 'reservation_booking_screen.dart' show BookingArgs;

/// Visual floor-plan showing 14 tables (with chair bumps).
/// Receives [BookingArgs] as route argument.
class TablePickerScreen extends StatefulWidget {
  const TablePickerScreen({super.key});

  @override
  State<TablePickerScreen> createState() => _TablePickerScreenState();
}

class _TablePickerScreenState extends State<TablePickerScreen> {
  int? _selectedTable;

  BookingArgs get _args =>
      ModalRoute.of(context)!.settings.arguments as BookingArgs;

  Future<void> _confirmTable() async {
    final args = _args;
    await ReservationController.instance.createReservation(
      restaurant: args.restaurant,
      date: args.date,
      timeSlot: args.timeSlot,
      seats: args.seats,
      tableNumber: _selectedTable!,
    );
    if (mounted) {
      Navigator.of(context).pushNamed(AppRoutes.reservationSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.reserveDashboard);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Now it's time to choose\nyour table",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.location_on_outlined,
                        color: AppColors.textPrimary),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AppRoutes.notifications),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ── Floor plan ───────────────────────────────────────────────
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _FloorPlan(
                      selectedTable: _selectedTable,
                      onSelect: (n) => setState(() => _selectedTable = n),
                    ),
                  ),
                  // Window view labels on the right edge
                  const _WindowViewLabels(),
                ],
              ),
            ),
            // ── NEXT button ──────────────────────────────────────────────
            if (_selectedTable != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: GestureDetector(
                  onTap: _confirmTable,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.accentRed,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'CONFIRM TABLE',
                      style: TextStyle(
                        color: Colors.white,
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
      ),
    );
  }
}

// ── Floor plan grid ───────────────────────────────────────────────────────────

class _FloorPlan extends StatelessWidget {
  const _FloorPlan({required this.selectedTable, required this.onSelect});
  final int? selectedTable;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Row 1: tables 1-3
          _tableRow([1, 2, 3]),
          const SizedBox(height: 12),
          // Row 2: tables 4-6
          _tableRow([4, 5, 6]),
          const SizedBox(height: 12),
          // Row 3: tables 7-9
          _tableRow([7, 8, 9]),
          const SizedBox(height: 12),
          // Row 4: tables 10-11 + table 12 (tall, spans 2 rows)
          Row(
            children: [
              Expanded(child: _TableWidget(number: 10, selected: selectedTable == 10, onTap: () => onSelect(10))),
              const SizedBox(width: 12),
              Expanded(child: _TableWidget(number: 11, selected: selectedTable == 11, onTap: () => onSelect(11))),
              const SizedBox(width: 12),
              Expanded(
                child: _TableWidget(
                  number: 12,
                  selected: selectedTable == 12,
                  onTap: () => onSelect(12),
                  tall: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 5: table 13 + table 14 (tall)
          Row(
            children: [
              Expanded(child: _TableWidget(number: 13, selected: selectedTable == 13, onTap: () => onSelect(13))),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
              const SizedBox(width: 12),
              Expanded(
                child: _TableWidget(
                  number: 14,
                  selected: selectedTable == 14,
                  onTap: () => onSelect(14),
                  tall: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableRow(List<int> numbers) {
    return Row(
      children: numbers.asMap().entries.map((e) {
        final n = e.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: e.key < numbers.length - 1 ? 12 : 0),
            child: _TableWidget(
              number: n,
              selected: selectedTable == n,
              onTap: () => onSelect(n),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// A single table widget showing chair bumps around the edges.
class _TableWidget extends StatelessWidget {
  const _TableWidget({
    required this.number,
    required this.selected,
    required this.onTap,
    this.tall = false,
  });
  final int number;
  final bool selected;
  final VoidCallback onTap;
  final bool tall;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.surfaceLight : AppColors.surface;
    final tableColor = selected
        ? Colors.white.withValues(alpha: 0.15)
        : AppColors.surfaceLight.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: tall ? 110 : 74,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Chair bumps — top & bottom
            Positioned(
              top: 4,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [_seat(bg), _seat(bg)],
              ),
            ),
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [_seat(bg), _seat(bg)],
              ),
            ),
            // Table surface
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
              decoration: BoxDecoration(
                color: tableColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.4)
                      : AppColors.border,
                  width: selected ? 1.5 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$number',
                style: TextStyle(
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seat(Color color) {
    return Container(
      width: 16,
      height: 12,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

// ── Window view labels ────────────────────────────────────────────────────────

class _WindowViewLabels extends StatelessWidget {
  const _WindowViewLabels();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      child: Column(
        children: [
          const SizedBox(height: 140),
          _rotatedLabel('WINDOW VIEW'),
          const SizedBox(height: 100),
          _rotatedLabel('WINDOW VIEW'),
        ],
      ),
    );
  }

  Widget _rotatedLabel(String text) {
    return RotatedBox(
      quarterTurns: 1,
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 8,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
