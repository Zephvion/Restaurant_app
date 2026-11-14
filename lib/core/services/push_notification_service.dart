
import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');

  static StreamSubscription<String>? _tokenSubscription;

  static String get _platform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'unknown';
    }
  }

  static Future<void> initialize() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('FCM: No signed-in Firebase user.');
      return;
    }

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();

    if (token != null) {
      await _registerToken(token);
    }

    await _tokenSubscription?.cancel();

    _tokenSubscription =
        _messaging.onTokenRefresh.listen((newToken) {
      _registerToken(newToken);
    });
  }

  static Future<void> _registerToken(String token) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }

    await _functions.httpsCallable('registerFcmToken').call({
      'token': token,
      'platform': _platform,
    });

    debugPrint('FCM: Device token registered.');
  }

  static Future<void> removeCurrentToken() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await _tokenSubscription?.cancel();
    _tokenSubscription = null;

    final token = await _messaging.getToken();

    if (token == null) return;

    await _functions.httpsCallable('removeFcmToken').call({
      'token': token,
    });
  }
}
