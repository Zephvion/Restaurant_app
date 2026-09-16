import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/catering_order.dart';

/// Singleton [ChangeNotifier] for managing Catering requests & orders.
class CateringController extends ChangeNotifier {
  CateringController._();
  static final CateringController instance = CateringController._();

  final List<CateringOrder> _orders = [];

  List<CateringOrder> get orders => List.unmodifiable(_orders);
  bool get hasNoOrders => _orders.isEmpty;

  CateringOrder placeOrder({
    required DateTime date,
    required String guestRange,
  }) {
    final randId = 'ID${1000 + Random().nextInt(9000)}';
    final order = CateringOrder(
      id: randId,
      date: date,
      guestRange: guestRange,
      status: CateringStatus.notifiedParagon,
      createdAt: DateTime.now(),
    );

    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  void cancelOrder(String id) {
    _orders.removeWhere((o) => o.id == id);
    notifyListeners();
  }
}
