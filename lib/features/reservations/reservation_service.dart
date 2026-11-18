import '../../models/reservation.dart';
import 'reservation_repository.dart';

/// Handles reservation use cases independently of the data source.
class ReservationService {
  ReservationService({
    required ReservationRepository repository,
  }) : _repository = repository;

  final ReservationRepository _repository;

  Future<List<Reservation>> getReservations() {
    return _repository.getAll();
  }

  Future<Reservation?> getReservation(String id) {
    return _repository.getById(id);
  }

  Future<void> createReservation(Reservation reservation) async {
    if (reservation.id.trim().isEmpty) {
      throw ArgumentError('Reservation ID cannot be empty.');
    }

    if (reservation.seats <= 0) {
      throw ArgumentError('Reservation seats must be greater than zero.');
    }

    if (reservation.tableNumber <= 0) {
      throw ArgumentError('Table number must be greater than zero.');
    }

    await _repository.create(reservation);
  }

  Future<void> deleteReservation(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('Reservation ID cannot be empty.');
    }

    await _repository.delete(id);
  }
}