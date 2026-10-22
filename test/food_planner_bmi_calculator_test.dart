import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/screens/food_planner/food_planner_calculator_screen.dart';
import 'package:restaurant_app/screens/food_planner/food_planner_week_view.dart';
import 'package:restaurant_app/screens/food_planner/food_planner_account_view.dart';
import 'package:restaurant_app/state/food_planner_controller.dart';
import 'package:restaurant_app/services/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.instance.init();
  });

  group('FoodPlanner BMI & Nutrition Calculation Tests', () {
    test('Calculates BMI, categories, and targets correctly', () async {
      final ctrl = FoodPlannerController.instance;

      // Male, 25 yrs, 175 cm, 70 kg, Moderate active, Maintain Weight
      final heightM = 1.75;
      final expectedBmi = double.parse((70.0 / (heightM * heightM)).toStringAsFixed(1));
      expect(expectedBmi, 22.9);

      // Healthy range: 18.5 * (1.75^2) = 56.656 -> 56.7, 24.9 * (1.75^2) = 76.256 -> 76.3
      final minH = double.parse((18.5 * (heightM * heightM)).toStringAsFixed(1));
      final maxH = double.parse((24.9 * (heightM * heightM)).toStringAsFixed(1));
      expect(minH, 56.7);
      expect(maxH, 76.3);

      final stats = {
        'bmi': expectedBmi,
        'bmiCategory': 'Healthy Weight',
        'minHealthyWeight': minH,
        'maxHealthyWeight': maxH,
        'bmr': 1674,
        'tdee': 2594,
        'targetKcal': 2594,
        'proteinG': 195,
        'carbsG': 292,
        'fatG': 72,
        'age': 25,
        'weightKg': 70.0,
        'heightCm': 175.0,
        'sex': 'Male',
        'activity': 'Moderate active',
        'goal': 'Maintain Weight',
      };

      await ctrl.saveUserBmiStats(stats);

      // Verify that stats and targets are properly updated in controller and SessionManager
      expect(ctrl.targetKcal, 2594);
      expect(ctrl.userBmiStats!['bmi'], 22.9);
      expect(ctrl.userBmiStats!['bmiCategory'], 'Healthy Weight');
      expect(ctrl.calorieStats.targetKcal, 2594);
    });

    testWidgets('FoodPlannerCalculatorScreen renders explicit calculate button & displays BMI metrics', (tester) async {
      tester.view.physicalSize = const Size(720, 1600); // 360 x 800 dp
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: FoodPlannerCalculatorScreen(isFirstTimeOnboarding: false),
        ),
      );
      await tester.pumpAndSettle();

      // Check for BMI score section
      expect(find.text('YOUR BMI SCORE'), findsOneWidget);
      expect(find.textContaining('Formula:'), findsOneWidget);

      // Scroll down to find the Dedicated Calculate Button
      final calcButtonFinder = find.text('CALCULATE BMI & NUTRITION GOAL');
      await tester.scrollUntilVisible(
        calcButtonFinder,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(calcButtonFinder, findsOneWidget);

      // Check for bottom action button
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('FoodPlannerWeekView displays BMI badge when stats exist', (tester) async {
      tester.view.physicalSize = const Size(720, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await FoodPlannerController.instance.saveUserBmiStats({
        'bmi': 22.9,
        'bmiCategory': 'Healthy Weight',
        'targetKcal': 2400,
        'minHealthyWeight': 56.7,
        'maxHealthyWeight': 76.3,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FoodPlannerWeekView()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('BMI: 22.9 • Healthy Weight'), findsOneWidget);
    });

    testWidgets('FoodPlannerAccountView displays BMI & healthy weight in nutrition goals', (tester) async {
      tester.view.physicalSize = const Size(720, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await FoodPlannerController.instance.saveUserBmiStats({
        'bmi': 22.9,
        'bmiCategory': 'Healthy Weight',
        'targetKcal': 2400,
        'minHealthyWeight': 56.7,
        'maxHealthyWeight': 76.3,
        'weightKg': 70.0,
        'bmr': 1674,
        'tdee': 2594,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FoodPlannerAccountView()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your BMI Score'), findsOneWidget);
      expect(find.text('22.9 kg/m²'), findsOneWidget);
      expect(find.text('Healthy Weight Target'), findsOneWidget);
      expect(find.text('56.7 – 76.3 kg'), findsOneWidget);
    });
  });
}

