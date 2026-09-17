import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/app_notification.dart';
import 'auth_service.dart';
import 'firebase_initializer.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  List<AppNotification> _cachedNotifications = [];

  List<AppNotification> get notifications =>
      _cachedNotifications.isNotEmpty ? _cachedNotifications : MockData.notifications;

  Future<void> init() async {
    _cachedNotifications = List.from(MockData.notifications);
  }

  Stream<List<AppNotification>> streamNotifications() {
    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';

    if (FirebaseInitializer.isFirebaseReady) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final items = snapshot.docs
              .map((doc) => AppNotification.fromMap(doc.data(), id: doc.id))
              .toList();
          _cachedNotifications = items;
          return items;
        }
        return MockData.notifications;
      });
    }

    return Stream.value(notifications);
  }

  Future<void> addNotification(AppNotification notification) async {
    final uid = AuthService.instance.currentUser?.uid ?? 'usr_demo';
    _cachedNotifications.insert(0, notification);

    if (FirebaseInitializer.isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .add(notification.toMap());
      } catch (e) {
        debugPrint('Error adding notification to Firestore: $e');
      }
    }
  }
}

