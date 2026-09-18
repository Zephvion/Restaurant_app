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
          final fetched = dishesSnapshot.docs
              .map((doc) => Dish.fromMap(doc.data(), id: doc.id))
              .toList();

          // Sync with MockData to ensure authentic local WebP assets are always respected
          final List<Dish> synced = [];
          final batch = firestore.batch();
          bool hasFirestoreUpdates = false;

          for (final dish in fetched) {
            final mock = MockData.findDishById(dish.id);
            if (mock != null && mock.imageUrl.isNotEmpty) {
              final updated = dish.copyWith(imageUrl: mock.imageUrl);
              synced.add(updated);
              if (dish.imageUrl != mock.imageUrl) {
                batch.update(firestore.collection('dishes').doc(dish.id), {
                  'imageUrl': mock.imageUrl,
                });
                hasFirestoreUpdates = true;
              }
            } else {
              synced.add(dish);
            }
          }

          if (hasFirestoreUpdates) {
            try {
              await batch.commit();
              debugPrint('✅ Updated Firestore dish images to authentic WebP assets');
            } catch (e) {
              debugPrint('Firestore batch image update note: $e');
            }
          }

          // Deduplicate by name
          final seenNames = <String>{};
          _cachedDishes = synced
              .where((d) => seenNames.add(d.name.toLowerCase().trim()))
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
        _cachedPromos = List.from(MockData.promoBanners);
        return;
      } catch (e) {
        debugPrint('Error fetching menu from Firestore: $e');
      }
    }

    _cachedDishes = List.from(MockData.dishes);
    _cachedCategories = List.from(MockData.categories);
    _cachedRestaurants = List.from(MockData.restaurants);
    _cachedPromos = List.from(MockData.promoBanners);
  }

  List<Dish> get dishes {
    final list = _cachedDishes.isNotEmpty ? _cachedDishes : MockData.dishes;
    final seen = <String>{};
    return list.where((d) => seen.add(d.name.toLowerCase().trim())).toList();
  }

  List<MenuCategory> get categories =>
      _cachedCategories.isNotEmpty ? _cachedCategories : MockData.categories;

  List<Restaurant> get restaurants =>
      _cachedRestaurants.isNotEmpty ? _cachedRestaurants : MockData.restaurants;

  List<PromoBanner> get promoBanners =>
      _cachedPromos.isNotEmpty ? _cachedPromos : MockData.promoBanners;

  List<Dish> getDishesByCategory(String categoryName) {
    return MockData.getDishesForCategory(categoryName);
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
      return MockData.findDishById(id);
    }
  }
}

