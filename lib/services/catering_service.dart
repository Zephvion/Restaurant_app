import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/catering_order.dart';
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
  }) async {
    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';
    final randId = 'ID${1000 + DateTime.now().millisecondsSinceEpoch % 9000}';

    final order = CateringOrder(
      id: randId,
      userId: uid,
      date: date,
      guestRange: guestRange,
      status: CateringStatus.notifiedParagon,
      createdAt: DateTime.now(),
    );

    _localOrders.insert(0, order);

    if (FirebaseInitializer.isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('catering_requests')
            .doc(randId)
            .set(order.toMap());
      } catch (e) {
        debugPrint('Error placing catering request in Firestore: $e');
      }
    }

    return order;
  }

  Future<List<CateringOrder>> getUserCateringOrders(String userId) async {
    if (FirebaseInitializer.isFirebaseReady) {
      try {
        final query = await FirebaseFirestore.instance
            .collection('catering_requests')
            .where('userId', isEqualTo: userId)
            .get();
        if (query.docs.isNotEmpty) {
          final items = query.docs
              .map((doc) => CateringOrder.fromMap(doc.data(), id: doc.id))
              .toList();
          _localOrders
            ..clear()
            ..addAll(items);
          return items;
        }
      } catch (e) {
        debugPrint('Error fetching catering orders from Firestore: $e');
      }
    }
    return _localOrders;
  }

  Future<void> cancelOrder(String id) async {
    _localOrders.removeWhere((o) => o.id == id);
    if (FirebaseInitializer.isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('catering_requests')
            .doc(id)
            .delete();
      } catch (e) {
        debugPrint('Error deleting catering request from Firestore: $e');
      }
    }
  }
}

