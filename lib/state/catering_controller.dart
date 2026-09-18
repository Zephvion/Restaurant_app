import 'package:flutter/foundation.dart';

import '../models/catering_order.dart';
import '../models/restaurant.dart';
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
    Restaurant? restaurant,
    String timeSlot = 'Lunch (12:00 PM – 3:30 PM)',
    String eventType = 'Corporate Buffet',
    String menuPackage = 'Royal Malabar Feast',
    double pricePerPlate = 450.0,
    String venueAddress = 'Palazhi, Calicut',
    String specialInstructions = '',
    String contactPhone = '+91 9874563210',
  }) async {
    final order = await CateringService.instance.placeCateringOrder(
      date: date,
      guestRange: guestRange,
      restaurant: restaurant,
      timeSlot: timeSlot,
      eventType: eventType,
      menuPackage: menuPackage,
      pricePerPlate: pricePerPlate,
      venueAddress: venueAddress,
      specialInstructions: specialInstructions,
      contactPhone: contactPhone,
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
