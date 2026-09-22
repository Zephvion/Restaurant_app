import 'package:flutter/foundation.dart';

import '../models/reservation.dart';
import '../models/restaurant.dart';
import '../services/auth_service.dart';
import '../services/reservation_service.dart';
import '../services/table_lock_service.dart';

/// Singleton [ChangeNotifier] that manages the user's table reservations.
///
/// Mirrors the pattern used by [CartController]: call [instance] to access the
/// singleton and wrap widgets in [AnimatedBuilder] / [ListenableBuilder] to
/// rebuild when reservations change.
class ReservationController extends ChangeNotifier {
  ReservationController._() {
    _init();
  }
  static final ReservationController instance = ReservationController._();

  final List<Reservation> _reservations = [];

  List<Reservation> get reservations => List.unmodifiable(_reservations);

  bool get isEmpty => _reservations.isEmpty;

  Future<void> _init() async {
    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';
    final items = await ReservationService.instance.getUserReservations(uid);
    _reservations
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  void add(Reservation reservation) {
    _reservations.insert(0, reservation);
    notifyListeners();
  }

  Future<Reservation> createReservation({
    required Restaurant restaurant,
    required DateTime date,
    required String timeSlot,
    required int seats,
    required int tableNumber,
    List<int> tableNumbers = const [],
  }) async {
    final res = await ReservationService.instance.createReservation(
      restaurant: restaurant,
      date: date,
      timeSlot: timeSlot,
      seats: seats,
      tableNumber: tableNumber,
      tableNumbers: tableNumbers,
    );
    _reservations.insert(0, res);
    notifyListeners();
    return res;
  }

  /// Customer cancellation: Cancels their own reservation and releases the table(s)
  Future<void> cancelReservation(Reservation reservation, {required String reason}) async {
    // 1. Free lock in TableLockService for all tables
    for (final num in reservation.allTableNumbers) {
      TableLockService.instance.cancelReservation(num);
    }

    // 2. Mark reservation cancelled in ReservationService
    await ReservationService.instance.cancelReservationWithDetails(
      reservation.id,
      reason: reason,
    );

    // 3. Update local state
    final idx = _reservations.indexWhere((r) => r.id == reservation.id);
    if (idx != -1) {
      _reservations[idx] = _reservations[idx].copyWith(
        status: 'cancelled',
        cancellationReason: reason,
        cancelledAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  /// Owner/Staff manual release (kept for Owner Dashboard)
  Future<void> releaseTable(Reservation reservation) async {
    // 1. Free lock in TableLockService for all tables
    for (final num in reservation.allTableNumbers) {
      TableLockService.instance.receptionistReleaseTable(num);
    }

    // 2. Mark reservation completed in ReservationService
    await ReservationService.instance.markReservationCompleted(reservation.id);

    // 3. Update local state
    final idx = _reservations.indexWhere((r) => r.id == reservation.id);
    if (idx != -1) {
      _reservations[idx] = _reservations[idx].copyWith(status: 'completed');
    }
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await ReservationService.instance.cancelReservation(id);
    _reservations.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  /// Guest "Pay at Table" action: marks reservation as paid/completed and
  /// immediately frees all reserved table locks so the floor plan shows them as available.
  Future<void> payAtTable(Reservation reservation) async {
    // 1. Release all table locks in TableLockService (occupied → available)
    for (final num in reservation.allTableNumbers) {
      TableLockService.instance.receptionistReleaseTable(num);
    }

    // 2. Mark reservation completed/freed in backend
    await ReservationService.instance.markReservationCompleted(reservation.id);

    // 3. Update local state to 'paid_at_table' (shows as completed)
    final idx = _reservations.indexWhere((r) => r.id == reservation.id);
    if (idx != -1) {
      _reservations[idx] = _reservations[idx].copyWith(status: 'paid_at_table');
    }
    notifyListeners();
  }
}
