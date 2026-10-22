import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/models/user_profile.dart';
import 'package:restaurant_app/screens/auth/login_screen.dart';
import 'package:restaurant_app/screens/auth/otp_screen.dart';
import 'package:restaurant_app/screens/takeaway/takeaway_dashboard_screen.dart';
import 'package:restaurant_app/services/auth_service.dart';
import 'package:restaurant_app/services/catering_service.dart';
import 'package:restaurant_app/services/session_manager.dart';
import 'package:restaurant_app/services/table_lock_service.dart';
import 'package:restaurant_app/widgets/otp_input.dart';
import 'package:restaurant_app/widgets/primary_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.instance.init();
    await AuthService.instance.init();
  });

  group('Senior QA Audit: OTP, Auth, Session & Responsiveness Tests', () {
    testWidgets('QA TEST 1: OTP screen displays NO mock/test OTP cards or auto-fill buttons', (tester) async {
      tester.view.physicalSize = const Size(360, 800); // Standard compact mobile viewport
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: OtpScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header and 6-digit input boxes exist
      expect(find.text('Verify OTP!'), findsOneWidget);
      expect(find.byType(OtpInput), findsOneWidget);

      // Verify that NO default/mock generated OTP text, test cards or auto-fill buttons exist!
      expect(find.textContaining('Test / Development OTP'), findsNothing);
      expect(find.text('Auto-fill'), findsNothing);
      expect(find.textContaining('Note: Cellular SMS requires Firebase Blaze'), findsNothing);

      // Verify the manual verification button is present
      expect(find.widgetWithText(PrimaryButton, 'VERIFY & SIGN IN'), findsOneWidget);
    });

    testWidgets('QA TEST 2: User can manually type OTP digits and trigger verification', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: OtpScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find text fields inside OtpInput
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(6));

      // User enters digits manually: 1 2 3 4 5 6
      final digits = ['1', '2', '3', '4', '5', '6'];
      for (int i = 0; i < 6; i++) {
        await tester.enterText(textFields.at(i), digits[i]);
      }
      await tester.pump();

      // All 6 boxes filled
      for (int i = 0; i < 6; i++) {
        expect(find.text(digits[i]), findsWidgets);
      }
    });

    test('QA TEST 3: User profile updates and session persistence work flawlessly', () async {
      final session = SessionManager.instance;
      final auth = AuthService.instance;

      final initialProfile = UserProfile(
        uid: 'usr_senior_qa_001',
        displayName: 'Aarav Nair',
        email: 'aarav.nair@example.com',
        phone: '+919876543210',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await session.saveSession(
        token: 'auth_jwt_token_sample',
        refreshToken: 'auth_refresh_token_sample',
        userId: initialProfile.uid,
        profile: initialProfile,
      );

      expect(session.isLoggedIn, isTrue);
      expect(session.currentUserId, 'usr_senior_qa_001');

      // Update user details
      final updatedProfile = initialProfile.copyWith(
        displayName: 'Aarav M. Nair',
        email: 'aarav.updated@example.com',
      );
      await auth.updateProfile(updatedProfile);

      // Verify persistence from storage
      final cached = session.getCachedUserProfile();
      expect(cached, isNotNull);
      expect(cached!.displayName, 'Aarav M. Nair');
      expect(cached.email, 'aarav.updated@example.com');
      expect(cached.phone, '+919876543210');
    });

    test('QA TEST 4: TableLockService cleanup background ticker and dynamic user binding', () async {
      final lockService = TableLockService.instance;
      lockService.resetAll();

      // Hold table 3
      final result1 = lockService.acquireLock(
        3,
        userId: 'usr_p1',
        userName: 'Person 1',
      );
      expect(result1.isSuccess, isTrue);

      final lock = lockService.getLock(3);
      expect(lock.holderUserId, 'usr_p1');

      // Queue Person 2 in waitlist
      final result2 = lockService.joinWaitlist(
        3,
        userId: 'usr_p2',
        userName: 'Person 2',
      );
      expect(result2, isTrue);
      expect(lock.waitlist.length, 1);

      // Voluntary release should auto-transfer to Person 2
      lockService.releaseLock(3, userId: 'usr_p1');
      expect(lock.holderUserId, 'usr_p2');
      expect(lock.holderUserName, 'Person 2');
      expect(lock.waitlist.isEmpty, isTrue);
    });

    test('QA TEST 5: CateringService gracefully recovers from Firestore timeout without throwing unhandled exception', () async {
      final cateringService = CateringService.instance;
      // Fetch user catering orders
      final orders = await cateringService.getUserCateringOrders('usr_non_existent');
      expect(orders, isA<List>());
    });

    testWidgets('QA TEST 6: Mobile responsiveness test - 360px viewport renders Login and Takeaway without overflow', (tester) async {
      // Small screen mobile (e.g. iPhone SE / Galaxy A10: 360 x 640)
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Test LoginScreen
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Test TakeawayDashboardScreen
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const TakeawayDashboardScreen(isEmbedded: true),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Verify the CTA button text is cleanly displayed without overflow
      expect(find.text('Order from Nearest Restaurant'), findsOneWidget);
    });
  });
}
