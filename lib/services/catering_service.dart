import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/catering_order.dart';
import '../models/restaurant.dart';
import 'auth_service.dart';
import 'firebase_initializer.dart';

class CateringService {
  CateringService._();
  static final CateringService instance = CateringService._();

  final List<CateringOrder> _localOrders = [];

  List<CateringOrder> get orders => List.unmodifiable(_localOrders);

  Future<CateringOrder> placeCateringOrder({
    required DateTime date,
    required String guestRange,
    Restaurant? restaurant,
    String timeSlot = 'Lunch (12:00 PM – 3:30 PM)',
    String eventType = 'Corporate Buffet',
    String menuPackage = 'Royal Malabar Feast',
    double pricePerPlate = 450.0,
    double totalAmount = 0.0,
    String venueAddress = 'Palazhi, Calicut',
    String specialInstructions = '',
    String contactPhone = '+91 9874563210',
    String ownerName = 'Chef Rajesh Kumar (Catering Operations Head)',
    String ownerPhone = '+91 98470 12345',
    String pickupLocation = 'Paragon Central Catering Hub, Mavoor Road, Kozhikode',
  }) async {
    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';
    final randId = 'CAT-${1000 + DateTime.now().millisecondsSinceEpoch % 9000}';

    final order = CateringOrder(
      id: randId,
      userId: uid,
      restaurantId: restaurant?.id ?? 'rest_calicut',
      restaurantName: restaurant?.name ?? 'Paragon Restaurant - Calicut',
      branchLocation: restaurant?.address ?? 'Mavoor Road, Calicut',
      pickupLocation: pickupLocation,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      date: date,
      timeSlot: timeSlot,
      guestRange: guestRange,
      eventType: eventType,
      menuPackage: menuPackage,
      pricePerPlate: pricePerPlate,
      totalAmount: totalAmount,
      venueAddress: venueAddress,
      specialInstructions: specialInstructions,
      contactPhone: contactPhone,
      status: CateringStatus.notifiedParagon,
      createdAt: DateTime.now(),
    );

    _localOrders.insert(0, order);

    if (FirebaseInitializer.isFirebaseReady) {
      // Non-blocking background sync with timeout so it never blocks UI navigation
      FirebaseFirestore.instance
          .collection('catering_requests')
          .doc(randId)
          .set(order.toMap())
          .timeout(const Duration(seconds: 2))
          .catchError((e) {
        debugPrint('Firestore catering sync offline note: $e');
      });
    }

    return order;
  }

  Future<void> confirmPayment(
    String id, {
    required String txnId,
    required String paymentMode,
  }) async {
    final idx = _localOrders.indexWhere((o) => o.id == id);
    if (idx != -1) {
      _localOrders[idx].isPaid = true;
      _localOrders[idx].paymentTxnId = txnId;
      _localOrders[idx].paymentMode = paymentMode;
      _localOrders[idx].status = CateringStatus.bookingConfirmed;
    }

    if (FirebaseInitializer.isFirebaseReady) {
      FirebaseFirestore.instance
          .collection('catering_requests')
          .doc(id)
          .update({
        'isPaid': true,
        'paymentTxnId': txnId,
        'paymentMode': paymentMode,
        'status': CateringStatus.bookingConfirmed.name,
      }).timeout(const Duration(seconds: 2)).catchError((e) {
        debugPrint('Error updating payment in Firestore: $e');
      });
    }
  }

  Future<void> updateOrderStatus(String id, CateringStatus status) async {
    final idx = _localOrders.indexWhere((o) => o.id == id);
    if (idx != -1) {
      _localOrders[idx].status = status;
    }

    if (FirebaseInitializer.isFirebaseReady) {
      FirebaseFirestore.instance
          .collection('catering_requests')
          .doc(id)
          .update({'status': status.name})
          .timeout(const Duration(seconds: 2))
          .catchError((e) {
        debugPrint('Error updating status in Firestore: $e');
      });
    }
  }

  Future<List<CateringOrder>> getUserCateringOrders(String userId) async {
    if (FirebaseInitializer.isFirebaseReady) {
      try {
        final query = await FirebaseFirestore.instance
            .collection('catering_requests')
            .where('userId', isEqualTo: userId)
            .get()
            .timeout(const Duration(seconds: 2));
        final items = query.docs
            .map((doc) => CateringOrder.fromMap(doc.data(), id: doc.id))
            .toList();
        _localOrders
          ..clear()
          ..addAll(items);
        return items;
      } catch (e) {
        debugPrint('Error fetching catering orders from Firestore: $e');
      }
    }
    return _localOrders.where((o) => o.userId == userId).toList();
  }

  Future<void> cancelOrder(String id) async {
    _localOrders.removeWhere((o) => o.id == id);
    if (FirebaseInitializer.isFirebaseReady) {
      FirebaseFirestore.instance
          .collection('catering_requests')
          .doc(id)
          .delete()
          .timeout(const Duration(seconds: 2))
          .catchError((e) {
        debugPrint('Error deleting catering request from Firestore: $e');
      });
    }
  }
}
