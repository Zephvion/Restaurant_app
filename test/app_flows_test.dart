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
  void setupViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('App Flow - 1. ParagonApp Boot', (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(const ParagonApp());
    expect(find.byType(ParagonApp), findsOneWidget);
  });

  testWidgets('App Flow - 2. LoginScreen', (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Login with google'), findsOneWidget);
  });

  testWidgets('App Flow - 2b. ForgotPasswordScreen', (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('SEND RESET LINK'), findsOneWidget);
  });

  testWidgets('App Flow - 2c. SignupScreen', (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
    expect(find.text('Create an Account'), findsOneWidget);
    expect(find.text('1. PERSONAL DETAILS'), findsOneWidget);
    expect(find.text('2. DELIVERY LOCATION'), findsOneWidget);
    expect(find.text('3. ACCOUNT SECURITY'), findsOneWidget);
    expect(find.text('Detect GPS'), findsOneWidget);
    expect(find.text('SIGN UP & VERIFY OTP'), findsOneWidget);
  });

  testWidgets('App Flow - 3. HomeScreen', (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Order Food'), findsWidgets);
  });

  testWidgets('App Flow - 4. FoodHomeScreen', (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: FoodHomeScreen()));
    expect(find.text('MENU'), findsOneWidget);
    expect(find.text('Frequent order'), findsWidgets);
  });

  testWidgets('App Flow - 5. CartScreen', (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: CartScreen()));
    expect(find.text('Cart'), findsOneWidget);
  });

  testWidgets('App Flow - 6. ReserveDashboardScreen', (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: ReserveDashboardScreen()));
    expect(find.byType(ReserveDashboardScreen), findsOneWidget);
  });

  testWidgets('App Flow - 7. TakeawayDashboardScreen', (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: TakeawayDashboardScreen()));
    expect(find.text('Take Away'), findsOneWidget);
  });

  testWidgets('App Flow - 8. CateringDashboardScreen', (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: CateringDashboardScreen()));
    expect(find.byType(CateringDashboardScreen), findsOneWidget);
  });

  testWidgets('App Flow - 9. FoodPlannerShellScreen', (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: FoodPlannerShellScreen()));
    expect(find.byType(FoodPlannerShellScreen), findsOneWidget);
  });

  testWidgets('App Flow - 10. AccountScreen', (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: AccountScreen()));
    expect(find.text('My Account'), findsOneWidget);
    expect(find.text('Order Food'), findsWidgets);
  });

  testWidgets('App Flow - 11. PaymentOptionsScreen', (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: PaymentOptionsScreen()));
    expect(find.text('Payment Options'), findsOneWidget);
    expect(find.text('Credit & Debit Cards'), findsOneWidget);
    expect(find.text('Net Banking'), findsOneWidget);
  });

  testWidgets('App Flow - 12. PaymentMethodsScreen', (tester) async {
    setupViewport(tester);
    await tester.pumpWidget(const MaterialApp(home: PaymentMethodsScreen()));
    expect(find.text('Manage Payment Methods'), findsOneWidget);
    expect(find.text('Add New Card'), findsOneWidget);
    expect(find.text('Add New UPI ID'), findsOneWidget);
    expect(find.text('Link New Wallet'), findsOneWidget);
  });
}
