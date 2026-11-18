import '../../models/dish.dart';
import '../../models/meal_plan.dart';
import 'food_planner_repository.dart';

class FoodPlannerService {
  FoodPlannerService({required FoodPlannerRepository repository})
      : _repository = repository;

  final FoodPlannerRepository _repository;

  Future<PlannerTrackOrder?> getActiveOrder() {
    return _repository.getActiveOrder();
  }

  Future<void> placeOrder({required Dish dish}) async {
    await _repository.confirmPlannedMeal(dish: dish);
  }
}