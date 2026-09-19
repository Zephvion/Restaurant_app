import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

class FirebaseInitializer {
  static bool isFirebaseReady = false;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      isFirebaseReady = true;
      try {
        FirebaseFirestore.instance.settings =
            const Settings(persistenceEnabled: true);
      } catch (settingsError) {
        debugPrint('Firestore persistence setting note: $settingsError');
      }
      debugPrint('🔥 Firebase initialized successfully with offline persistence.');
    } catch (e) {
      isFirebaseReady = false;
      debugPrint(
        '⚠️ Firebase initialization skipped or failed: $e\n'
        'The app is running in resilient local cache / offline fallback mode.\n'
        'To connect your live Firebase project, configure google-services.json / GoogleService-Info.plist or flutterfire configure.',
      );
    }
  }
}

