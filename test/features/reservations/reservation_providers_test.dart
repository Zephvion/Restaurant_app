
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant_app/features/reservations/reservation_providers.dart';
import 'package:restaurant_app/features/reservations/reservation_repository.dart';
import 'package:restaurant_app/models/reservation.dart';

class FakeReservationRepository implements ReservationRepository {
  FakeReservationRepository([List<Reservation>? initialReservations])
      : reservations = List<Reservation>.from(initialReservations ?? []);

  final List<Reservation> reservations;

  @override
  Future<List<Reservation>> getAll() async => reservations;

  @override
  Future<Reservation?> getById(String id) async {
    for (final reservation in reservations) {
      if (reservation.id == id) return reservation;
    }
    return null;
  }

  @override
  Future<void> create(Reservation reservation) async {
    reservations.add(reservation);
  }

  @override
  Future<void> delete(String id) async {
    reservations.removeWhere((reservation) => reservation.id == id);
  }
}

void main() {
  test('reservations provider loads records asynchronously', () async {
    final container = ProviderContainer(
      overrides: [
        reservationRepositoryProvider.overrideWithValue(
          FakeReservationRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final reservations =
        await container.read(reservationsAsyncProvider.future);

    expect(reservations, isEmpty);
  });

  test('reservation lookup returns null when record is missing', () async {
    final container = ProviderContainer(
      overrides: [
        reservationRepositoryProvider.overrideWithValue(
          FakeReservationRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final reservation =
        await container.read(reservationByIdProvider('missing-id').future);

    expect(reservation, isNull);
  });
}
