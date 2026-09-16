import 'package:flutter/material.dart';

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

/// Service providing state management for Google Authentication in PARAGON.
class GoogleAuthService extends ChangeNotifier {
  GoogleAuthService._();
  static final GoogleAuthService instance = GoogleAuthService._();

  GoogleUserProfile? _currentUser;
  GoogleUserProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Default mock accounts available for selection.
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

  /// Signs in with the given profile.
  void signIn(GoogleUserProfile user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Adds a custom Google account and signs in.
  void signInWithCustomAccount({required String name, required String email}) {
    final user = GoogleUserProfile(
      displayName: name.trim().isEmpty ? 'Google User' : name.trim(),
      email: email.trim(),
      avatarColor: const Color(0xFF1976D2),
    );
    if (!availableAccounts.any((a) => a.email.toLowerCase() == user.email.toLowerCase())) {
      availableAccounts.add(user);
    }
    signIn(user);
  }

  /// Signs out current session.
  void signOut() {
    _currentUser = null;
    notifyListeners();
  }
}
