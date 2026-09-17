import 'package:flutter/foundation.dart';

import '../models/reservation.dart';
import '../models/restaurant.dart';
import '../services/auth_service.dart';
import '../services/reservation_service.dart';

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
  }) async {
    final res = await ReservationService.instance.createReservation(
      restaurant: restaurant,
      date: date,
      timeSlot: timeSlot,
      seats: seats,
      tableNumber: tableNumber,
    );
    _reservations.insert(0, res);
    notifyListeners();
    return res;
  }

  Future<void> remove(String id) async {
    await ReservationService.instance.cancelReservation(id);
    _reservations.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
