import 'package:flutter/material.dart';

import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/food_planner_bottom_nav.dart';
import 'food_planner_account_view.dart';
import 'food_planner_calculator_screen.dart';
import 'food_planner_calorie_view.dart';
import 'food_planner_week_view.dart';

/// Main Shell screen for the Food Planner housing the persistent 4-tab bottom navigation bar.
class FoodPlannerShellScreen extends StatelessWidget {
  const FoodPlannerShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FoodPlannerController.instance,
      builder: (context, _) {
        final ctrl = FoodPlannerController.instance;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: ctrl.activeTabIndex,
            children: const [
              FoodPlannerWeekView(),
              FoodPlannerCalorieView(),
              FoodPlannerCalculatorScreen(),
              FoodPlannerAccountView(),
            ],
          ),
          bottomNavigationBar: FoodPlannerBottomNav(
            currentIndex: ctrl.activeTabIndex,
            onTap: (index) => ctrl.setActiveTab(index),
          ),
        );
      },
    );
  }
}
