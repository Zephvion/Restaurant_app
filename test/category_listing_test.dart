import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/data/mock_data.dart';
import 'package:restaurant_app/main.dart';
import 'package:restaurant_app/routes/app_routes.dart';
import 'package:restaurant_app/screens/order_food/category_listing_screen.dart';
import 'package:restaurant_app/state/cart_controller.dart';

void main() {
  setUp(() {
    CartController.instance.clear();
  });

  group('Category Data & Image Quality Tests', () {
    test('TEST: MockData.getDishesForCategory returns correct dishes', () {
      final meals = MockData.getDishesForCategory('Meals');
      expect(meals.isNotEmpty, isTrue);
      for (final dish in meals) {
        expect(dish.category == 'Meals' || dish.id == 'meals', isTrue);
        // Verify meals uses high-res card_meals.png
        expect(dish.imageUrl.contains('card_meals.png'), isTrue);
      }

      final chicken = MockData.getDishesForCategory('Chicken');
      expect(chicken.isNotEmpty, isTrue);
      for (final dish in chicken) {
        expect(dish.name.toLowerCase().contains('chicken'), isTrue);
      }

      final fish = MockData.getDishesForCategory('Fish');
      expect(fish.isNotEmpty, isTrue);
      for (final dish in fish) {
        expect(dish.name.toLowerCase().contains('fish'), isTrue);
      }

      final egg = MockData.getDishesForCategory('Egg');
      expect(egg.isNotEmpty, isTrue);
      for (final dish in egg) {
        expect(dish.name.toLowerCase().contains('egg'), isTrue);
      }

      final veg = MockData.getDishesForCategory('Veg');
      expect(veg.isNotEmpty, isTrue);
      for (final dish in veg) {
        expect(dish.isVeg, isTrue);
      }

      final breakfast = MockData.getDishesForCategory('Breakfast');
      expect(breakfast.isNotEmpty, isTrue);
    });

    test('TEST: High resolution images are used for food items', () {
      expect(MockData.meals.imageUrl, 'assets/images/foodplanner/extracted/card_meals.png');
      expect(MockData.plainDosa.imageUrl, 'assets/images/order/extracted/featured_dosa.png');
      expect(MockData.kuzhipaniyaram.imageUrl, 'assets/images/order/extracted/featured_kuzhi.png');
      // Verify juice does not use thumb_appam
      expect(MockData.freshJuiceOrange.imageUrl.contains('thumb_appam'), isFalse);
    });
  });

  group('Category Navigation & Cart Integration Tests', () {
    testWidgets('TEST 1 & 3: Category page opens and Back returns to Home',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            AppRoutes.home: (_) => const Scaffold(body: Text('HOME_SCREEN')),
            AppRoutes.categoryListing: (_) => const CategoryListingScreen(),
          },
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRoutes.categoryListing,
                  arguments: 'Meals',
                ),
                child: const Text('OPEN_MEALS'),
              ),
            ),
          ),
        ),
      );

      // Open Meals
      await tester.tap(find.text('OPEN_MEALS'));
      await tester.pumpAndSettle();

      // Meals Listing Page is open
      expect(find.text('Meals'), findsWidgets);
      expect(find.byType(CategoryListingScreen), findsOneWidget);

      // Tap Back button
      final backButton = find.byIcon(Icons.arrow_back_ios_new);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Back on Home
      expect(find.text('OPEN_MEALS'), findsOneWidget);
    });

    testWidgets('TEST 2, 6, 7: Add item, change quantity, and cart updates',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final cart = CartController.instance;
      expect(cart.isEmpty, isTrue);

      await tester.pumpWidget(
        const MaterialApp(
          home: CategoryListingScreen(initialCategory: 'Meals'),
        ),
      );
      await tester.pumpAndSettle();

      // Find an add button in the grid
      final addButtons = find.byIcon(Icons.add);
      expect(addButtons, findsWidgets);

      // Tap first add button
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      // Cart is updated
      expect(cart.totalQuantity, 1);
      expect(cart.items.length, 1);
      final addedDish = cart.items.first.dish;

      // QuantityStepper should now be shown with value 1
      expect(find.text('1'), findsWidgets);

      // Change quantity: tap '+' on the stepper
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      expect(cart.quantityOf(addedDish), 2);
      expect(cart.totalQuantity, 2);

      // BasketBar should be visible with "2 Items added to basket"
      expect(find.text('2 Items added to basket'), findsOneWidget);
    });

    testWidgets('TEST 4: Chicken category listing shows correct items',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: CategoryListingScreen(initialCategory: 'Chicken'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chicken'), findsWidgets);
      expect(find.text('Chicken Biriyani'), findsOneWidget);
      expect(find.text('Chicken Curry'), findsOneWidget);
    });

    testWidgets('TEST 5: Fish category listing shows correct items',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: CategoryListingScreen(initialCategory: 'Fish'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fish'), findsWidgets);
      expect(find.text('Fish Curry'), findsOneWidget);
      expect(find.text('Fish Fry'), findsOneWidget);
    });

    testWidgets('TEST 8: Category switching tabs on CategoryListingScreen work',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: CategoryListingScreen(initialCategory: 'Meals'),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on 'Chicken' pill which is visible
      final chickenPill = find.text('Chicken');
      expect(chickenPill, findsOneWidget);
      await tester.tap(chickenPill);
      await tester.pumpAndSettle();

      // Now Chicken dishes are displayed
      expect(find.text('Chicken Biriyani'), findsOneWidget);
      expect(find.text('Chicken Curry'), findsOneWidget);
    });
  });
}
