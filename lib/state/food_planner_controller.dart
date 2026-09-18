import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import '../data/food_planner_assets.dart';
import '../data/mock_data.dart';
import '../models/dish.dart';
import '../models/meal_plan.dart';
import '../services/food_planner_service.dart';

/// Singleton [ChangeNotifier] for managing the entire Food Planner workflow,
/// including meal plans, calorie targets, tracking, and cart.
class FoodPlannerController extends ChangeNotifier {
  FoodPlannerController._() {
    _initDefaults();
    _loadFromFirestore();
  }

  static final FoodPlannerController instance = FoodPlannerController._();

  int _activeTabIndex = 0;
  int get activeTabIndex => _activeTabIndex;

  int _selectedDayOffset = 0; // 0 for Jan 2 (Tue)
  int get selectedDayOffset => _selectedDayOffset;

  int _targetKcal = 2000;
  int get targetKcal => _targetKcal;
  int get dailyCalorieBudget => _targetKcal;
  int getDayCalories([int? dayOffset]) => getPlannedCaloriesForDay(dayOffset);

  CalorieStats get calorieStats => getCalorieStatsForDay(_selectedDayOffset);

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
      final dish = findDish(dishId);
      if (dish != null) total += dish.price * qty;
    });
    return total;
  }

  Future<void> _loadFromFirestore() async {
    final remotePlans = await FoodPlannerService.instance.fetchUserMealPlans();
    if (remotePlans != null && remotePlans.isNotEmpty) {
      _plannedMeals
        ..clear()
        ..addAll(remotePlans);
      notifyListeners();
    }
  }

  void _initDefaults() {
    _targetKcal = 2000;

    // Populate default planned meals across the week
    final defaultDayPlans = [
      // Day 0: Jan 2 (Tue)
      [
        PlannedMeal(
          id: 'pm_0_1',
          dayOffset: 0,
          mealType: MealType.breakfast,
          timeSlot: '7:30AM',
          location: 'HOME',
          dishName: 'Plain Dosa',
          imageUrl: FoodPlannerAssets.cardDosa,
          servings: 2,
          calories: 280,
          weightGm: 220,
          price: 80,
          protein: 8,
          carbs: 46,
          fat: 8,
        ),
        PlannedMeal(
          id: 'pm_0_2',
          dayOffset: 0,
          mealType: MealType.breakfast,
          timeSlot: '8:00AM',
          location: 'HOME',
          dishName: 'Orange Juice',
          imageUrl: MockData.freshJuiceOrange.imageUrl,
          servings: 1,
          calories: 120,
          weightGm: 250,
          price: 70,
          protein: 2,
          carbs: 28,
          fat: 1,
        ),
        PlannedMeal(
          id: 'pm_0_3',
          dayOffset: 0,
          mealType: MealType.lunch,
          timeSlot: '12:30PM',
          location: 'OFFICE',
          dishName: 'Special Kerala Meals',
          imageUrl: FoodPlannerAssets.cardMeals,
          servings: 1,
          calories: 640,
          weightGm: 450,
          price: 150,
          protein: 20,
          carbs: 98,
          fat: 16,
        ),
        PlannedMeal(
          id: 'pm_0_4',
          dayOffset: 0,
          mealType: MealType.dinner,
          timeSlot: '8:00PM',
          location: 'HOME',
          dishName: 'Chappathi Curry',
          imageUrl: FoodPlannerAssets.cardChappathi,
          servings: 1,
          calories: 460,
          weightGm: 320,
          price: 120,
          protein: 15,
          carbs: 58,
          fat: 14,
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

  static String dateStringForOffset(int offset) {
    final date = DateTime.now().add(Duration(days: offset));
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String get selectedDateString => dateStringForOffset(_selectedDayOffset);

  void selectDay(int offset) {
    if (_selectedDayOffset != offset) {
      _selectedDayOffset = offset;
      notifyListeners();
    }
  }

  List<PlannedMeal> getMealsForDay([int? dayOffset]) {
    final offset = dayOffset ?? _selectedDayOffset;
    final dateStr = dateStringForOffset(offset);
    return _plannedMeals
        .where((m) =>
            (m.date != null && m.date == dateStr) ||
            (m.date == null && m.dayOffset == offset))
        .toList();
  }

  List<PlannedMeal> getMealsForSelectedDay() {
    return getMealsForDay(_selectedDayOffset);
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

  int getPlannedCaloriesForDay([int? dayOffset]) {
    final dayMeals = getMealsForDay(dayOffset);
    return dayMeals.fold<int>(0, (sum, m) => sum + m.calories);
  }

  CalorieStats getCalorieStatsForDay([int? dayOffset]) {
    final offset = dayOffset ?? _selectedDayOffset;
    final dayMeals = getMealsForDay(offset);
    final plannedKcal = dayMeals.fold<int>(0, (sum, m) => sum + m.calories);
    final remaining = math.max(0, _targetKcal - plannedKcal);

    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;

    for (final meal in dayMeals) {
      totalProtein += meal.protein;
      totalCarbs += meal.carbs;
      totalFat += meal.fat;
    }

    // Baseline targets if no meals planned yet
    if (totalProtein == 0 && totalCarbs == 0 && totalFat == 0) {
      totalProtein = 45;
      totalCarbs = 65;
      totalFat = 30;
    }

    return CalorieStats(
      targetKcal: _targetKcal,
      remainingKcal: remaining,
      proteinG: totalProtein,
      carbsG: totalCarbs,
      fatG: totalFat,
    );
  }

  void removeMeal(String mealId) {
    _plannedMeals.removeWhere((m) => m.id == mealId);
    FoodPlannerService.instance.savePlannedMeals(_plannedMeals);
    notifyListeners();
  }

  void updateMealServings(String mealId, int newServings) {
    final index = _plannedMeals.indexWhere((m) => m.id == mealId);
    if (index < 0) return;

    if (newServings <= 0) {
      _plannedMeals.removeAt(index);
    } else {
      final meal = _plannedMeals[index];
      final currentServings = meal.servings > 0 ? meal.servings : 1;
      final unitKcal = (meal.calories / currentServings).round();
      final unitWeight = (meal.weightGm / currentServings).round();
      final unitPrice = meal.price / currentServings;
      final unitProtein = (meal.protein / currentServings).round();
      final unitCarbs = (meal.carbs / currentServings).round();
      final unitFat = (meal.fat / currentServings).round();

      _plannedMeals[index] = meal.copyWith(
        servings: newServings,
        calories: unitKcal * newServings,
        weightGm: unitWeight * newServings,
        price: unitPrice * newServings,
        protein: unitProtein * newServings,
        carbs: unitCarbs * newServings,
        fat: unitFat * newServings,
      );
    }

    FoodPlannerService.instance.savePlannedMeals(_plannedMeals);
    notifyListeners();
  }

  void clearSlot(int dayOffset, MealType mealType) {
    final dateStr = dateStringForOffset(dayOffset);
    _plannedMeals.removeWhere((m) =>
        ((m.date != null && m.date == dateStr) || m.dayOffset == dayOffset) &&
        m.mealType == mealType);
    FoodPlannerService.instance.savePlannedMeals(_plannedMeals);
    notifyListeners();
  }

  List<PlannedMeal> getMealsForSlot(int dayOffset, MealType type) {
    final dateStr = dateStringForOffset(dayOffset);
    return _plannedMeals
        .where((m) =>
            ((m.date != null && m.date == dateStr) ||
                (m.date == null && m.dayOffset == dayOffset)) &&
            m.mealType == type)
        .toList();
  }

  int getSlotCalories(int dayOffset, MealType type) {
    return getMealsForSlot(dayOffset, type)
        .fold<int>(0, (sum, m) => sum + m.calories);
  }

  int getSlotProtein(int dayOffset, MealType type) {
    return getMealsForSlot(dayOffset, type)
        .fold<int>(0, (sum, m) => sum + m.protein);
  }

  int getSlotCarbs(int dayOffset, MealType type) {
    return getMealsForSlot(dayOffset, type)
        .fold<int>(0, (sum, m) => sum + m.carbs);
  }

  int getSlotFat(int dayOffset, MealType type) {
    return getMealsForSlot(dayOffset, type)
        .fold<int>(0, (sum, m) => sum + m.fat);
  }

  void confirmPlannedMeal({
    required Dish dish,
    int? dayOffset,
    MealType? mealType,
    String? timeSlot,
    String? location,
    int quantity = 1,
  }) {
    final offset = dayOffset ?? _selectedDayOffset;
    final dateStr = dateStringForOffset(offset);
    final type = mealType ?? _currentSlotMealType;
    final time = timeSlot ?? _currentSlotTime;
    final loc = location ?? _currentSlotLocation;

    final baseKcal = dish.kcal > 0 ? dish.kcal : 320;
    final baseGrams = dish.grams > 0 ? dish.grams : 300;
    final baseProtein = dish.protein > 0 ? dish.protein : ((baseKcal * 0.20) / 4).round();
    final baseCarbs = dish.carbs > 0 ? dish.carbs : ((baseKcal * 0.50) / 4).round();
    final baseFat = dish.fat > 0 ? dish.fat : ((baseKcal * 0.30) / 9).round();

    // Check if this dish is already in this slot
    final existingIndex = _plannedMeals.indexWhere(
      (m) =>
          ((m.date != null && m.date == dateStr) || m.dayOffset == offset) &&
          m.mealType == type &&
          (m.dishId == dish.id || m.dishName == dish.name),
    );

    if (existingIndex >= 0) {
      final existing = _plannedMeals[existingIndex];
      final newServings = existing.servings + quantity;
      _plannedMeals[existingIndex] = existing.copyWith(
        servings: newServings,
        date: dateStr,
        calories: baseKcal * newServings,
        weightGm: baseGrams * newServings,
        price: dish.price * newServings,
        protein: baseProtein * newServings,
        carbs: baseCarbs * newServings,
        fat: baseFat * newServings,
        timeSlot: time,
        location: loc,
      );
    } else {
      final newMeal = PlannedMeal(
        id: 'pm_${DateTime.now().microsecondsSinceEpoch}_${dish.id}',
        dayOffset: offset,
        date: dateStr,
        mealType: type,
        timeSlot: time,
        location: loc,
        dishId: dish.id,
        dishName: dish.name,
        imageUrl: dish.imageUrl,
        servings: quantity,
        calories: baseKcal * quantity,
        weightGm: baseGrams * quantity,
        price: dish.price * quantity,
        protein: baseProtein * quantity,
        carbs: baseCarbs * quantity,
        fat: baseFat * quantity,
      );
      _plannedMeals.add(newMeal);
    }

    FoodPlannerService.instance.savePlannedMeals(_plannedMeals);
    clearBasket();
    notifyListeners();
  }

  void confirmBasketToPlan({
    int? dayOffset,
    MealType? mealType,
    String? timeSlot,
    String? location,
  }) {
    final offset = dayOffset ?? _selectedDayOffset;
    final type = mealType ?? _currentSlotMealType;
    final time = timeSlot ?? _currentSlotTime;
    final loc = location ?? _currentSlotLocation;

    if (_basket.isEmpty) return;

    _basket.forEach((dishId, qty) {
      final dish = findDish(dishId);
      if (dish != null && qty > 0) {
        confirmPlannedMeal(
          dish: dish,
          dayOffset: offset,
          mealType: type,
          timeSlot: time,
          location: loc,
          quantity: qty,
        );
      }
    });

    clearBasket();
    notifyListeners();
  }

  void setCalorieTarget(int kcal) {
    _targetKcal = kcal;
    FoodPlannerService.instance.saveCalorieStats(calorieStats);
    notifyListeners();
  }

  Dish? findDish(String id) {
    try {
      return MockData.dishes.firstWhere((d) => d.id == id);
    } catch (_) {
      try {
        final all = [
          ...MockData.dishes,
          ...MockData.frequentOrders,
          ...MockData.combinationBreakfast,
          ...MockData.recommendedBreakfast,
          ...MockData.chickenDishes,
          ...MockData.biriyaniDishes,
          ...MockData.fishDishes,
          ...MockData.vegDishes,
          ...MockData.eggDishes,
          ...MockData.mealsDishes,
          ...MockData.vegRiceDishes,
          MockData.meals,
          MockData.freshJuiceOrange,
          MockData.plainDosa,
          MockData.kuzhipaniyaram,
        ];
        return all.firstWhere((d) => d.id == id);
      } catch (_) {
        return null;
      }
    }
  }
}
