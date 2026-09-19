import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/reservation.dart';
import '../models/restaurant.dart';
import 'auth_service.dart';
import 'firebase_initializer.dart';

class ReservationService {
  ReservationService._();
  static final ReservationService instance = ReservationService._();

  final List<Reservation> _localReservations = [];

  List<Reservation> get reservations => List.unmodifiable(_localReservations);

  Future<Reservation> createReservation({
    required Restaurant restaurant,
    required DateTime date,
    required String timeSlot,
    required int seats,
    required int tableNumber,
    List<int> tableNumbers = const [],
  }) async {
    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';
    final reservationId = 'RES${1000 + DateTime.now().millisecondsSinceEpoch % 9000}';

    final reservation = Reservation(
      id: reservationId,
      userId: uid,
      restaurant: restaurant,
      date: date,
      timeSlot: timeSlot,
      seats: seats,
      tableNumber: tableNumber,
      tableNumbers: tableNumbers.isNotEmpty ? tableNumbers : [tableNumber],
    );

    _localReservations.insert(0, reservation);

    if (FirebaseInitializer.isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('reservations')
            .doc(reservationId)
            .set(reservation.toMap())
            .timeout(
              const Duration(seconds: 3),
              onTimeout: () => debugPrint(
                  'Firestore create reservation timed out; persisting locally.'),
            );
      } catch (e) {
        debugPrint('Error creating reservation in Firestore: $e');
      }
    }

    return reservation;
  }

  Future<List<Reservation>> getUserReservations(String userId) async {
    if (FirebaseInitializer.isFirebaseReady) {
      try {
        final query = await FirebaseFirestore.instance
            .collection('reservations')
            .where('userId', isEqualTo: userId)
            .get()
            .timeout(
              const Duration(seconds: 3),
              onTimeout: () {
                debugPrint('Firestore fetch reservations timed out; using local.');
                return FirebaseFirestore.instance
                    .collection('reservations')
                    .limit(0)
                    .get();
              },
            );
        if (query.docs.isNotEmpty) {
          final items = query.docs
              .map((doc) => Reservation.fromMap(doc.data(), id: doc.id))
              .toList();
          _localReservations
            ..clear()
            ..addAll(items);
          return items;
        }
      } catch (e) {
        debugPrint('Error fetching reservations from Firestore: $e');
      }
    }
    return _localReservations;
  }

  Future<void> markReservationCompleted(String id) async {
    final idx = _localReservations.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _localReservations[idx] =
          _localReservations[idx].copyWith(status: 'completed');
    }
    if (FirebaseInitializer.isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('reservations')
            .doc(id)
            .update({'status': 'completed'}).timeout(
          const Duration(seconds: 3),
          onTimeout: () => debugPrint(
              'Firestore mark reservation completed timed out; updated locally.'),
        );
      } catch (e) {
        debugPrint('Error updating reservation in Firestore: $e');
      }
    }
  }

  Future<void> cancelReservationWithDetails(
    String id, {
    required String reason,
  }) async {
    final now = DateTime.now();
    final idx = _localReservations.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _localReservations[idx] = _localReservations[idx].copyWith(
        status: 'cancelled',
        cancellationReason: reason,
        cancelledAt: now,
      );
    }
    if (FirebaseInitializer.isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('reservations')
            .doc(id)
            .update({
              'status': 'cancelled',
              'cancellationReason': reason,
              'cancelledAt': now.toIso8601String(),
            })
            .timeout(
              const Duration(seconds: 3),
              onTimeout: () => debugPrint(
                  'Firestore cancel reservation timed out; updated locally.'),
            );
      } catch (e) {
        debugPrint('Error cancelling reservation in Firestore: $e');
      }
    }
  }

  Future<void> cancelReservation(String id) async {
    _localReservations.removeWhere((r) => r.id == id);
    if (FirebaseInitializer.isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('reservations')
            .doc(id)
            .delete()
            .timeout(
              const Duration(seconds: 3),
              onTimeout: () => debugPrint('Firestore cancel reservation timed out.'),
            );
      } catch (e) {
        debugPrint('Error deleting reservation from Firestore: $e');
      }
    }
  }
}

