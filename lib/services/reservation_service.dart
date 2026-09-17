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
    );

    _localReservations.insert(0, reservation);

    if (FirebaseInitializer.isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('reservations')
            .doc(reservationId)
            .set(reservation.toMap());
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
            .get();
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

  Future<void> cancelReservation(String id) async {
    _localReservations.removeWhere((r) => r.id == id);
    if (FirebaseInitializer.isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('reservations')
            .doc(id)
            .delete();
      } catch (e) {
        debugPrint('Error deleting reservation from Firestore: $e');
      }
    }
  }
}

