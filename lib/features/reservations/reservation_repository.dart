import '../../models/reservation.dart';
import '../../state/reservation_controller.dart';
import '../../core/repositories/app_repository.dart';

/// Repository for accessing reservation data.
///
/// Currently uses the existing in-memory ReservationController.
/// It can later be replaced with a Firestore implementation without
/// changing the feature's provider interface.
class ReservationRepository implements AppRepository<Reservation> {
  ReservationRepository({
    required ReservationController controller,
  }) : _controller = controller;

  final ReservationController _controller;

  @override
  Future<List<Reservation>> getAll() async {
    return _controller.reservations;
  }

  @override
  Future<Reservation?> getById(String id) async {
    for (final reservation in _controller.reservations) {
      if (reservation.id == id) {
        return reservation;
      }
    }

    return null;
  }
}
