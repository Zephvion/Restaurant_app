import '../../core/repositories/app_repository.dart';
import '../../models/reservation.dart';
import '../../state/reservation_controller.dart';

/// Reservation-specific data access contract.
abstract interface class ReservationRepository
    implements AppRepository<Reservation> {
  Future<void> create(Reservation reservation);

  Future<void> delete(String id);
}

/// Controller-backed implementation of the repository.
class ControllerReservationRepository implements ReservationRepository {
  ControllerReservationRepository({
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

  @override
  Future<void> create(Reservation reservation) async {
    _controller.add(reservation);
  }

  @override
  Future<void> delete(String id) async {
    _controller.remove(id);
  }
}