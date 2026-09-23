import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/app_notification.dart';
import '../models/meal_plan.dart';
import '../routes/app_routes.dart';
import '../state/food_planner_controller.dart';
import 'auth_service.dart';
import 'firebase_initializer.dart';

/// Top-level background message handler for FCM push notifications
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📱 [FCM Background] Title: ${message.notification?.title}, Body: ${message.notification?.body}');
}

class NotificationService extends ChangeNotifier {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  List<AppNotification> _cachedNotifications = [];
  final StreamController<List<AppNotification>> _streamController =
      StreamController<List<AppNotification>>.broadcast();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  List<AppNotification> get notifications =>
      _cachedNotifications.isNotEmpty ? _cachedNotifications : MockData.notifications;

  int get unreadCount => notifications.where((n) => !n.read).length;

  Future<void> init() async {
    _cachedNotifications = List.from(MockData.notifications);
    _streamController.add(notifications);

    if (FirebaseInitializer.isFirebaseReady) {
      try {
        final messaging = FirebaseMessaging.instance;
        final settings = await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        debugPrint('FCM Notification permission status: ${settings.authorizationStatus}');

        // Register background handler
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

        _fcmToken = await messaging.getToken();
        if (_fcmToken != null) {
          debugPrint('📱 [FCM] Device Token: ${_fcmToken!.substring(0, math.min(15, _fcmToken!.length))}...');
          await _saveFcmToken(_fcmToken!);
        }

        messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          _saveFcmToken(newToken);
        });

        // Listen for foreground push notifications
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('📱 [FCM Foreground] Push received: ${message.notification?.title}');
          final notif = message.notification;
          if (notif != null) {
            addNotification(
              AppNotification(
                id: 'fcm_${DateTime.now().millisecondsSinceEpoch}',
                title: notif.title ?? 'PARAGON Notification',
                message: notif.body ?? '',
                category: message.data['category'] ?? 'ORDER STATUS',
                iconName: message.data['iconName'] ?? 'order',
                actionRoute: message.data['actionRoute'],
                actionLabel: message.data['actionLabel'],
                timestamp: DateTime.now(),
              ),
            );
          }
        });
      } catch (e) {
        debugPrint('FCM initialization note: $e');
      }
    }
  }

  Future<void> _saveFcmToken(String token) async {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid != null && FirebaseInitializer.isFirebaseReady) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Error saving FCM token: $e');
      }
    }
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

  /// Dispatches notification when order is confirmed
  void notifyOrderPlaced(String orderId, double grandTotal) {
    addNotification(
      AppNotification(
        id: 'notif_order_placed_$orderId',
        title: 'Order Confirmed! 🛍️',
        message: 'Your order #$orderId (\$${grandTotal.toStringAsFixed(2)}) has been accepted by PARAGON Kitchen.',
        category: 'ORDER STATUS',
        iconName: 'order',
        orderId: orderId,
        actionLabel: 'Track Order',
        actionRoute: AppRoutes.trackOrder,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Dispatches notification when chef starts cooking
  void notifyOrderPreparing(String orderId) {
    addNotification(
      AppNotification(
        id: 'notif_order_prep_$orderId',
        title: 'Chef is Preparing Your Feast 👨‍🍳',
        message: 'Order #$orderId is now in the kitchen. Authentic spices and fresh ingredients at work!',
        category: 'ORDER STATUS',
        iconName: 'chef',
        orderId: orderId,
        actionLabel: 'Live Track',
        actionRoute: AppRoutes.trackOrder,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Dispatches notification when delivery partner is on the way
  void notifyOrderOutForDelivery(String orderId, String partnerName) {
    addNotification(
      AppNotification(
        id: 'notif_order_transit_$orderId',
        title: 'Order Out for Delivery! 🛵',
        message: 'Delivery partner ($partnerName) is on the way to your doorstep.',
        category: 'DELIVERY',
        iconName: 'delivery',
        orderId: orderId,
        actionLabel: 'Live Track',
        actionRoute: AppRoutes.trackOrder,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Dispatches notification when order is delivered
  void notifyOrderDelivered(String orderId) {
    addNotification(
      AppNotification(
        id: 'notif_order_delivered_$orderId',
        title: 'Order Delivered! 🎉',
        message: 'Your meal from PARAGON has arrived. Enjoy your dining experience!',
        category: 'ORDER STATUS',
        iconName: 'order',
        orderId: orderId,
        actionLabel: 'Order Again',
        actionRoute: AppRoutes.foodHome,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Dispatches notification when order is cancelled
  void notifyOrderCancelled(String orderId, String reason) {
    addNotification(
      AppNotification(
        id: 'notif_order_cancelled_$orderId',
        title: 'Order #$orderId Cancelled',
        message: 'Cancellation confirmed ($reason). Any pre-authorized payment has been refunded.',
        category: 'ORDER STATUS',
        iconName: 'order',
        orderId: orderId,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Dispatches notification when table reservation is confirmed
  void notifyTableReserved({required String tableNumber, required int guests, required String time}) {
    addNotification(
      AppNotification(
        id: 'notif_table_res_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Table #$tableNumber Confirmed! 🍽️',
        message: 'Your table reservation for $guests guests at $time is booked. We look forward to hosting you!',
        category: 'TABLE RESERVATION',
        iconName: 'table',
        actionLabel: 'View Booking',
        actionRoute: AppRoutes.reserveDashboard,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Dispatches notification when food bill is paid at table
  void notifyTableBillPaid({required String tableNumber, required double amount}) {
    addNotification(
      AppNotification(
        id: 'notif_table_paid_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Food Bill Paid (\$${amount.toStringAsFixed(2)}) 💳',
        message: 'Payment received at Table #$tableNumber. Table lock released. Thank you for dining with PARAGON!',
        category: 'TABLE BILL',
        iconName: 'bill',
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Dispatches notification when table is freed
  void notifyTableReleased({required String tableNumber}) {
    addNotification(
      AppNotification(
        id: 'notif_table_rel_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Table #$tableNumber Released ✨',
        message: 'Table is now available. We hope you enjoyed your time with us.',
        category: 'TABLE RESERVATION',
        iconName: 'table',
        timestamp: DateTime.now(),
      ),
    );
  }
}
