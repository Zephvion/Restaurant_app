import 'package:flutter/foundation.dart';

/// A round category shortcut on the food home screen
/// (Meals, Chicken, Biriyani, Breakfast, Fish, Veg Rice…).
@immutable
class MenuCategory {
  const MenuCategory({required this.name, required this.imageUrl});

  final String name;
  final String imageUrl;
}
