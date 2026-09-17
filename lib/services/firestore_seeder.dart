import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import 'firebase_initializer.dart';

class FirestoreSeeder {
  static bool _hasSeeded = false;

  /// Checks if Firestore is connected and seeds initial data if collections are empty.
  static Future<void> seedIfEmpty() async {
    if (!FirebaseInitializer.isFirebaseReady || _hasSeeded) return;
    _hasSeeded = true;

    try {
      final firestore = FirebaseFirestore.instance;
      final dishesSnapshot = await firestore.collection('dishes').limit(1).get();

      if (dishesSnapshot.docs.isEmpty) {
        debugPrint('🌱 Seeding initial restaurant catalog into Firestore...');
        final batch = firestore.batch();

        // Seed dishes
        for (final dish in MockData.dishes) {
          final doc = firestore.collection('dishes').doc(dish.id);
          batch.set(doc, dish.toMap());
        }

        // Seed categories
        for (final cat in MockData.categories) {
          final catId = cat.id.isNotEmpty ? cat.id : cat.name.toLowerCase().replaceAll(' ', '_');
          final doc = firestore.collection('categories').doc(catId);
          batch.set(doc, cat.toMap());
        }

        // Seed restaurants
        for (final rest in MockData.restaurants) {
          final doc = firestore.collection('restaurants').doc(rest.id);
          batch.set(doc, rest.toMap());
        }

        // Seed promos
        for (int i = 0; i < MockData.promos.length; i++) {
          final promo = MockData.promos[i];
          final doc = firestore.collection('promos').doc('promo_$i');
          batch.set(doc, promo.toMap());
        }

        await batch.commit();
        debugPrint('✅ Initial catalog seeded successfully to Firestore!');
      }
    } catch (e) {
      debugPrint('⚠️ Firestore seeding note: $e');
    }
  }
}
