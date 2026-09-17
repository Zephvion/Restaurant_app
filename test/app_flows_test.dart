import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/main.dart';
import 'package:restaurant_app/screens/auth/forgot_password_screen.dart';
import 'package:restaurant_app/screens/auth/login_screen.dart';
import 'package:restaurant_app/screens/auth/signup_screen.dart';
import 'package:restaurant_app/screens/home/home_screen.dart';
import 'package:restaurant_app/screens/order_food/food_home_screen.dart';
import 'package:restaurant_app/screens/order_food/cart_screen.dart';
import 'package:restaurant_app/screens/order_food/payment_options_screen.dart';
import 'package:restaurant_app/screens/reserve_table/reserve_dashboard_screen.dart';
import 'package:restaurant_app/screens/takeaway/takeaway_dashboard_screen.dart';
import 'package:restaurant_app/screens/catering/catering_dashboard_screen.dart';
import 'package:restaurant_app/screens/food_planner/food_planner_shell_screen.dart';
import 'package:restaurant_app/screens/order_food/account_screen.dart';
import 'package:restaurant_app/screens/order_food/payment_methods_screen.dart';

void main() {
  testWidgets('Full App Navigation and Screen Rendering Test', (tester) async {
    // Set a phone-like viewport size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    // 1. Boot the App
    await tester.pumpWidget(const ParagonApp());
    expect(find.byType(ParagonApp), findsOneWidget);

    // 2. Test Login Screen Direct Render
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen()),
    );
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Login with google'), findsOneWidget);

    // 2b. Test Forgot Password Screen Direct Render
    await tester.pumpWidget(
      const MaterialApp(home: ForgotPasswordScreen()),
    );
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('SEND RESET LINK'), findsOneWidget);

    // 2c. Test Signup Screen Direct Render with Address and Landmark
    await tester.pumpWidget(
      const MaterialApp(home: SignupScreen()),
    );
    expect(find.text('Create an Account'), findsOneWidget);
    expect(find.text('1. PERSONAL DETAILS'), findsOneWidget);
    expect(find.text('2. DELIVERY LOCATION'), findsOneWidget);
    expect(find.text('3. ACCOUNT SECURITY'), findsOneWidget);
    expect(find.text('Detect GPS'), findsOneWidget);
    expect(find.text('SIGN UP & VERIFY OTP'), findsOneWidget);

    // 3. Test Home Hub Multi-Service Navigation
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen()),
    );
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Order Food'), findsWidgets);

    // 4. Test Food Home Screen (Menu & Categories)
    await tester.pumpWidget(
      const MaterialApp(home: FoodHomeScreen()),
    );
    expect(find.text('MENU'), findsOneWidget);
    expect(find.text('Frequent order'), findsWidgets);

    // 5. Test Cart Screen
    await tester.pumpWidget(
      const MaterialApp(home: CartScreen()),
    );
    expect(find.text('Cart'), findsOneWidget);

    // 6. Test Reserve Table Dashboard
    await tester.pumpWidget(
      const MaterialApp(home: ReserveDashboardScreen()),
    );
    expect(find.byType(ReserveDashboardScreen), findsOneWidget);

    // 7. Test Take Away Dashboard
    await tester.pumpWidget(
      const MaterialApp(home: TakeawayDashboardScreen()),
    );
    expect(find.text('Take Away'), findsOneWidget);

    // 8. Test Catering Dashboard
    await tester.pumpWidget(
      const MaterialApp(home: CateringDashboardScreen()),
    );
    expect(find.byType(CateringDashboardScreen), findsOneWidget);

    // 9. Test Food Planner Shell
    await tester.pumpWidget(
      const MaterialApp(home: FoodPlannerShellScreen()),
    );
    expect(find.byType(FoodPlannerShellScreen), findsOneWidget);

    // 10. Test Account Screen
    await tester.pumpWidget(
      const MaterialApp(home: AccountScreen()),
    );
    expect(find.text('My Account'), findsOneWidget);
    expect(find.text('Order Food'), findsWidgets);

    // 11. Test Payment Options Screen
    await tester.pumpWidget(
      const MaterialApp(home: PaymentOptionsScreen()),
    );
    expect(find.text('Payment Options'), findsOneWidget);
    expect(find.text('Credit & Debit Cards'), findsOneWidget);
    expect(find.text('Net Banking'), findsOneWidget);

    // 12. Test Payment Methods Screen (Profile Manage Payments)
    await tester.pumpWidget(
      const MaterialApp(home: PaymentMethodsScreen()),
    );
    expect(find.text('Manage Payment Methods'), findsOneWidget);
    expect(find.text('Add New Card'), findsOneWidget);
    expect(find.text('Add New UPI ID'), findsOneWidget);
    expect(find.text('Link New Wallet'), findsOneWidget);
  });
}

