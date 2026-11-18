import '../../models/dish.dart';
import '../../models/meal_plan.dart';
import '../../state/food_planner_controller.dart';

abstract interface class FoodPlannerRepository {
  Future<PlannerTrackOrder?> getActiveOrder();

  Future<void> confirmPlannedMeal({required Dish dish});
}

class ControllerFoodPlannerRepository implements FoodPlannerRepository {
  ControllerFoodPlannerRepository({
    required FoodPlannerController controller,
  }) : _controller = controller;

  final FoodPlannerController _controller;

  @override
  Future<PlannerTrackOrder?> getActiveOrder() async {
    return _controller.activeTrackOrder;
  }

  @override
  Future<void> confirmPlannedMeal({required Dish dish}) async {
    _controller.confirmPlannedMeal(dish: dish);
  }
}