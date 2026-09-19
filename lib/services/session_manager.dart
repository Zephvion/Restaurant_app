import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/address.dart';
import '../models/user_profile.dart';

/// Session Manager handles persistent local cookies, authentication tokens,
/// and local caching using [SharedPreferences].
class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserProfile = 'user_profile_json';
  static const String _keyActiveOrderId = 'active_order_id';
  static const String _keySelectedAddress = 'selected_address_json';
  static const String _keyCustomLocation = 'custom_location_area';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  bool get isLoggedIn {
    final token = _prefs?.getString(_keyAuthToken);
    final uid = _prefs?.getString(_keyUserId);
    return token != null && token.isNotEmpty && uid != null && uid.isNotEmpty;
  }

  String? get currentUserId => _prefs?.getString(_keyUserId);

  String? get authToken => _prefs?.getString(_keyAuthToken);

  String? get activeOrderId => _prefs?.getString(_keyActiveOrderId);

  String get deliveryArea {
    final custom = _prefs?.getString(_keyCustomLocation);
    if (custom != null && custom.isNotEmpty) return custom;
    final selected = getSelectedAddress();
    if (selected != null && selected.label.isNotEmpty) {
      return selected.label;
    }
    return 'Select Delivery Location';
  }

  Future<void> setDeliveryArea(String area) async {
    await _prefs?.setString(_keyCustomLocation, area);
  }

  Future<void> saveSession({
    required String token,
    required String userId,
    UserProfile? profile,
  }) async {
    await _prefs?.setString(_keyAuthToken, token);
    await _prefs?.setString(_keyUserId, userId);
    if (profile != null) {
      await saveUserProfile(profile);
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _prefs?.setString(_keyUserProfile, jsonEncode(profile.toMap()));
  }

  UserProfile? getCachedUserProfile() {
    final jsonStr = _prefs?.getString(_keyUserProfile);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserProfile.fromMap(map);
    } catch (_) {
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

  Future<void> clearSession() async {
    await _prefs?.remove(_keyAuthToken);
    await _prefs?.remove(_keyUserId);
    await _prefs?.remove(_keyUserProfile);
    await _prefs?.remove(_keyActiveOrderId);
  }
}

