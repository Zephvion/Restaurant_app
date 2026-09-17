import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/dish.dart';
import '../models/menu_category.dart';
import '../models/promo_banner.dart';
import '../models/restaurant.dart';
import 'firebase_initializer.dart';
import 'firestore_seeder.dart';

class MenuService {
  MenuService._();
  static final MenuService instance = MenuService._();

  List<Dish> _cachedDishes = [];
  List<MenuCategory> _cachedCategories = [];
  List<Restaurant> _cachedRestaurants = [];
  List<PromoBanner> _cachedPromos = [];

  Future<void> init() async {
    await FirestoreSeeder.seedIfEmpty();
    await fetchAll();
  }

  Future<void> fetchAll() async {
    if (FirebaseInitializer.isFirebaseReady) {
      try {
        final firestore = FirebaseFirestore.instance;

        // Fetch Dishes
        final dishesSnapshot = await firestore.collection('dishes').get();
        if (dishesSnapshot.docs.isNotEmpty) {
          _cachedDishes = dishesSnapshot.docs
              .map((doc) => Dish.fromMap(doc.data(), id: doc.id))
              .toList();
        } else {
          _cachedDishes = List.from(MockData.dishes);
        }

        // Fetch Restaurants
        final restSnapshot = await firestore.collection('restaurants').get();
        if (restSnapshot.docs.isNotEmpty) {
          _cachedRestaurants = restSnapshot.docs
              .map((doc) => Restaurant.fromMap(doc.data(), id: doc.id))
              .toList();
        } else {
          _cachedRestaurants = List.from(MockData.restaurants);
        }

        _cachedCategories = List.from(MockData.categories);
        _cachedPromos = List.from(MockData.promos);
        return;
      } catch (e) {
        debugPrint('Error fetching menu from Firestore: $e');
      }
    }

    _cachedDishes = List.from(MockData.dishes);
    _cachedCategories = List.from(MockData.categories);
    _cachedRestaurants = List.from(MockData.restaurants);
    _cachedPromos = List.from(MockData.promos);
  }

  List<Dish> get dishes => _cachedDishes.isNotEmpty ? _cachedDishes : MockData.dishes;

  List<MenuCategory> get categories =>
      _cachedCategories.isNotEmpty ? _cachedCategories : MockData.categories;

  List<Restaurant> get restaurants =>
      _cachedRestaurants.isNotEmpty ? _cachedRestaurants : MockData.restaurants;

  List<PromoBanner> get promoBanners =>
      _cachedPromos.isNotEmpty ? _cachedPromos : MockData.promos;

  List<Dish> getDishesByCategory(String categoryName) {
    if (categoryName.toLowerCase() == 'all') return dishes;
    return dishes.where((d) => d.category.toLowerCase() == categoryName.toLowerCase()).toList();
  }

  List<Dish> searchDishes(String query) {
    if (query.trim().isEmpty) return dishes;
    final q = query.toLowerCase();
    return dishes.where((d) {
      return d.name.toLowerCase().contains(q) ||
          d.category.toLowerCase().contains(q) ||
          d.description.toLowerCase().contains(q);
    }).toList();
  }

  Dish? findDishById(String id) {
    try {
      return dishes.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
