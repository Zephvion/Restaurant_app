import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reservation.dart';
import 'reservation_controller.dart';

/// Provides the existing reservation controller to the app.
///
/// The existing singleton is retained to preserve compatibility
/// with widgets that already use ReservationController.instance.
final reservationControllerProvider =
    ChangeNotifierProvider<ReservationController>((ref) {
  return ReservationController.instance;
});

/// Provides the current reservation list.
///
/// This provider automatically updates when the controller notifies
/// its listeners.
final reservationsProvider = Provider<List<Reservation>>((ref) {
  return ref.watch(reservationControllerProvider).reservations;
});
