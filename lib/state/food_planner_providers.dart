import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/food_planner/food_planner_repository.dart';
import '../features/food_planner/food_planner_service.dart';
import '../models/meal_plan.dart';
import 'food_planner_controller.dart';

/// Provides the existing app-wide food planner controller.
final foodPlannerControllerProvider =
    ChangeNotifierProvider<FoodPlannerController>((ref) {
  return FoodPlannerController.instance;
});

/// Provides the Food Planner repository.
final foodPlannerRepositoryProvider = Provider<FoodPlannerRepository>((ref) {
  return ControllerFoodPlannerRepository(
    controller: ref.watch(foodPlannerControllerProvider),
  );
});

/// Provides the Food Planner service.
final foodPlannerServiceProvider = Provider<FoodPlannerService>((ref) {
  return FoodPlannerService(
    repository: ref.watch(foodPlannerRepositoryProvider),
  );
});

/// Provides the active Food Planner order asynchronously.
final foodPlannerActiveOrderAsyncProvider =
    FutureProvider<PlannerTrackOrder?>((ref) {
  return ref.watch(foodPlannerServiceProvider).getActiveOrder();
});

/// Provides the currently selected planner tab.
final foodPlannerActiveTabProvider = Provider<int>((ref) {
  return ref.watch(foodPlannerControllerProvider).activeTabIndex;
});

/// Provides the selected day offset.
final foodPlannerSelectedDayProvider = Provider<int>((ref) {
  return ref.watch(foodPlannerControllerProvider).selectedDayOffset;
});

/// Provides the planned meals.
final plannedMealsProvider = Provider<List<PlannedMeal>>((ref) {
  return ref.watch(foodPlannerControllerProvider).plannedMeals;
});

/// Provides meals for the currently selected day.
final selectedDayMealsProvider = Provider<List<PlannedMeal>>((ref) {
  final controller = ref.watch(foodPlannerControllerProvider);
  return controller.getMealsForSelectedDay();
});

/// Provides the current meal-planning basket.
final foodPlannerBasketProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(foodPlannerControllerProvider).basket;
});

/// Provides the total quantity in the meal-planning basket.
final foodPlannerBasketTotalItemsProvider = Provider<int>((ref) {
  return ref.watch(foodPlannerControllerProvider).basketTotalItems;
});

/// Provides the meal-planning basket subtotal.
final foodPlannerBasketSubtotalProvider = Provider<double>((ref) {
  return ref.watch(foodPlannerControllerProvider).basketSubtotal;
});

/// Provides the current calorie statistics.
final foodPlannerCalorieStatsProvider = Provider<CalorieStats>((ref) {
  return ref.watch(foodPlannerControllerProvider).calorieStats;
});