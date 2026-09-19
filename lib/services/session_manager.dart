import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/address.dart';
import '../models/user_profile.dart';

/// Production-ready Session Manager handling persistent local cookies, authentication
/// access tokens, refresh tokens, token expiration timestamps, user profile caching,
/// offline meal plans, and persistent account state using [SharedPreferences].
class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyTokenExpiry = 'token_expiry_timestamp';
  static const String _keyUserId = 'user_id';
  static const String _keyUserProfile = 'user_profile_json';
  static const String _keyActiveOrderId = 'active_order_id';
  static const String _keySelectedAddress = 'selected_address_json';
  static const String _keyCustomLocation = 'custom_location_area';
  static const String _keyCachedMealPlans = 'cached_meal_plans_json';
  static const String _keyIsAccountActive = 'is_account_active';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Whether a valid user session is stored and active.
  bool get isLoggedIn {
    final token = _prefs?.getString(_keyAuthToken);
    final uid = _prefs?.getString(_keyUserId);
    final isAccountActive = _prefs?.getBool(_keyIsAccountActive) ?? false;
    return (token != null && token.isNotEmpty && uid != null && uid.isNotEmpty) ||
        (isAccountActive && uid != null && uid.isNotEmpty);
  }

  String? get currentUserId => _prefs?.getString(_keyUserId);

  String? get authToken => _prefs?.getString(_keyAuthToken);

  String? get refreshToken => _prefs?.getString(_keyRefreshToken);

  DateTime? get tokenExpiresAt {
    final millis = _prefs?.getInt(_keyTokenExpiry);
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis) : null;
  }

  /// Returns true if the current access token has expired or is nearing expiration (within 5 minutes).
  bool get isTokenExpired {
    final expiry = tokenExpiresAt;
    if (expiry == null) return false; // Non-expiring fallback token
    return DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5)));
  }

  String? get activeOrderId => _prefs?.getString(_keyActiveOrderId);

  String get deliveryArea =>
      _prefs?.getString(_keyCustomLocation) ?? 'Palazhi , Calicut';

  Future<void> setDeliveryArea(String area) async {
    await _prefs?.setString(_keyCustomLocation, area);
  }

  /// Saves the complete user session with access token, refresh token, expiration, and profile.
  Future<void> saveSession({
    required String token,
    String? refreshToken,
    DateTime? expiresAt,
    required String userId,
    UserProfile? profile,
  }) async {
    await _prefs?.setString(_keyAuthToken, token);
    await _prefs?.setString(_keyUserId, userId);
    await _prefs?.setBool(_keyIsAccountActive, true);

    // Save or generate persistent refresh token
    final existingRefresh = _prefs?.getString(_keyRefreshToken);
    final finalRefresh = refreshToken ??
        existingRefresh ??
        'rt_${userId}_${DateTime.now().millisecondsSinceEpoch}';
    await _prefs?.setString(_keyRefreshToken, finalRefresh);

    if (expiresAt != null) {
      await _prefs?.setInt(_keyTokenExpiry, expiresAt.millisecondsSinceEpoch);
    } else {
      // Default 30-day token lifetime for production persistence
      final defaultExpiry = DateTime.now().add(const Duration(days: 30));
      await _prefs?.setInt(_keyTokenExpiry, defaultExpiry.millisecondsSinceEpoch);
    }

    if (profile != null) {
      await saveUserProfile(profile);
    }
  }

  /// Updates tokens without modifying profile
  Future<void> saveTokens({
    required String token,
    String? refreshToken,
    DateTime? expiresAt,
  }) async {
    await _prefs?.setString(_keyAuthToken, token);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _prefs?.setString(_keyRefreshToken, refreshToken);
    }
    if (expiresAt != null) {
      await _prefs?.setInt(_keyTokenExpiry, expiresAt.millisecondsSinceEpoch);
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _prefs?.setString(_keyUserProfile, jsonEncode(profile.toMap()));
    } catch (e) {
      debugPrint('Error saving user profile to persistent storage: $e');
    }
  }

  UserProfile? getCachedUserProfile() {
    final jsonStr = _prefs?.getString(_keyUserProfile);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserProfile.fromMap(map);
    } catch (e) {
      debugPrint('Error decoding cached user profile: $e');
      return null;
    }
  }

  Future<void> setActiveOrderId(String? orderId) async {
    if (orderId == null) {
      await _prefs?.remove(_keyActiveOrderId);
    } else {
      await _prefs?.setString(_keyActiveOrderId, orderId);
    }
  }

  Future<void> saveSelectedAddress(Address address) async {
    await _prefs?.setString(_keySelectedAddress, jsonEncode(address.toMap()));
  }

  Address? getSelectedAddress() {
    final jsonStr = _prefs?.getString(_keySelectedAddress);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Address.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  /// Offline cache for user meal plans
  Future<void> saveCachedMealPlans(List<Map<String, dynamic>> plans) async {
    await _prefs?.setString(_keyCachedMealPlans, jsonEncode(plans));
  }

  List<Map<String, dynamic>>? getCachedMealPlans() {
    final jsonStr = _prefs?.getString(_keyCachedMealPlans);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } catch (e) {
      debugPrint('Error decoding cached meal plans: $e');
      return null;
    }
  }

  /// Clears active login session on explicit sign-out, while retaining user device preferences.
  Future<void> clearSession() async {
    await _prefs?.remove(_keyAuthToken);
    await _prefs?.remove(_keyRefreshToken);
    await _prefs?.remove(_keyTokenExpiry);
    await _prefs?.remove(_keyUserId);
    await _prefs?.remove(_keyUserProfile);
    await _prefs?.remove(_keyActiveOrderId);
    await _prefs?.setBool(_keyIsAccountActive, false);
  }

  /// Completely deletes the account and all locally stored user data permanently.
  Future<void> deleteAccount() async {
    await _prefs?.clear();
  }
}
