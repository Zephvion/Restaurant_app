import 'package:flutter/foundation.dart';

import '../data/food_planner_assets.dart';
import '../data/mock_data.dart';
import '../models/dish.dart';
import '../models/meal_plan.dart';

/// Singleton [ChangeNotifier] for managing the entire Food Planner workflow,
/// including meal plans, calorie targets, tracking, and cart.
class FoodPlannerController extends ChangeNotifier {
  FoodPlannerController._() {
    _initDefaults();
  }

  static final FoodPlannerController instance = FoodPlannerController._();

  int _activeTabIndex = 0;
  int get activeTabIndex => _activeTabIndex;

  int _selectedDayOffset = 0; // 0 for Jan 2 (Tue)
  int get selectedDayOffset => _selectedDayOffset;

  late CalorieStats _calorieStats;
  CalorieStats get calorieStats => _calorieStats;

  late PlannerTrackOrder _activeTrackOrder;
  PlannerTrackOrder get activeTrackOrder => _activeTrackOrder;

  final List<PlannedMeal> _plannedMeals = [];
  List<PlannedMeal> get plannedMeals => List.unmodifiable(_plannedMeals);

  // In-flight slot selection for planning a new meal
  MealType _currentSlotMealType = MealType.breakfast;
  MealType get currentSlotMealType => _currentSlotMealType;

  String _currentSlotTime = '7:30AM';
  String get currentSlotTime => _currentSlotTime;

  String _currentSlotLocation = 'HOME';
  String get currentSlotLocation => _currentSlotLocation;

  // Basket for current meal planning session
  final Map<String, int> _basket = {}; // dish.id -> qty
  Map<String, int> get basket => Map.unmodifiable(_basket);

  int get basketTotalItems =>
      _basket.values.fold(0, (sum, count) => sum + count);

  double get basketSubtotal {
    double total = 0.0;
    _basket.forEach((dishId, qty) {
      final dish = _findDish(dishId);
      if (dish != null) total += dish.price * qty;
    });
    return total;
  }

  void _initDefaults() {
    _calorieStats = CalorieStats(
      targetKcal: 2000,
      remainingKcal: 800,
      proteinG: 50,
      carbsG: 75,
      fatG: 100,
    );

    _activeTrackOrder = PlannerTrackOrder(
      orderId: 'PO78965412',
      etaMins: 15,
      status: PlannerOrderStatus.taken,
      driverName: 'John Doe',
      driverPhone: '+91 987654321',
      driverPhotoUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=70',
      paymentLabel: 'Card Payment\nEnding with *8754',
      deliveryTimeWindow: 'Home\n7:30AM - 8:00AM',
      items: const [
        PlannerOrderItem(name: 'Plain Dosa', quantity: 1, price: 80),
        PlannerOrderItem(name: 'Fresh Juice - Orange', quantity: 1, price: 110),
      ],
      subtotal: 190,
      deliveryFee: 30,
    );

    // Populate default planned meals across the week so every day has rich visuals
    final defaultDayPlans = [
      // Day 0: Jan 2 (Tue)
      [
        PlannedMeal(
          id: 'pm_0_1',
          dayOffset: 0,
          mealType: MealType.breakfast,
          timeSlot: '7:30AM',
          location: 'HOME',
          dishName: 'Dosa',
          imageUrl: FoodPlannerAssets.cardDosa,
          calories: 320,
          weightGm: 300,
          price: 80,
        ),
        PlannedMeal(
          id: 'pm_0_2',
          dayOffset: 0,
          mealType: MealType.lunch,
          timeSlot: '12:30PM',
          location: 'HOME',
          dishName: 'Meals',
          imageUrl: FoodPlannerAssets.cardMeals,
          calories: 320,
          weightGm: 300,
          price: 150,
        ),
        PlannedMeal(
          id: 'pm_0_3',
          dayOffset: 0,
          mealType: MealType.dinner,
          timeSlot: '8:00PM',
          location: 'HOME',
          dishName: 'Chappathi Curry',
          imageUrl: FoodPlannerAssets.cardChappathi,
          calories: 320,
          weightGm: 300,
          price: 120,
        ),
      ],
      // Day 1: Jan 3 (Wed)
      [
        PlannedMeal(
          id: 'pm_1_1',
          dayOffset: 1,
          mealType: MealType.breakfast,
          timeSlot: '7:30AM',
          location: 'HOME',
          dishName: 'Appam & Stew',
          imageUrl: FoodPlannerAssets.thumbAppam,
          calories: 320,
          weightGm: 300,
          price: 180,
        ),
        PlannedMeal(
          id: 'pm_1_2',
          dayOffset: 1,
          mealType: MealType.lunch,
          timeSlot: '12:30PM',
          location: 'HOME',
          dishName: 'Meals',
          imageUrl: FoodPlannerAssets.cardMeals,
          calories: 320,
          weightGm: 300,
          price: 150,
        ),
        PlannedMeal(
          id: 'pm_1_3',
          dayOffset: 1,
          mealType: MealType.dinner,
          timeSlot: '8:00PM',
          location: 'HOME',
          dishName: 'Chappathi Curry',
          imageUrl: FoodPlannerAssets.cardChappathi,
          calories: 320,
          weightGm: 300,
          price: 120,
        ),
      ],
      // Day 2: Jan 4 (Thu)
      [
        PlannedMeal(
          id: 'pm_2_1',
          dayOffset: 2,
          mealType: MealType.breakfast,
          timeSlot: '7:30AM',
          location: 'HOME',
          dishName: 'Puttu & Kadala',
          imageUrl: FoodPlannerAssets.thumbPuttu,
          calories: 320,
          weightGm: 300,
          price: 180,
        ),
        PlannedMeal(
          id: 'pm_2_2',
          dayOffset: 2,
          mealType: MealType.lunch,
          timeSlot: '12:30PM',
          location: 'HOME',
          dishName: 'Meals',
          imageUrl: FoodPlannerAssets.cardMeals,
          calories: 320,
          weightGm: 300,
          price: 150,
        ),
        PlannedMeal(
          id: 'pm_2_3',
          dayOffset: 2,
          mealType: MealType.dinner,
          timeSlot: '8:00PM',
          location: 'HOME',
          dishName: 'Chappathi Curry',
          imageUrl: FoodPlannerAssets.cardChappathi,
          calories: 320,
          weightGm: 300,
          price: 120,
        ),
      ],
      // Day 3: Jan 5 (Fri)
      [
        PlannedMeal(
          id: 'pm_3_1',
          dayOffset: 3,
          mealType: MealType.breakfast,
          timeSlot: '7:30AM',
          location: 'HOME',
          dishName: 'Poori Masala',
          imageUrl: FoodPlannerAssets.thumbPoori,
          calories: 320,
          weightGm: 300,
          price: 180,
        ),
        PlannedMeal(
          id: 'pm_3_2',
          dayOffset: 3,
          mealType: MealType.lunch,
          timeSlot: '12:30PM',
          location: 'HOME',
          dishName: 'Meals',
          imageUrl: FoodPlannerAssets.cardMeals,
          calories: 320,
          weightGm: 300,
          price: 150,
        ),
        PlannedMeal(
          id: 'pm_3_3',
          dayOffset: 3,
          mealType: MealType.dinner,
          timeSlot: '8:00PM',
          location: 'HOME',
          dishName: 'Chappathi Curry',
          imageUrl: FoodPlannerAssets.cardChappathi,
          calories: 320,
          weightGm: 300,
          price: 120,
        ),
      ],
      // Day 4: Jan 6 (Sat)
      [
        PlannedMeal(
          id: 'pm_4_1',
          dayOffset: 4,
          mealType: MealType.breakfast,
          timeSlot: '7:30AM',
          location: 'HOME',
          dishName: 'Idli & Sambar',
          imageUrl: FoodPlannerAssets.thumbIdli,
          calories: 320,
          weightGm: 300,
          price: 180,
        ),
        PlannedMeal(
          id: 'pm_4_2',
          dayOffset: 4,
          mealType: MealType.lunch,
          timeSlot: '12:30PM',
          location: 'HOME',
          dishName: 'Meals',
          imageUrl: FoodPlannerAssets.cardMeals,
          calories: 320,
          weightGm: 300,
          price: 150,
        ),
        PlannedMeal(
          id: 'pm_4_3',
          dayOffset: 4,
          mealType: MealType.dinner,
          timeSlot: '8:00PM',
          location: 'HOME',
          dishName: 'Chappathi Curry',
          imageUrl: FoodPlannerAssets.cardChappathi,
          calories: 320,
          weightGm: 300,
          price: 120,
        ),
      ],
      // Day 5: Jan 7 (Sun)
      [
        PlannedMeal(
          id: 'pm_5_1',
          dayOffset: 5,
          mealType: MealType.breakfast,
          timeSlot: '7:30AM',
          location: 'HOME',
          dishName: 'Dosa',
          imageUrl: FoodPlannerAssets.cardDosa,
          calories: 320,
          weightGm: 300,
          price: 80,
        ),
        PlannedMeal(
          id: 'pm_5_2',
          dayOffset: 5,
          mealType: MealType.lunch,
          timeSlot: '12:30PM',
          location: 'HOME',
          dishName: 'Meals',
          imageUrl: FoodPlannerAssets.cardMeals,
          calories: 320,
          weightGm: 300,
          price: 150,
        ),
        PlannedMeal(
          id: 'pm_5_3',
          dayOffset: 5,
          mealType: MealType.dinner,
          timeSlot: '8:00PM',
          location: 'HOME',
          dishName: 'Chappathi Curry',
          imageUrl: FoodPlannerAssets.cardChappathi,
          calories: 320,
          weightGm: 300,
          price: 120,
        ),
      ],
      // Day 6: Jan 8 (Mon)
      [
        PlannedMeal(
          id: 'pm_6_1',
          dayOffset: 6,
          mealType: MealType.breakfast,
          timeSlot: '7:30AM',
          location: 'HOME',
          dishName: 'Idiyappam & Kadala',
          imageUrl: FoodPlannerAssets.thumbIdiyappam,
          calories: 320,
          weightGm: 300,
          price: 180,
        ),
        PlannedMeal(
          id: 'pm_6_2',
          dayOffset: 6,
          mealType: MealType.lunch,
          timeSlot: '12:30PM',
          location: 'HOME',
          dishName: 'Meals',
          imageUrl: FoodPlannerAssets.cardMeals,
          calories: 320,
          weightGm: 300,
          price: 150,
        ),
        PlannedMeal(
          id: 'pm_6_3',
          dayOffset: 6,
          mealType: MealType.dinner,
          timeSlot: '8:00PM',
          location: 'HOME',
          dishName: 'Chappathi Curry',
          imageUrl: FoodPlannerAssets.cardChappathi,
          calories: 320,
          weightGm: 300,
          price: 120,
        ),
      ],
    ];

    for (final day in defaultDayPlans) {
      _plannedMeals.addAll(day);
    }

  }

  void setActiveTab(int index) {
    if (_activeTabIndex != index) {
      _activeTabIndex = index;
      notifyListeners();
    }
  }

  void selectDay(int offset) {
    if (_selectedDayOffset != offset) {
      _selectedDayOffset = offset;
      notifyListeners();
    }
  }

  List<PlannedMeal> getMealsForSelectedDay() {
    return _plannedMeals
        .where((m) => m.dayOffset == _selectedDayOffset)
        .toList();
  }

  void setupSlot({
    required MealType mealType,
    required String timeSlot,
    required String location,
  }) {
    _currentSlotMealType = mealType;
    _currentSlotTime = timeSlot;
    _currentSlotLocation = location;
    notifyListeners();
  }

  void addToBasket(String dishId) {
    _basket[dishId] = (_basket[dishId] ?? 0) + 1;
    notifyListeners();
  }

  void removeFromBasket(String dishId) {
    if (_basket.containsKey(dishId)) {
      final current = _basket[dishId]!;
      if (current <= 1) {
        _basket.remove(dishId);
      } else {
        _basket[dishId] = current - 1;
      }
      notifyListeners();
    }
  }

  int getQuantity(String dishId) => _basket[dishId] ?? 0;

  void clearBasket() {
    _basket.clear();
    notifyListeners();
  }

  void confirmPlannedMeal({
    required Dish dish,
  }) {
    // Remove existing meal for this day & mealType if any
    _plannedMeals.removeWhere((m) =>
        m.dayOffset == _selectedDayOffset &&
        m.mealType == _currentSlotMealType);

    _plannedMeals.add(PlannedMeal(
      id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
      dayOffset: _selectedDayOffset,
      mealType: _currentSlotMealType,
      timeSlot: _currentSlotTime,
      location: _currentSlotLocation,
      dishName: dish.name,
      imageUrl: dish.imageUrl,
      calories: 320,
      weightGm: 300,
      price: dish.price,
    ));

    clearBasket();
    notifyListeners();
  }

  void setCalorieTarget(int kcal) {
    _calorieStats = _calorieStats.copyWith(
      targetKcal: kcal,
      remainingKcal: kcal - 1000 > 0 ? kcal - 1000 : kcal,
    );
    notifyListeners();
  }

  Dish? _findDish(String id) {
    try {
      return MockData.dishes.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
