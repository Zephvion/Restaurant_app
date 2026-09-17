import 'package:flutter/foundation.dart';

import '../models/catering_order.dart';
import '../services/auth_service.dart';
import '../services/catering_service.dart';

/// Singleton [ChangeNotifier] for managing Catering requests & orders.
class CateringController extends ChangeNotifier {
  CateringController._() {
    _init();
  }
  static final CateringController instance = CateringController._();

  final List<CateringOrder> _orders = [];

  List<CateringOrder> get orders => List.unmodifiable(_orders);
  bool get hasNoOrders => _orders.isEmpty;

  Future<void> _init() async {
    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';
    final items = await CateringService.instance.getUserCateringOrders(uid);
    _orders
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  Future<CateringOrder> placeOrder({
    required DateTime date,
    required String guestRange,
  }) async {
    final order = await CateringService.instance.placeCateringOrder(
      date: date,
      guestRange: guestRange,
    );

    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  Future<void> cancelOrder(String id) async {
    await CateringService.instance.cancelOrder(id);
    _orders.removeWhere((o) => o.id == id);
    notifyListeners();
  }
}
