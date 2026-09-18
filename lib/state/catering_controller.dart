import 'package:flutter/foundation.dart';

import '../models/catering_order.dart';
import '../models/restaurant.dart';
import '../services/auth_service.dart';
import '../services/catering_service.dart';

/// Singleton [ChangeNotifier] for managing Catering requests & orders.
class CateringController extends ChangeNotifier {
  CateringController._() {
    _orders.addAll(CateringService.instance.orders);
    _init();
  }
  static final CateringController instance = CateringController._();

  final List<CateringOrder> _orders = [];

  List<CateringOrder> get orders => List.unmodifiable(_orders);
  bool get hasNoOrders => _orders.isEmpty;

  Future<void> _init() async {
    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';
    final items = await CateringService.instance.getUserCateringOrders(uid);
    for (final item in items) {
      if (!_orders.any((o) => o.id == item.id)) {
        _orders.add(item);
      }
    }
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
    double totalAmount = 0.0,
    String venueAddress = 'Palazhi, Calicut',
    String specialInstructions = '',
    String contactPhone = '+91 9874563210',
    String ownerName = 'Chef Rajesh Kumar (Catering Operations Head)',
    String ownerPhone = '+91 98470 12345',
    String pickupLocation = 'Paragon Central Catering Hub, Mavoor Road, Kozhikode',
  }) async {
    final order = await CateringService.instance.placeCateringOrder(
      date: date,
      guestRange: guestRange,
      restaurant: restaurant,
      timeSlot: timeSlot,
      eventType: eventType,
      menuPackage: menuPackage,
      pricePerPlate: pricePerPlate,
      totalAmount: totalAmount,
      venueAddress: venueAddress,
      specialInstructions: specialInstructions,
      contactPhone: contactPhone,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      pickupLocation: pickupLocation,
    );

    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  Future<void> confirmPayment(
    String id, {
    required String txnId,
    required String paymentMode,
  }) async {
    await CateringService.instance.confirmPayment(
      id,
      txnId: txnId,
      paymentMode: paymentMode,
    );
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx != -1) {
      _orders[idx].isPaid = true;
      _orders[idx].paymentTxnId = txnId;
      _orders[idx].paymentMode = paymentMode;
      _orders[idx].status = CateringStatus.bookingConfirmed;
    }
    notifyListeners();
  }

  Future<void> updateOrderStatus(String id, CateringStatus status) async {
    await CateringService.instance.updateOrderStatus(id, status);
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx != -1) {
      _orders[idx].status = status;
    }
    notifyListeners();
  }

  Future<void> cancelOrder(String id) async {
    await CateringService.instance.cancelOrder(id);
    _orders.removeWhere((o) => o.id == id);
    notifyListeners();
  }
}
