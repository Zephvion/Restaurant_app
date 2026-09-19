import 'package:flutter/foundation.dart';

/// Available sorting options for dish menus.
enum DishSortOption {
  popularity,
  priceLowHigh,
  priceHighLow,
  rating,
}

/// A single menu item (dish) shown across the Order Food flow.
///
/// Frontend-only build: every field is populated from in-app mock data
/// (see `lib/data/mock_data.dart`).
@immutable
class Dish {
  const Dish({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.oldPrice,
    this.kcal = 320,
    this.grams = 300,
    this.isVeg = true,
    this.rating = 4.7,
    this.category = 'Frequent order',
    this.description =
        'Freshly prepared to order using time-honoured recipes and locally '
        'sourced ingredients. Served hot and ready to enjoy.',
    this.ingredients = const [],
    this.carbs = 45,
    this.fat = 12,
    this.protein = 8,
    this.prepTimeMinutes = 15,
    this.subtitle,
  });

  final String id;
  final String name;

  /// Optional line under the name in list rows (e.g. "2 nos").
  final String? subtitle;

  /// Current selling price in rupees.
  final double price;

  /// Original price, struck through when present (e.g. ₹100 → ₹80).
  final double? oldPrice;

  final String imageUrl;

  /// Energy in kilocalories, shown in the small pill badge.
  final int kcal;

  /// Serving weight in grams, shown in the small pill badge.
  final int grams;

  /// Veg (green dot) vs non-veg (red dot).
  final bool isVeg;

  final double rating;

  /// Menu category this dish belongs to (matches a tab / circle name).
  final String category;

  final String description;

  /// Bullet-point ingredient list on the product screen.
  final List<String> ingredients;

  // Macro-nutrients shown as pills on the product screen.
  final int carbs;
  final int fat;
  final int protein;

  /// Kitchen preparation time in minutes.
  final int prepTimeMinutes;

  /// Whether a discount is active (drives the strikethrough price display).
  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'subtitle': subtitle,
        'price': price,
        'oldPrice': oldPrice,
        'imageUrl': imageUrl,
        'kcal': kcal,
        'grams': grams,
        'isVeg': isVeg,
        'rating': rating,
        'category': category,
        'description': description,
        'ingredients': ingredients,
        'carbs': carbs,
        'fat': fat,
        'protein': protein,
        'prepTimeMinutes': prepTimeMinutes,
      };

  factory Dish.fromMap(Map<String, dynamic> map, {String? id}) {
    return Dish(
      id: id ?? (map['id'] as String? ?? ''),
      name: map['name'] as String? ?? '',
      subtitle: map['subtitle'] as String?,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: (map['oldPrice'] as num?)?.toDouble(),
      imageUrl: map['imageUrl'] as String? ?? '',
      kcal: (map['kcal'] as num?)?.toInt() ?? 320,
      grams: (map['grams'] as num?)?.toInt() ?? 300,
      isVeg: map['isVeg'] as bool? ?? true,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.7,
      category: map['category'] as String? ?? 'Frequent order',
      description: map['description'] as String? ?? '',
      ingredients: (map['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      carbs: (map['carbs'] as num?)?.toInt() ?? 45,
      fat: (map['fat'] as num?)?.toInt() ?? 12,
      protein: (map['protein'] as num?)?.toInt() ?? 8,
      prepTimeMinutes: (map['prepTimeMinutes'] as num?)?.toInt() ?? 15,
    );
  }

  Dish copyWith({
    String? id,
    String? name,
    String? subtitle,
    double? price,
    double? oldPrice,
    String? imageUrl,
    int? kcal,
    int? grams,
    bool? isVeg,
    double? rating,
    String? category,
    String? description,
    List<String>? ingredients,
    int? carbs,
    int? fat,
    int? protein,
    int? prepTimeMinutes,
  }) {
    return Dish(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      kcal: kcal ?? this.kcal,
      grams: grams ?? this.grams,
      isVeg: isVeg ?? this.isVeg,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      protein: protein ?? this.protein,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
    );
  }
}
