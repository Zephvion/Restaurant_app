import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../models/restaurant.dart';
import '../models/takeaway_order.dart';
import 'takeaway_controller.dart';

/// Provides the existing app-wide takeaway controller.
final takeawayControllerProvider =
    ChangeNotifierProvider<TakeawayController>((ref) {
  return TakeawayController.instance;
});

/// Provides the current takeaway orders.
final takeawayOrdersProvider = Provider<List<TakeawayOrder>>((ref) {
  return ref.watch(takeawayControllerProvider).orders;
});

/// Provides the selected takeaway restaurant.
final selectedTakeawayRestaurantProvider = Provider<Restaurant?>((ref) {
  return ref.watch(takeawayControllerProvider).selectedRestaurant;
});

/// Provides the current takeaway basket items.
final takeawayCartItemsProvider = Provider<List<CartItem>>((ref) {
  return ref.watch(takeawayControllerProvider).cartItems;
});

/// Provides the total quantity in the takeaway basket.
final takeawayCartQuantityProvider = Provider<int>((ref) {
  return ref.watch(takeawayControllerProvider).totalQuantity;
});

/// Provides the total price of the takeaway basket.
final takeawayCartTotalProvider = Provider<double>((ref) {
  return ref.watch(takeawayControllerProvider).totalPrice;
});
