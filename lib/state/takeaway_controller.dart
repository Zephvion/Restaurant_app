import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/dish.dart';
import '../models/restaurant.dart';
import '../models/takeaway_order.dart';
import '../services/auth_service.dart';
import '../services/gps_detection_service.dart';
import '../services/location_service.dart';
import '../services/session_manager.dart';
import '../services/takeaway_service.dart';

/// Singleton [ChangeNotifier] for managing the Take Away flow:
/// - Selecting a branch
/// - Managing the takeaway basket
/// - Placing takeaway orders & tracking order statuses
class TakeawayController extends ChangeNotifier {
  TakeawayController._() {
    _init();
  }
  static final TakeawayController instance = TakeawayController._();

  final List<TakeawayOrder> _orders = [];
  final Map<String, CartItem> _cart = {};
  Restaurant? _selectedRestaurant;

  List<TakeawayOrder> get orders => List.unmodifiable(_orders);
  bool get hasNoOrders => _orders.isEmpty;

  Restaurant? get selectedRestaurant => _selectedRestaurant;

  /// Returns the selected restaurant or dynamically resolves the nearest one.
  Restaurant get activeRestaurant {
    if (_selectedRestaurant != null) return _selectedRestaurant!;
    final userAddr = SessionManager.instance.getSelectedAddress() ??
        GpsDetectionService.instance.lastDetectedAddress;
    final lat = userAddr?.lat ?? 12.9753;
    final lng = userAddr?.lng ?? 77.5910;
    final nearest = LocationService.instance.getNearestRestaurant(lat: lat, lng: lng);
    _selectedRestaurant = nearest;
    return nearest;
  }

  /// Calculates straight-line distance to the active restaurant in km.
  double get distanceToSelectedKm {
    final rest = activeRestaurant;
    final userAddr = SessionManager.instance.getSelectedAddress() ??
        GpsDetectionService.instance.lastDetectedAddress;
    final lat = userAddr?.lat ?? 12.9753;
    final lng = userAddr?.lng ?? 77.5910;
    return LocationService.instance.calculateDistanceKm(
      startLat: lat,
      startLng: lng,
      endLat: rest.lat,
      endLng: rest.lng,
    );
  }

  Future<void> _init() async {
    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';
    final items = await TakeawayService.instance.getUserTakeaways(uid);
    _orders
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  void selectRestaurant(Restaurant restaurant) {
    _selectedRestaurant = restaurant;
    notifyListeners();
  }

  // ── Basket Management ───────────────────────────────────────────────────────

  List<CartItem> get cartItems => _cart.values.toList(growable: false);

  int get totalQuantity =>
      _cart.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _cart.values.fold(0.0, (sum, item) => sum + item.lineTotal);

  double get grandTotal => totalPrice;

  bool get isCartEmpty => _cart.isEmpty;

  bool contains(Dish dish) => _cart.containsKey(dish.id);

  int quantityOf(Dish dish) => _cart[dish.id]?.quantity ?? 0;

  void add(Dish dish) {
    if (_cart.containsKey(dish.id)) {
      _cart[dish.id]!.quantity += 1;
    } else {
      _cart[dish.id] = CartItem(dish: dish, quantity: 1);
    }
    notifyListeners();
  }

  void increment(Dish dish) => add(dish);

  void decrement(Dish dish) {
    final existing = _cart[dish.id];
    if (existing == null) return;
    if (existing.quantity <= 1) {
      _cart.remove(dish.id);
    } else {
      existing.quantity -= 1;
    }
    notifyListeners();
  }

  void remove(Dish dish) {
    if (_cart.remove(dish.id) != null) {
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void setQuantity(Dish dish, int quantity) {
    if (quantity <= 0) {
      _cart.remove(dish.id);
    } else if (_cart.containsKey(dish.id)) {
      _cart[dish.id]!.quantity = quantity;
    } else {
      _cart[dish.id] = CartItem(dish: dish, quantity: quantity);
    }
    notifyListeners();
  }

  // ── Place Order ─────────────────────────────────────────────────────────────

  Future<TakeawayOrder> placeOrder({
    Restaurant? restaurantOverride,
    String paymentMethod = 'UPI (Google Pay)',
    String? transactionId,
  }) async {
    final restaurant = restaurantOverride ?? activeRestaurant;

    final order = await TakeawayService.instance.placeTakeawayOrder(
      restaurant: restaurant,
      items: _cart.values.toList(),
      paymentMethod: paymentMethod,
      transactionId: transactionId,
    );

    _orders.insert(0, order);
    _cart.clear();
    notifyListeners();
    return order;
  }

  /// Adds an externally created takeaway order (e.g. from global cart checkout)
  void addDirectOrder(TakeawayOrder order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  Future<TakeawayOrder?> cancelOrder(
    String orderId, {
    required String reason,
  }) async {
    final updated = await TakeawayService.instance.cancelTakeawayOrder(
      orderId,
      reason: reason,
    );
    if (updated != null) {
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        _orders[idx] = updated;
        notifyListeners();
      }
    }
    return updated;
  }

  void reorder(TakeawayOrder order) {
    _selectedRestaurant = order.restaurant;
    for (final item in order.items) {
      if (_cart.containsKey(item.dish.id)) {
        _cart[item.dish.id]!.quantity += item.quantity;
      } else {
        _cart[item.dish.id] = CartItem(dish: item.dish, quantity: item.quantity);
      }
    }
    notifyListeners();
  }
}
