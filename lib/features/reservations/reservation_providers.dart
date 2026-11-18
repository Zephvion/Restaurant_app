import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/reservation.dart';
import '../../state/reservation_providers.dart';
import 'reservation_repository.dart';
import 'reservation_service.dart';

/// Injects the reservation repository.
final reservationRepositoryProvider =
    Provider<ReservationRepository>((ref) {
  final controller = ref.watch(reservationControllerProvider);

  return ControllerReservationRepository(controller: controller);
});

/// Injects the reservation service.
final reservationServiceProvider = Provider<ReservationService>((ref) {
  final repository = ref.watch(reservationRepositoryProvider);

  return ReservationService(repository: repository);
});

/// Loads all reservations through the service layer.
final reservationsAsyncProvider =
    FutureProvider<List<Reservation>>((ref) async {
  final service = ref.watch(reservationServiceProvider);
  return service.getReservations();
});

/// Loads one reservation through the service layer.
final reservationByIdProvider =
    FutureProvider.family<Reservation?, String>((ref, id) async {
  final service = ref.watch(reservationServiceProvider);
  return service.getReservation(id);
});