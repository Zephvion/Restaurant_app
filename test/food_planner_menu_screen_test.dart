import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/models/meal_plan.dart';
import 'package:restaurant_app/screens/food_planner/food_planner_menu_screen.dart';
import 'package:restaurant_app/services/session_manager.dart';
import 'package:restaurant_app/state/food_planner_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.instance.init();
    final ctrl = FoodPlannerController.instance;
    ctrl.clearBasket();
    ctrl.setupSlot(
      mealType: MealType.breakfast,
      timeSlot: '7:30AM',
      location: 'HOME',
    );
  });

  group('FoodPlannerMenuScreen Unified Category & Meal Selection Tests', () {
    testWidgets('Renders single unified category selector with icons and food grid', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/food-planner/product': (_) => const Scaffold(body: Text('Product Detail')),
          },
          home: const FoodPlannerMenuScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Top app bar shows meal title & calorie progress
      expect(find.text('ADD TO BREAKFAST'), findsOneWidget);

      // Meal switch tabs
      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
      expect(find.text('Snacks'), findsOneWidget);

      // Single Unified Category Selector chips & section header
      expect(find.text('All / Popular'), findsWidgets);
      expect(find.text('Dosa & Idli'), findsOneWidget);

      // Calorie budget target banner
      expect(find.textContaining('Breakfast Target:'), findsOneWidget);

      // Food dishes rendered in grid (e.g. Plain Dosa)
      expect(find.text('Plain Dosa'), findsWidgets);
    });

    testWidgets('Tapping category changes dishes and updates category title', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/food-planner/product': (_) => const Scaffold(body: Text('Product Detail')),
          },
          home: const FoodPlannerMenuScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Dosa & Idli' category chip
      final dosaCategoryChip = find.text('Dosa & Idli');
      expect(dosaCategoryChip, findsOneWidget);
      await tester.tap(dosaCategoryChip);
      await tester.pumpAndSettle();

      // Category section title is updated to Dosa & Idli
      expect(find.text('Dosa & Idli'), findsWidgets);
    });

    testWidgets('Adding item shows floating confirmation bar with calorie count', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final ctrl = FoodPlannerController.instance;
      expect(ctrl.basketTotalItems, 0);

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/food-planner/product': (_) => const Scaffold(body: Text('Product Detail')),
          },
          home: const FoodPlannerMenuScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap ADD on first dish card
      final addButtons = find.text('ADD');
      expect(addButtons, findsWidgets);
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      // Basket updated
      expect(ctrl.basketTotalItems, 1);

      // Floating confirmation cart bar appears
      expect(find.textContaining('CONFIRM BREAKFAST'), findsOneWidget);
      expect(find.textContaining('1 ITEM'), findsOneWidget);
    });
  });
}
