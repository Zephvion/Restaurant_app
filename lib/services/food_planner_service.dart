import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/meal_plan.dart';
import 'auth_service.dart';
import 'firebase_initializer.dart';

class FoodPlannerService {
  FoodPlannerService._();
  static final FoodPlannerService instance = FoodPlannerService._();

  Future<void> savePlannedMeals(List<PlannedMeal> meals) async {
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
      await batch.commit();
    } catch (e) {
      debugPrint('Error saving meal plans to Firestore: $e');
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
          .set(stats.toMap());
    } catch (e) {
      debugPrint('Error saving calorie stats to Firestore: $e');
    }
  }

  Future<List<PlannedMeal>?> fetchUserMealPlans() async {
    if (!FirebaseInitializer.isFirebaseReady) return null;
    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('meal_plans')
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => PlannedMeal.fromMap(doc.data(), id: doc.id))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching meal plans from Firestore: $e');
    }
    return null;
  }
}

