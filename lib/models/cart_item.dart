import 'dish.dart';

/// A [Dish] together with the quantity the user has added to their basket.
class CartItem {
  CartItem({required this.dish, this.quantity = 1});

  final Dish dish;
  int quantity;

  /// Line total for this row (unit price × quantity).
  double get lineTotal => dish.price * quantity;
}
