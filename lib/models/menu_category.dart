import 'package:flutter/foundation.dart';

/// A round category shortcut on the food home screen
/// (Meals, Chicken, Biriyani, Breakfast, Fish, Veg Rice…).
@immutable
class MenuCategory {
  const MenuCategory({
    this.id = '',
    required this.name,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String imageUrl;

  Map<String, dynamic> toMap() => {
        'id': id.isNotEmpty ? id : name.toLowerCase().replaceAll(' ', '_'),
        'name': name,
        'imageUrl': imageUrl,
      };

  factory MenuCategory.fromMap(Map<String, dynamic> map, {String? id}) {
    return MenuCategory(
      id: id ?? (map['id'] as String? ?? ''),
      name: map['name'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
    );
  }
}
