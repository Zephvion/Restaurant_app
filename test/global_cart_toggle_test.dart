import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/data/mock_data.dart';
import 'package:restaurant_app/routes/app_routes.dart';
import 'package:restaurant_app/screens/order_food/cart_screen.dart';
import 'package:restaurant_app/state/app_mode_controller.dart';
import 'package:restaurant_app/state/cart_controller.dart';

void main() {
  setUp(() {
    CartController.instance.clear();
    AppModeController.instance.setMode(AppMode.orderFood);
  });

  tearDown(() {
    CartController.instance.clear();
  });

  testWidgets(
      'Global Cart displays Delivery vs Take Away toggle and switches modes properly',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    // Add an item to cart so cart is not empty
    final dish = MockData.dishes.first;
    CartController.instance.add(dish, qty: 2);

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoutes.cart,
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.cart) {
            return MaterialPageRoute(
              settings: const RouteSettings(
                name: AppRoutes.cart,
                arguments: {'isGlobal': true},
              ),
              builder: (_) => const CartScreen(),
            );
          }
          return null;
        },
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Global Cart has fulfillment toggle
    expect(find.text('Delivery'), findsWidgets);
    expect(find.text('Take Away'), findsWidgets);
    expect(find.text('To Doorstep'), findsOneWidget);
    expect(find.text('Direct Pickup'), findsOneWidget);

    // Initially in Delivery mode
    expect(AppModeController.instance.isOrderFood, isTrue);
    expect(find.text('Delivery partner fee for 8km'), findsOneWidget);
    expect(find.text('ORDER NOW'), findsOneWidget);

    // 2. Tap Take Away option
    await tester.tap(find.text('Take Away').first);
    await tester.pumpAndSettle();

    // Verify mode switched to Take Away
    expect(AppModeController.instance.isTakeAway, isTrue);
    // Verify delivery fee is FREE
    expect(find.text('Delivery fee (Takeaway)'), findsOneWidget);
    expect(find.text('FREE'), findsOneWidget);
    // Verify pickup store badge is shown
    expect(find.text('PICKUP'), findsOneWidget);
    expect(find.text('PROCEED TO TAKEAWAY'), findsOneWidget);

    // 3. Tap Delivery option back
    await tester.tap(find.text('Delivery').first);
    await tester.pumpAndSettle();

    // Verify mode switched back to Delivery
    expect(AppModeController.instance.isOrderFood, isTrue);
    expect(find.text('Delivery partner fee for 8km'), findsOneWidget);
    expect(find.text('ORDER NOW'), findsOneWidget);
  });

  testWidgets(
      'Inside Cart (isGlobal = false) does NOT display Delivery vs Take Away toggle',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    // Add an item to cart
    final dish = MockData.dishes.first;
    CartController.instance.add(dish, qty: 1);

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoutes.cart,
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.cart) {
            return MaterialPageRoute(
              settings: const RouteSettings(
                name: AppRoutes.cart,
                arguments: {'isGlobal': false},
              ),
              builder: (_) => const CartScreen(),
            );
          }
          return null;
        },
      ),
    );
    await tester.pumpAndSettle();

    // Verify subtitle texts from toggle do NOT exist
    expect(find.text('To Doorstep'), findsNothing);
    expect(find.text('Direct Pickup'), findsNothing);

    // Ensure it remains in Delivery mode
    expect(AppModeController.instance.isOrderFood, isTrue);
    expect(find.text('Delivery partner fee for 8km'), findsOneWidget);
    expect(find.text('ORDER NOW'), findsOneWidget);
  });
}
