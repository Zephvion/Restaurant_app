import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_profile.dart';
import 'auth_service.dart';
import 'firebase_initializer.dart';

/// Represents a signed-in or selectable Google user profile.
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
}

/// Service providing authentic Google OAuth Authentication in PARAGON.
class GoogleAuthService extends ChangeNotifier {
  GoogleAuthService._();
  static final GoogleAuthService instance = GoogleAuthService._();

  static const String _webClientId =
      '854555269860-h745rnb425f905rksiet7q94plt432ue.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: _webClientId,
  );

  GoogleUserProfile? _currentUser;
  GoogleUserProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Performs authentic Google OAuth sign-in.
  /// - On Web: uses [FirebaseAuth.instance.signInWithPopup] with GoogleAuthProvider,
  ///   launching Google's official accounts.google.com authentication dialog.
  /// - On Native Mobile: launches the official [GoogleSignIn] account picker / credentials dialog.
  /// Returns the authenticated [UserProfile].
  Future<UserProfile> signInWithRealGoogle() async {
    String? email;
    String? displayName;
    String? photoUrl;
    String? uid;
    String? token;

    if (kIsWeb) {
      if (FirebaseInitializer.isFirebaseReady) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        final userCredential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);
        final user = userCredential.user;
        if (user != null) {
          email = user.email;
          displayName = user.displayName;
          photoUrl = user.photoURL;
          uid = user.uid;
          token = await user.getIdToken();
        }
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          throw Exception('Google Sign-In was cancelled by the user.');
        }
        email = googleUser.email;
        displayName = googleUser.displayName;
        photoUrl = googleUser.photoUrl;
        uid = googleUser.id;
        final auth = await googleUser.authentication;
        token = auth.idToken ?? auth.accessToken;
      }
    } else {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled by the user.');
      }
      email = googleUser.email;
      displayName = googleUser.displayName;
      photoUrl = googleUser.photoUrl;
      uid = googleUser.id;

      final googleAuth = await googleUser.authentication;
      token = googleAuth.idToken ?? googleAuth.accessToken;

      if (FirebaseInitializer.isFirebaseReady) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        if (userCredential.user != null) {
          uid = userCredential.user!.uid;
          displayName = userCredential.user!.displayName ?? displayName;
          photoUrl = userCredential.user!.photoURL ?? photoUrl;
        }
      }
    }

    if (email == null || email.isEmpty) {
      throw Exception('Could not retrieve email from Google Sign-In.');
    }

    final effectiveName = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : email.split('@').first;

    final googleProfile = GoogleUserProfile(
      displayName: effectiveName,
      email: email,
      photoUrl: photoUrl,
    );

    _currentUser = googleProfile;
    notifyListeners();

    final profile = await AuthService.instance.signInWithGoogle(
      displayName: effectiveName,
      email: email,
      photoUrl: photoUrl,
      uid: uid,
      token: token,
    );

    return profile;
  }

  /// Default mock accounts available for selection in testing environments.
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

  /// Signs in with the given profile (backward-compatibility for unit tests).
  void signIn(GoogleUserProfile user) {
    _currentUser = user;
    notifyListeners();
    AuthService.instance.signInWithGoogle(
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoUrl,
    );
  }

  /// Adds a custom Google account and signs in.
  void signInWithCustomAccount({required String name, required String email}) {
    final user = GoogleUserProfile(
      displayName: name.trim().isEmpty ? 'Google User' : name.trim(),
      email: email.trim(),
      avatarColor: const Color(0xFF1976D2),
    );
    if (!availableAccounts
        .any((a) => a.email.toLowerCase() == user.email.toLowerCase())) {
      availableAccounts.add(user);
    }
    signIn(user);
  }

  /// Signs out current session.
  void signOut() {
    _currentUser = null;
    notifyListeners();
    try {
      _googleSignIn.signOut();
    } catch (_) {}
    AuthService.instance.signOut();
  }
}

