import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/dish.dart';
import '../models/restaurant.dart';
import '../models/takeaway_order.dart';

/// Singleton [ChangeNotifier] for managing the Take Away flow:
/// - Selecting a branch
/// - Managing the takeaway basket
/// - Placing takeaway orders & tracking order statuses
class TakeawayController extends ChangeNotifier {
  TakeawayController._();
  static final TakeawayController instance = TakeawayController._();

  final List<TakeawayOrder> _orders = [];
  final Map<String, CartItem> _cart = {};
  Restaurant? _selectedRestaurant;

  List<TakeawayOrder> get orders => List.unmodifiable(_orders);
  bool get hasNoOrders => _orders.isEmpty;

  Restaurant? get selectedRestaurant => _selectedRestaurant;

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

  // ── Place Order ─────────────────────────────────────────────────────────────

  TakeawayOrder placeOrder({Restaurant? restaurantOverride}) {
    final restaurant = restaurantOverride ?? _selectedRestaurant;
    if (restaurant == null) {
      throw StateError('Cannot place takeaway order without a selected restaurant');
    }

    final randId = 'ID${1000 + Random().nextInt(9000)}';
    final order = TakeawayOrder(
      id: randId,
      restaurant: restaurant,
      items: _cart.values.toList(),
      status: TakeawayStatus.readyForTakeaway,
      createdAt: DateTime.now(),
    );

    _orders.insert(0, order);
    _cart.clear();
    notifyListeners();
    return order;
  }
}
