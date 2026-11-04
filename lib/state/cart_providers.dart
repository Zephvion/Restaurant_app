import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import 'cart_controller.dart';

/// Provides the existing app-wide cart controller.
final cartControllerProvider = ChangeNotifierProvider<CartController>((ref) {
  return CartController.instance;
});

/// Provides the current cart items and rebuilds when the cart changes.
final cartItemsProvider = Provider<List<CartItem>>((ref) {
  return ref.watch(cartControllerProvider).items;
});

/// Provides the number of distinct dishes in the cart.
final cartDistinctCountProvider = Provider<int>((ref) {
  return ref.watch(cartControllerProvider).distinctCount;
});

/// Provides the total number of units in the cart.
final cartTotalQuantityProvider = Provider<int>((ref) {
  return ref.watch(cartControllerProvider).totalQuantity;
});

/// Provides the current cart subtotal.
final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartControllerProvider).subtotal;
});

/// Provides the current checkout total.
final cartGrandTotalProvider = Provider<double>((ref) {
  return ref.watch(cartControllerProvider).grandTotal;
});
