import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/restaurant.dart';
import '../models/takeaway_order.dart';
import 'auth_service.dart';
import 'firebase_initializer.dart';

class TakeawayService {
  TakeawayService._();
  static final TakeawayService instance = TakeawayService._();

  final List<TakeawayOrder> _localTakeaways = [];

  List<TakeawayOrder> get orders => List.unmodifiable(_localTakeaways);

  Future<TakeawayOrder> placeTakeawayOrder({
    required Restaurant restaurant,
    required List<CartItem> items,
  }) async {
    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';
    final orderId = 'TK${1000 + DateTime.now().millisecondsSinceEpoch % 9000}';

    final order = TakeawayOrder(
      id: orderId,
      userId: uid,
      restaurant: restaurant,
      items: items,
      status: TakeawayStatus.readyForTakeaway,
    );

    _localTakeaways.insert(0, order);

    if (FirebaseInitializer.isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('takeaways')
            .doc(orderId)
            .set(order.toMap())
            .timeout(const Duration(seconds: 2));
      } catch (e) {
        debugPrint('Error placing takeaway in Firestore: $e');
      }
    }

    return order;
  }

  Future<List<TakeawayOrder>> getUserTakeaways(String userId) async {
    if (FirebaseInitializer.isFirebaseReady) {
      try {
        final query = await FirebaseFirestore.instance
            .collection('takeaways')
            .where('userId', isEqualTo: userId)
            .get()
            .timeout(const Duration(seconds: 2));
        if (query.docs.isNotEmpty) {
          final items = query.docs
              .map((doc) => TakeawayOrder.fromMap(doc.data(), id: doc.id))
              .toList();
          _localTakeaways
            ..clear()
            ..addAll(items);
          return items;
        }
      } catch (e) {
        debugPrint('Error fetching takeaways from Firestore: $e');
      }
    }
    return _localTakeaways;
  }
}

