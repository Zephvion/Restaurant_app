import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/meal_plan.dart';
import 'auth_service.dart';
import 'firebase_initializer.dart';
import 'session_manager.dart';

class FoodPlannerService {
  FoodPlannerService._();
  static final FoodPlannerService instance = FoodPlannerService._();

  Future<void> savePlannedMeals(List<PlannedMeal> meals) async {
    // Write-through local persistence
    try {
      final serialized = meals.map((m) => m.toMap()).toList();
      await SessionManager.instance.saveCachedMealPlans(serialized);
    } catch (e) {
      debugPrint('Error caching meal plans locally: $e');
    }

    if (!FirebaseInitializer.isFirebaseReady) return;
    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      for (final meal in meals) {
        final doc = firestore
            .collection('users')
            .doc(uid)
            .collection('meal_plans')
            .doc(meal.id);
        batch.set(doc, meal.toMap());
      }
      await batch.commit().timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Firestore save meal plans note: $e (Meals safely stored in persistent local cache)');
    }
  }

  Future<void> saveCalorieStats(CalorieStats stats) async {
    if (!FirebaseInitializer.isFirebaseReady) return;
    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('preferences')
          .doc('calorie_stats')
          .set(stats.toMap())
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Firestore save calorie stats note: $e');
    }
  }

  Future<List<PlannedMeal>?> fetchUserMealPlans() async {
    // 1. Try Firestore with server and local cache
    if (FirebaseInitializer.isFirebaseReady) {
      final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';

      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('meal_plans')
            .get(const GetOptions(source: Source.serverAndCache))
            .timeout(const Duration(seconds: 2));

        if (snapshot.docs.isNotEmpty) {
          final meals = snapshot.docs
              .map((doc) => PlannedMeal.fromMap(doc.data(), id: doc.id))
              .toList();
          // Update local cache
          await SessionManager.instance
              .saveCachedMealPlans(meals.map((m) => m.toMap()).toList());
          return meals;
        }
      } catch (e) {
        debugPrint('Firestore meal plans note: $e (Using resilient persistent local cache)');
      }
    }

    // 2. Resilient local fallback from persistent session
    final cached = SessionManager.instance.getCachedMealPlans();
    if (cached != null && cached.isNotEmpty) {
      return cached.map((map) => PlannedMeal.fromMap(map)).toList();
    }

    return null;
  }
}
