import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/app_notification.dart';
import '../models/meal_plan.dart';
import '../routes/app_routes.dart';
import '../state/food_planner_controller.dart';
import 'auth_service.dart';
import 'firebase_initializer.dart';

class NotificationService extends ChangeNotifier {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  List<AppNotification> _cachedNotifications = [];
  final StreamController<List<AppNotification>> _streamController =
      StreamController<List<AppNotification>>.broadcast();

  List<AppNotification> get notifications =>
      _cachedNotifications.isNotEmpty ? _cachedNotifications : MockData.notifications;

  int get unreadCount => notifications.where((n) => !n.read).length;

  Future<void> init() async {
    _cachedNotifications = List.from(MockData.notifications);
    _streamController.add(notifications);
  }

  Stream<List<AppNotification>> streamNotifications() {
    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';

    if (FirebaseInitializer.isFirebaseReady) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final items = snapshot.docs
              .map((doc) => AppNotification.fromMap(doc.data(), id: doc.id))
              .toList();
          _cachedNotifications = items;
          _streamController.add(items);
          notifyListeners();
        }
      });
    }

    // Return the reactive broadcast stream seeded with current notifications
    Timer.run(() {
      if (!_streamController.isClosed) {
        _streamController.add(notifications);
      }
    });

    return _streamController.stream;
  }

  Future<void> addNotification(AppNotification notification) async {
    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';
    
    // If notification with same id already exists, replace it
    final existingIndex = _cachedNotifications.indexWhere((n) => n.id == notification.id);
    if (existingIndex >= 0) {
      _cachedNotifications[existingIndex] = notification;
    } else {
      _cachedNotifications.insert(0, notification);
    }

    _streamController.add(notifications);
    notifyListeners();

    if (FirebaseInitializer.isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .doc(notification.id.isNotEmpty ? notification.id : null)
            .set(notification.toMap());
      } catch (e) {
        debugPrint('Error adding notification to Firestore: $e');
      }
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _cachedNotifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _cachedNotifications[index] = _cachedNotifications[index].copyWith(read: true);
      _streamController.add(notifications);
      notifyListeners();

      final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';
      if (FirebaseInitializer.isFirebaseReady) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('notifications')
              .doc(id)
              .update({'read': true});
        } catch (_) {}
      }
    }
  }

  Future<void> markAllAsRead() async {
    _cachedNotifications = _cachedNotifications
        .map((n) => n.copyWith(read: true))
        .toList();
    _streamController.add(notifications);
    notifyListeners();

    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';
    if (FirebaseInitializer.isFirebaseReady) {
      try {
        final batch = FirebaseFirestore.instance.batch();
        final col = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications');
        final snap = await col.where('read', isEqualTo: false).get();
        for (final doc in snap.docs) {
          batch.update(doc.reference, {'read': true});
        }
        await batch.commit();
      } catch (_) {}
    }
  }

  Future<void> deleteNotification(String id) async {
    _cachedNotifications.removeWhere((n) => n.id == id);
    _streamController.add(notifications);
    notifyListeners();

    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';
    if (FirebaseInitializer.isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .doc(id)
            .delete();
      } catch (_) {}
    }
  }

  /// Evaluates the user's current meal plan state in [FoodPlannerController]
  /// and dynamically creates/updates relevant notifications and reminders.
  void generateContextualPlannerReminders(FoodPlannerController ctrl) {
    final todayLunch = ctrl.getMealsForSlot(0, MealType.lunch);
    final todayDinner = ctrl.getMealsForSlot(0, MealType.dinner);
    final todayCalories = ctrl.getDayCalories(0);
    final budget = ctrl.dailyCalorieBudget;

    // 1. Lunch reminder if unlogged
    if (todayLunch.isEmpty) {
      addNotification(
        const AppNotification(
          id: 'notif_today_lunch',
          title: "Don't forget today's Lunch! 🍛",
          message:
              'Your lunch slot for today is currently empty. Add healthy Kerala specials to stay on track with your macros.',
          category: 'MEAL REMINDER',
          iconName: 'meal',
          actionLabel: 'Log Lunch',
          actionRoute: AppRoutes.foodPlannerMenu,
          actionMealType: 'lunch',
          read: false,
        ),
      );
    }

    // 2. Dinner reminder if unlogged
    if (todayDinner.isEmpty) {
      addNotification(
        const AppNotification(
          id: 'notif_today_dinner',
          title: "Plan Ahead: Tonight's Dinner 🌙",
          message:
              'Schedule your dinner dishes in advance to hit your protein target and avoid late-night impulse ordering.',
          category: 'MEAL REMINDER',
          iconName: 'meal',
          actionLabel: 'Plan Dinner',
          actionRoute: AppRoutes.foodPlannerMenu,
          actionMealType: 'dinner',
          read: false,
        ),
      );
    }

    // 3. Calorie progress update
    if (todayCalories > 0) {
      final isUnder = todayCalories <= budget;
      final diff = (budget - todayCalories).abs();
      addNotification(
        AppNotification(
          id: 'notif_calorie_progress',
          title: 'Daily Progress: $todayCalories / $budget kcal 🎯',
          message: isUnder
              ? "Looking good! You have $diff kcal remaining for today's intake."
              : "Calorie target exceeded by $diff kcal today. Check your macro distribution in the calculator.",
          category: 'CALORIE GOAL',
          iconName: 'fire',
          actionLabel: 'View Macro Stats',
          actionRoute: AppRoutes.foodPlannerCalculator,
          read: false,
        ),
      );
    }
  }
}
