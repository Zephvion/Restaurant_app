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
  const FoodPlannerShellScreen({super.key, this.isEmbedded = false});

  final bool isEmbedded;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FoodPlannerController.instance,
      builder: (context, _) {
        final ctrl = FoodPlannerController.instance;

        // If user is opening food planner for the first time without having completed
        // their personal stats assessment, direct them through the BMI setup first.
        if (!ctrl.hasCompletedBmiSetup) {
          return FoodPlannerCalculatorScreen(
            isFirstTimeOnboarding: true,
            isEmbedded: isEmbedded,
            onSetupComplete: () {
              ctrl.setActiveTab(0);
            },
          );
        }

        return Scaffold(
          backgroundColor:
              isEmbedded ? Colors.transparent : AppColors.background,
          body: IndexedStack(
            index: ctrl.activeTabIndex,
            children: [
              FoodPlannerWeekView(isEmbedded: isEmbedded),
              const FoodPlannerCalorieView(),
              const FoodPlannerCalculatorScreen(),
              const FoodPlannerAccountView(),
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
