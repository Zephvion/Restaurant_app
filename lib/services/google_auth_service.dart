
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class GoogleUserProfile {
  final String displayName;
  final String email;
  final Color avatarColor;
  final String? photoUrl;

  const GoogleUserProfile({
    required this.displayName,
    required this.email,
    this.avatarColor = const Color(0xFF673AB7),
    this.photoUrl,
  });

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : 'G';
  }

  factory GoogleUserProfile.fromFirebaseUser(User user) {
    return GoogleUserProfile(
      displayName: user.displayName ?? 'Google User',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }
}

class GoogleAuthService extends ChangeNotifier {
  GoogleAuthService._();

  static final GoogleAuthService instance = GoogleAuthService._();

  GoogleUserProfile? _currentUser;
  GoogleUserProfile? get currentUser => _currentUser;

  User? get firebaseUser =>
      Firebase.apps.isEmpty ? null : FirebaseAuth.instance.currentUser;

  bool get isLoggedIn => firebaseUser != null || _currentUser != null;

  StreamSubscription<User?>? _authSubscription;

  bool get isFirebaseReady => Firebase.apps.isNotEmpty;

  final List<GoogleUserProfile> availableAccounts = [
    const GoogleUserProfile(
      displayName: 'Sinchana DK',
      email: 'sinchana.dk@gmail.com',
      avatarColor: Color(0xFF7B1FA2),
    ),
    const GoogleUserProfile(
      displayName: 'Sinchana Work',
      email: 'sinchana@enterprise.io',
      avatarColor: Color(0xFF00796B),
    ),
  ];

  /// Call after Firebase.initializeApp().
  Future<void> initializeFirebaseAuth() async {
    if (!isFirebaseReady) {
      throw StateError('Firebase has not been initialized.');
    }

    await _authSubscription?.cancel();

    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentUser = user == null
          ? null
          : GoogleUserProfile.fromFirebaseUser(user);
      notifyListeners();
    });

    final user = FirebaseAuth.instance.currentUser;
    _currentUser = user == null
        ? null
        : GoogleUserProfile.fromFirebaseUser(user);

    notifyListeners();
  }

  /// Real Firebase email/password sign-in.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _requireFirebase();

    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Real Firebase email/password account creation.
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    _requireFirebase();

    return FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Completes Google sign-in using a Google OAuth credential.
  /// Obtain this credential from the configured Google Sign-In flow.
  Future<UserCredential> signInWithGoogleCredential(
    AuthCredential credential,
  ) async {
    _requireFirebase();

    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  void _requireFirebase() {
    if (!isFirebaseReady) {
      throw StateError(
        'Firebase is not configured. Configure the Firebase app first.',
      );
    }
  }

  // Legacy mock methods retained so existing UI does not break.
  // These methods do NOT authenticate with Firebase.

  void signIn(GoogleUserProfile user) {
    _currentUser = user;
    notifyListeners();
  }

  void signInWithCustomAccount({
    required String name,
    required String email,
  }) {
    final user = GoogleUserProfile(
      displayName: name.trim().isEmpty ? 'Google User' : name.trim(),
      email: email.trim(),
      avatarColor: const Color(0xFF1976D2),
    );

    if (!availableAccounts.any(
      (account) => account.email.toLowerCase() == user.email.toLowerCase(),
    )) {
      availableAccounts.add(user);
    }

    signIn(user);
  }

  Future<void> signOut() async {
    if (isFirebaseReady) {
      await FirebaseAuth.instance.signOut();
    }

    _currentUser = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
