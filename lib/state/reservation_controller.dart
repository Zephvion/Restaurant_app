import 'package:flutter/foundation.dart';

import '../models/reservation.dart';

/// Singleton [ChangeNotifier] that manages the user's table reservations.
///
/// Mirrors the pattern used by [CartController]: call [instance] to access the
/// singleton and wrap widgets in [AnimatedBuilder] / [ListenableBuilder] to
/// rebuild when reservations change.
class ReservationController extends ChangeNotifier {
  ReservationController._();
  static final ReservationController instance = ReservationController._();

  final List<Reservation> _reservations = [];

  List<Reservation> get reservations => List.unmodifiable(_reservations);

  bool get isEmpty => _reservations.isEmpty;

  void add(Reservation reservation) {
    _reservations.add(reservation);
    notifyListeners();
  }

  void remove(String id) {
    _reservations.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
