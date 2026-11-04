import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/app_repository.dart';
import '../../models/reservation.dart';
import '../../state/reservation_providers.dart';
import 'reservation_repository.dart';

/// Injects the reservation repository through its shared contract.
///
/// Tests and future backend implementations can override this provider.
final reservationRepositoryProvider =
    Provider<AppRepository<Reservation>>((ref) {
  final controller = ref.watch(reservationControllerProvider);

  return ReservationRepository(controller: controller);
});

/// Loads all reservations asynchronously.
final reservationsAsyncProvider =
    FutureProvider<List<Reservation>>((ref) async {
  final repository = ref.watch(reservationRepositoryProvider);
  return repository.getAll();
});

/// Loads a reservation by ID asynchronously.
final reservationByIdProvider =
    FutureProvider.family<Reservation?, String>((ref, id) async {
  final repository = ref.watch(reservationRepositoryProvider);
  return repository.getById(id);
});