import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/models/address.dart';
import 'package:restaurant_app/models/meal_plan.dart';
import 'package:restaurant_app/models/user_profile.dart';
import 'package:restaurant_app/services/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.instance.init();
  });

  group('Persistent Session Storage & Token Tests', () {
    test('TEST 1: Saves access token, refresh token, and token expiry timestamp', () async {
      final session = SessionManager.instance;
      expect(session.isLoggedIn, isFalse);

      final expiry = DateTime.now().add(const Duration(days: 30));
      await session.saveSession(
        token: 'access_token_abc_123',
        refreshToken: 'refresh_token_xyz_789',
        expiresAt: expiry,
        userId: 'usr_premium_42',
      );

      expect(session.isLoggedIn, isTrue);
      expect(session.authToken, 'access_token_abc_123');
      expect(session.refreshToken, 'refresh_token_xyz_789');
      expect(session.currentUserId, 'usr_premium_42');
      expect(session.isTokenExpired, isFalse);
    });

    test('TEST 2: Automatically detects expired access token', () async {
      final session = SessionManager.instance;
      final pastExpiry = DateTime.now().subtract(const Duration(minutes: 10));

      await session.saveSession(
        token: 'expired_access_token',
        refreshToken: 'valid_refresh_token',
        expiresAt: pastExpiry,
        userId: 'usr_test_1',
      );

      expect(session.isTokenExpired, isTrue);
      expect(session.refreshToken, 'valid_refresh_token');

      // Refreshing token updates expiry
      final newExpiry = DateTime.now().add(const Duration(hours: 1));
      await session.saveTokens(
        token: 'new_fresh_token',
        expiresAt: newExpiry,
      );

      expect(session.authToken, 'new_fresh_token');
      expect(session.refreshToken, 'valid_refresh_token');
      expect(session.isTokenExpired, isFalse);
    });

    test('TEST 3: Persists user profile, address, and delivery area permanently', () async {
      final session = SessionManager.instance;
      final profile = UserProfile(
        uid: 'usr_paragon_customer',
        displayName: 'Rahul Sharma',
        email: 'rahul.sharma@example.com',
        phone: '+91 9876543210',
        defaultDeliveryArea: 'Palazhi, Calicut',
        savedAddresses: [
          const Address(
            id: 'addr_1',
            label: 'Home',
            details: 'Flat 4B, Emerald Heights, Palazhi, Calicut',
            isDefault: true,
          ),
        ],
      );

      await session.saveSession(
        token: 'token_123',
        userId: profile.uid,
        profile: profile,
      );

      final retrieved = session.getCachedUserProfile();
      expect(retrieved, isNotNull);
      expect(retrieved!.uid, 'usr_paragon_customer');
      expect(retrieved.displayName, 'Rahul Sharma');
      expect(retrieved.email, 'rahul.sharma@example.com');
      expect(retrieved.savedAddresses.length, 1);
      expect(retrieved.savedAddresses.first.details, contains('Emerald Heights'));
    });

    test('TEST 4: Offline meal plans are permanently cached and recovered', () async {
      final session = SessionManager.instance;
      final meals = [
        PlannedMeal(
          id: 'meal_1',
          name: 'Paragon Special Meals',
          imageUrl: 'assets/images/foodplanner/extracted/card_meals.webp',
          category: 'Meals',
          kcal: 540,
          grams: 400,
          price: 240,
          isVeg: false,
          date: '2026-09-19',
          mealType: MealType.lunch,
        ),
      ];

      await session.saveCachedMealPlans(meals.map((m) => m.toMap()).toList());

      final cached = session.getCachedMealPlans();
      expect(cached, isNotNull);
      expect(cached!.length, 1);
      expect(cached.first['name'], 'Paragon Special Meals');
      expect(cached.first['kcal'], 540);
    });

    test('TEST 5: Clear session removes tokens but deleteAccount wipes all data', () async {
      final session = SessionManager.instance;
      final profile = UserProfile(
        uid: 'usr_to_delete',
        displayName: 'Temp User',
        email: 'temp@example.com',
      );

      await session.saveSession(
        token: 'token_temp',
        userId: 'usr_to_delete',
        profile: profile,
      );
      await session.setDeliveryArea('Mavoor Road');

      expect(session.isLoggedIn, isTrue);

      // Sign out clears session
      await session.clearSession();
      expect(session.isLoggedIn, isFalse);
      expect(session.authToken, isNull);
      expect(session.refreshToken, isNull);
      expect(session.currentUserId, isNull);

      // Re-login
      await session.saveSession(
        token: 'token_temp2',
        userId: 'usr_to_delete',
        profile: profile,
      );
      expect(session.isLoggedIn, isTrue);

      // Account deletion wipes everything completely
      await session.deleteAccount();
      expect(session.isLoggedIn, isFalse);
      expect(session.getCachedUserProfile(), isNull);
      expect(session.getCachedMealPlans(), isNull);
    });
  });
}

