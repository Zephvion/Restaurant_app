import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/address.dart';
import '../models/cart_item.dart';
import '../models/dish.dart';
import '../models/order_model.dart';
import '../models/payment_method.dart';
import '../services/location_service.dart';
import '../services/order_service.dart';
import '../services/session_manager.dart';

/// In-app basket + checkout state for the Order Food flow.
///
/// This is a tiny hand-rolled store (a [ChangeNotifier] singleton) so the build
/// stays dependency-free. Screens listen with `AnimatedBuilder(animation:
/// CartController.instance, …)` and rebuild when the basket changes.
class CartController extends ChangeNotifier {
  CartController._() {
    _initFromSession();
  }

  /// Shared, app-wide instance.
  static final CartController instance = CartController._();

  final List<CartItem> _items = [];

  /// Currently selected delivery address (defaults to the first saved one).
  /// Currently selected delivery address.
  Address selectedAddress = MockData.addresses.first;

  /// Currently selected payment method (defaults to the first saved card).
  /// Currently selected payment method.
  PaymentMethod selectedPayment = MockData.paymentMethods.first;

  /// An applied coupon code, if any.
  String? appliedCoupon;

  void _initFromSession() {
    final cachedAddr = SessionManager.instance.getSelectedAddress();
    if (cachedAddr != null) {
      selectedAddress = cachedAddr;
    }
  }

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  /// Number of distinct dishes in the basket (drives the cart badge).
  /// Number of distinct dishes in the basket.
  int get distinctCount => _items.length;

  /// Total number of units across all dishes.
  int get totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  /// How many of [dish] are currently in the basket (0 if none).
  int quantityOf(Dish dish) {
    for (final item in _items) {
      if (item.dish.id == dish.id) return item.quantity;
    }
    return 0;
  }

  bool contains(Dish dish) => quantityOf(dish) > 0;

  void add(Dish dish, {int qty = 1}) {
    final existing = _find(dish);
    if (existing != null) {
      existing.quantity += qty;
    } else {
      _items.add(CartItem(dish: dish, quantity: qty));
    }
    notifyListeners();
  }

  void increment(Dish dish) => add(dish);

  void decrement(Dish dish) {
    final existing = _find(dish);
    if (existing == null) return;
    existing.quantity -= 1;
    if (existing.quantity <= 0) {
      _items.remove(existing);
    }
    notifyListeners();
  }

  /// Sets an absolute quantity (used by the product screen stepper). A value of
  /// 0 removes the dish.
  void setQuantity(Dish dish, int quantity) {
    final existing = _find(dish);
    if (quantity <= 0) {
      if (existing != null) _items.remove(existing);
    } else if (existing != null) {
      existing.quantity = quantity;
    } else {
      _items.add(CartItem(dish: dish, quantity: quantity));
    }
    notifyListeners();
  }

  void remove(Dish dish) {
    _items.removeWhere((item) => item.dish.id == dish.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    appliedCoupon = null;
    notifyListeners();
  }

  void selectAddress(Address address) {
    selectedAddress = address;
    SessionManager.instance.saveSelectedAddress(address);
    notifyListeners();
  }

  void selectPayment(PaymentMethod method) {
    selectedPayment = method;
    notifyListeners();
  }

  void applyCoupon(String? code) {
    appliedCoupon = code;
    notifyListeners();
  }

  // ---- Money -------------------------------------------------------------

  /// Sum of every line total.
  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.lineTotal);

  /// Flat GST at 15% of the subtotal (mock, rounded to whole rupees).
  /// Flat GST at 15% of the subtotal.
  double get gst => (subtotal * 0.15).roundToDouble();

  /// Delivery partner fee calculated dynamically based on distance.
  double get deliveryFee => isEmpty
      ? 0
      : LocationService.instance.calculateDeliveryFee(selectedAddress);

  /// A small mock discount applied when any coupon is active.
  double get discount =>
      appliedCoupon == null ? 0 : (subtotal * 0.10).roundToDouble();

  double get grandTotal => subtotal + gst + deliveryFee - discount;

  /// Places order via [OrderService] and clears cart
  Future<OrderModel> checkout() async {
    final order = await OrderService.instance.placeOrder(
      items: List.from(_items),
      address: selectedAddress,
      payment: selectedPayment,
      subtotal: subtotal,
      gst: gst,
      deliveryFee: deliveryFee,
      discount: discount,
      grandTotal: grandTotal,
      coupon: appliedCoupon,
    );
    clear();
    return order;
  }

  CartItem? _find(Dish dish) {
    for (final item in _items) {
      if (item.dish.id == dish.id) return item;
    }
    return null;
  }
}
