import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/dish.dart';
import '../../models/meal_plan.dart';
import '../../routes/app_routes.dart';
import '../../services/menu_service.dart';
import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/dish_card.dart';

/// Meal Menu selection screen for the Food Planner matching the Home Page Food Order layout.
/// Features category tabs, dynamic filtering, horizontal featured rails, category circles,
/// combo lists, chef recommendations, and interactive quantity steppers.
class FoodPlannerMenuScreen extends StatefulWidget {
  const FoodPlannerMenuScreen({super.key});

  @override
  State<FoodPlannerMenuScreen> createState() => _FoodPlannerMenuScreenState();
}

class _FoodPlannerMenuScreenState extends State<FoodPlannerMenuScreen> {
  String _selectedCategory = 'All / Popular';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getCategoriesForMeal(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return const [
          'All / Popular',
          'Dosa & Idli',
          'Appam & Stew',
          'Puttu & Poori',
          'Combos & Sets',
          'Beverages',
        ];
      case MealType.lunch:
        return const [
          'All / Popular',
          'Kerala Meals',
          'Biriyani',
          'Fish Curries',
          'Chicken Special',
          'Veg Rice',
          'Beverages',
        ];
      case MealType.dinner:
        return const [
          'All / Popular',
          'Porotta & Breads',
          'Curries & Roast',
          'Grilled & Tandoori',
          'Light Dinner',
          'Beverages',
        ];
      case MealType.snacks:
        return const [
          'All / Popular',
          'Snacks & Bites',
          'Healthy Bowls',
          'Desserts',
          'Beverages',
        ];
    }
  }

  List<Dish> _getDishesForCategory(MealType mealType, String category) {
    final allDishes = MenuService.instance.dishes.isNotEmpty
        ? MenuService.instance.dishes
        : MockData.dishes;

    final catLower = category.toLowerCase();

    // ── 1. Breakfast Categories ──────────────────────────────────────────────
    if (mealType == MealType.breakfast) {
      if (catLower.contains('all') || catLower.contains('popular') || catLower.contains('frequent')) {
        return [
          MockData.plainDosa,
          MockData.kuzhipaniyaram,
          ...MockData.combinationBreakfast,
          ...MockData.recommendedBreakfast,
        ];
      }
      if (catLower.contains('dosa') || catLower.contains('idli')) {
        return [
          MockData.plainDosa,
          const Dish(
            id: 'masala_dosa',
            name: 'Ghee Roast Masala Dosa',
            price: 110,
            imageUrl: 'assets/images/order/extracted/featured_dosa.webp',
            kcal: 380,
            grams: 320,
            isVeg: true,
            rating: 4.8,
            category: 'Breakfast',
            description: 'Crispy ghee roast filled with tempered spicy potato mash and chutney.',
          ),
          MockData.kuzhipaniyaram,
          const Dish(
            id: 'idli_sambar_main',
            name: 'Steamed Idli & Sambar (4 pcs)',
            price: 90,
            imageUrl: 'assets/images/order/extracted/thumb_idli.webp',
            kcal: 260,
            grams: 280,
            isVeg: true,
            rating: 4.7,
            category: 'Breakfast',
            description: 'Soft, melt-in-the-mouth rice cakes served with piping hot toor dal sambar.',
          ),
          ...MockData.recommendedBreakfast,
        ];
      }
      if (catLower.contains('appam') || catLower.contains('stew')) {
        return [
          const Dish(
            id: 'appam_stew_fp',
            name: 'Appam with Veg Stew (3 pcs)',
            price: 140,
            imageUrl: 'assets/images/order/extracted/thumb_appam.webp',
            kcal: 310,
            grams: 300,
            isVeg: true,
            rating: 4.9,
            category: 'Breakfast',
            description: 'Lacy, soft fermented rice pancakes with mild coconut milk vegetable stew.',
          ),
          const Dish(
            id: 'idiyappam_coconut_milk',
            name: 'Idiyappam & Coconut Milk (4 pcs)',
            price: 120,
            imageUrl: 'assets/images/order/extracted/thumb_idiyappam.webp',
            kcal: 280,
            grams: 260,
            isVeg: true,
            rating: 4.6,
            category: 'Breakfast',
            description: 'Steamed rice string hoppers paired with sweetened cardamom coconut milk.',
          ),
          ...MockData.combinationBreakfast.where((d) => d.name.toLowerCase().contains('appam') || d.name.toLowerCase().contains('idiyappam')),
        ];
      }
      if (catLower.contains('puttu') || catLower.contains('poori')) {
        return [
          const Dish(
            id: 'puttu_kadala_fp',
            name: 'Kerala Matta Puttu & Kadala Curry',
            price: 130,
            imageUrl: 'assets/images/order/extracted/rec_puttu.webp',
            kcal: 420,
            grams: 350,
            isVeg: true,
            rating: 4.8,
            category: 'Breakfast',
            description: 'Traditional steamed red rice puttu layered with freshly grated coconut.',
          ),
          const Dish(
            id: 'poori_bhaji_fp',
            name: 'Fluffy Poori Bhaji (3 pcs)',
            price: 120,
            imageUrl: 'assets/images/order/extracted/thumb_poori.webp',
            kcal: 460,
            grams: 320,
            isVeg: true,
            rating: 4.7,
            category: 'Breakfast',
            description: 'Golden fried pooris served with lightly spiced turmeric potato masala.',
          ),
          ...MockData.combinationBreakfast.where((d) => d.name.toLowerCase().contains('puttu') || d.name.toLowerCase().contains('poori')),
        ];
      }
      if (catLower.contains('beverage')) {
        return [
          MockData.freshJuiceOrange,
          const Dish(
            id: 'filter_coffee',
            name: 'South Indian Filter Coffee',
            price: 50,
            imageUrl: 'assets/images/order/extracted/dish_filter_coffee.webp',
            kcal: 90,
            grams: 180,
            isVeg: true,
            rating: 4.9,
            category: 'Beverages',
            description: 'Freshly brewed aromatic chicory blend with frothy whole milk.',
          ),
          const Dish(
            id: 'malabar_tea',
            name: 'Malabar Spiced Sulaimani Tea',
            price: 40,
            imageUrl: 'assets/images/order/extracted/dish_sulaimani.webp',
            kcal: 45,
            grams: 200,
            isVeg: true,
            rating: 4.8,
            category: 'Beverages',
            description: 'Black tea infused with cardamom, mint, and fresh lemon drops.',
          ),
        ];
      }
      if (catLower.contains('combo')) {
        return MockData.combinationBreakfast;
      }
    }

    // ── 2. Lunch Categories ──────────────────────────────────────────────────
    if (mealType == MealType.lunch) {
      if (catLower.contains('all') || catLower.contains('popular') || catLower.contains('frequent')) {
        return [
          MockData.meals,
          ...MockData.biriyaniDishes,
          ...MockData.chickenDishes,
          ...MockData.fishDishes,
        ];
      }
      if (catLower.contains('meal')) {
        return [
          MockData.meals,
          const Dish(
            id: 'grand_sadya_lunch',
            name: 'Paragon Grand Kerala Sadya',
            price: 240,
            imageUrl: 'assets/images/foodplanner/extracted/card_meals.webp',
            kcal: 680,
            grams: 600,
            isVeg: true,
            rating: 4.9,
            category: 'Meals',
            description: 'Authentic 18-dish feast served with payasam, avial, thoran, and matta rice.',
          ),
          const Dish(
            id: 'executive_veg_thali',
            name: 'Executive Veg Lunch Thali',
            price: 180,
            imageUrl: 'assets/images/foodplanner/extracted/card_meals.webp',
            kcal: 540,
            grams: 480,
            isVeg: true,
            rating: 4.7,
            category: 'Meals',
            description: 'Compact daily executive meal with chapathi, rice, paneer curry, and salad.',
          ),
        ];
      }
      if (catLower.contains('biriyani')) {
        return MockData.biriyaniDishes;
      }
      if (catLower.contains('fish')) {
        return MockData.fishDishes.isNotEmpty
            ? MockData.fishDishes
            : [
                const Dish(
                  id: 'ayala_curry',
                  name: 'Malabar Fish Curry (Mackerel)',
                  price: 220,
                  imageUrl: 'assets/images/order/extracted/dish_fish_curry.webp',
                  kcal: 380,
                  grams: 350,
                  isVeg: false,
                  rating: 4.8,
                  category: 'Fish',
                  description: 'Spicy, tangy fish curry made with kudampuli and coconut oil.',
                ),
              ];
      }
      if (catLower.contains('chicken')) {
        return MockData.chickenDishes;
      }
      if (catLower.contains('rice')) {
        return [
          const Dish(
            id: 'ghee_rice_lunch',
            name: 'Malabar Neychoru (Ghee Rice)',
            price: 140,
            imageUrl: 'assets/images/order/extracted/dish_ghee_rice.webp',
            kcal: 480,
            grams: 400,
            isVeg: true,
            rating: 4.8,
            category: 'Rice',
            description: 'Kaima rice tempered with pure desi ghee, fried cashews, and crisp onions.',
          ),
          ...MockData.biriyaniDishes.where((d) => d.isVeg),
        ];
      }
      if (catLower.contains('beverage')) {
        return [
          MockData.freshJuiceOrange,
          const Dish(
            id: 'spiced_buttermilk',
            name: 'Kerala Sambharam (Spiced Buttermilk)',
            price: 45,
            imageUrl: 'assets/images/order/extracted/dish_buttermilk.webp',
            kcal: 60,
            grams: 250,
            isVeg: true,
            rating: 4.8,
            category: 'Beverages',
            description: 'Cooling churned curd infused with ginger, curry leaves, and green chillies.',
          ),
        ];
      }
    }

    // ── 3. Dinner Categories ─────────────────────────────────────────────────
    if (mealType == MealType.dinner) {
      if (catLower.contains('all') || catLower.contains('popular') || catLower.contains('frequent')) {
        return [
          ...MockData.chickenDishes,
          ...MockData.biriyaniDishes,
          MockData.plainDosa,
          MockData.meals,
        ];
      }
      if (catLower.contains('porotta') || catLower.contains('bread')) {
        return [
          const Dish(
            id: 'malabar_porotta_dinner',
            name: 'Malabar Flaky Porotta (3 pcs)',
            price: 75,
            imageUrl: 'assets/images/order/extracted/dish_porotta.webp',
            kcal: 420,
            grams: 250,
            isVeg: true,
            rating: 4.9,
            category: 'Breads',
            description: 'Layered, flaky, melt-in-the-mouth flatbreads crafted to perfection.',
          ),
          const Dish(
            id: 'wheat_chappathi_dinner',
            name: 'Soft Whole Wheat Chappathi (4 pcs)',
            price: 60,
            imageUrl: 'assets/images/foodplanner/extracted/card_chappathi.webp',
            kcal: 280,
            grams: 200,
            isVeg: true,
            rating: 4.7,
            category: 'Breads',
            description: 'Nutritious whole wheat rotis roasted on a tawa without oil.',
          ),
        ];
      }
      if (catLower.contains('curries') || catLower.contains('roast')) {
        return [
          ...MockData.chickenDishes,
          const Dish(
            id: 'paneer_butter_masala',
            name: 'Paneer Butter Masala',
            price: 190,
            imageUrl: 'assets/images/order/extracted/dish_paneer.webp',
            kcal: 410,
            grams: 350,
            isVeg: true,
            rating: 4.8,
            category: 'Curries',
            description: 'Rich tomato, butter and cashew gravy with fresh cottage cheese cubes.',
          ),
        ];
      }
      if (catLower.contains('grilled') || catLower.contains('tandoori')) {
        return [
          const Dish(
            id: 'chicken_tikka_dinner',
            name: 'Tandoori Chicken Tikka Platter',
            price: 260,
            imageUrl: 'assets/images/order/extracted/dish_tandoori.webp',
            kcal: 450,
            grams: 350,
            isVeg: false,
            rating: 4.9,
            category: 'Grill',
            description: 'Char-grilled boneless chicken chunks marinated in mustard oil & spices.',
          ),
        ];
      }
      if (catLower.contains('light')) {
        return [
          MockData.plainDosa,
          MockData.kuzhipaniyaram,
          ...MockData.combinationBreakfast.where((d) => d.name.contains('Idli') || d.name.contains('Appam')),
        ];
      }
      if (catLower.contains('beverage')) {
        return [
          MockData.freshJuiceOrange,
          const Dish(
            id: 'warm_badam_milk',
            name: 'Warm Saffron Badam Milk',
            price: 70,
            imageUrl: 'assets/images/order/extracted/dish_badam_milk.webp',
            kcal: 180,
            grams: 220,
            isVeg: true,
            rating: 4.9,
            category: 'Beverages',
            description: 'Warm whole milk infused with crushed almonds, cardamom, and Kashmiri saffron.',
          ),
        ];
      }
    }

    // ── 4. Snacks & Drinks Categories ────────────────────────────────────────
    if (mealType == MealType.snacks) {
      if (catLower.contains('all') || catLower.contains('popular') || catLower.contains('frequent')) {
        return [
          MockData.freshJuiceOrange,
          MockData.kuzhipaniyaram,
          ...allDishes.where((d) => d.category.toLowerCase().contains('beverage')),
        ];
      }
      if (catLower.contains('beverage')) {
        return [
          MockData.freshJuiceOrange,
          ...allDishes.where((d) => d.category.toLowerCase().contains('beverage')),
        ];
      }
      if (catLower.contains('snack') || catLower.contains('bite')) {
        return [
          MockData.kuzhipaniyaram,
          ...MockData.vegDishes.take(4),
        ];
      }
      if (catLower.contains('dessert') || catLower.contains('bowl')) {
        return [
          MockData.freshJuiceOrange,
          ...allDishes.where((d) => d.category.toLowerCase().contains('dessert') || d.category.toLowerCase().contains('sweet')),
        ];
      }
    }

    // Generic fallback if none matched
    final fallback = allDishes
        .where((d) =>
            d.category.toLowerCase().contains(catLower) ||
            d.name.toLowerCase().contains(catLower))
        .toList();

    return fallback.isNotEmpty ? fallback : allDishes.take(4).toList();
  }

  void _openProduct(Dish dish) {
    Navigator.of(context).pushNamed(
      AppRoutes.foodPlannerProduct,
      arguments: dish,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FoodPlannerController.instance,
      builder: (context, _) {
        final ctrl = FoodPlannerController.instance;
        final totalItems = ctrl.basketTotalItems;
        final mealType = ctrl.currentSlotMealType;
        final categories = _getCategoriesForMeal(mealType);

        if (!categories.contains(_selectedCategory)) {
          _selectedCategory = categories.first;
        }

        List<Dish> activeDishes;
        if (_searchQuery.trim().isNotEmpty) {
          final q = _searchQuery.toLowerCase().trim();
          final allMenuDishes = MenuService.instance.dishes.isNotEmpty
              ? MenuService.instance.dishes
              : MockData.dishes;
          final seen = <String>{};
          activeDishes = allMenuDishes.where((d) {
            final matches = d.name.toLowerCase().contains(q) ||
                (d.subtitle != null && d.subtitle!.toLowerCase().contains(q)) ||
                d.category.toLowerCase().contains(q) ||
                d.description.toLowerCase().contains(q) ||
                d.ingredients.any((ing) => ing.toLowerCase().contains(q));
            return matches && seen.add(d.name.toLowerCase().trim());
          }).toList();
        } else {
          activeDishes = _getDishesForCategory(mealType, _selectedCategory);
        }

        final screenWidth = MediaQuery.sizeOf(context).width;
        final childAspectRatio = screenWidth < 380 ? 0.68 : 0.72;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADD TO ${mealType.label.toUpperCase()}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Slot: ${ctrl.currentSlotTime} · ${ctrl.currentSlotLocation}',
                  style: const TextStyle(
                    color: AppColors.copper,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: AppColors.accentRed, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${ctrl.getPlannedCaloriesForDay()} / ${ctrl.targetKcal} kcal',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                            // ── Quick Meal Selector Tabs ──────────────────────────
                            _mealTypeSegmentedSwitch(ctrl),
                            const SizedBox(height: 12),

                            // ── Calorie Context Banner ────────────────────────────
                            _calorieBudgetHelper(ctrl, mealType),
                            const SizedBox(height: 12),

                            // ── Search Bar ────────────────────────────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: _searchField(),
                            ),
                            const SizedBox(height: 16),

                            // ── Unified Category Selector (Single, with Icons) ───
                            _categorySelector(categories),
                            const SizedBox(height: 16),

                            // ── Selected Category Header ──────────────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _searchQuery.trim().isNotEmpty
                                          ? 'Search Results for "$_searchQuery"'
                                          : _selectedCategory,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${activeDishes.length} ${activeDishes.length == 1 ? 'dish' : 'dishes'}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),

                      // ── Selected Category Dishes Grid ─────────────────────────
                      if (activeDishes.isEmpty)
                        SliverToBoxAdapter(
                          child: _emptyDishesState(),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: childAspectRatio,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final dish = activeDishes[index];
                                final qty = ctrl.getQuantity(dish.id);
                                return TacoBellProductCard(
                                  dish: dish,
                                  quantity: qty,
                                  onTap: () => _openProduct(dish),
                                  onAdd: () => ctrl.addToBasket(dish.id),
                                  onIncrement: () => ctrl.addToBasket(dish.id),
                                  onDecrement: () => ctrl.removeFromBasket(dish.id),
                                );
                              },
                              childCount: activeDishes.length,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // ── Floating Cart Bar when items in basket ─────────────────────
                  if (totalItems > 0)
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 24 + MediaQuery.paddingOf(context).bottom,
                      child: _floatingCartBar(context, ctrl),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Meal Type Segmented Switch ──────────────────────────────────────────────

  Widget _mealTypeSegmentedSwitch(FoodPlannerController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: MealType.values.map((type) {
            final isSelected = ctrl.currentSlotMealType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  ctrl.setupSlot(
                    mealType: type,
                    timeSlot: type == MealType.breakfast
                        ? '7:30AM'
                        : type == MealType.lunch
                            ? '12:30PM'
                            : '8:00PM',
                    location: ctrl.currentSlotLocation,
                  );
                  setState(() {
                    _selectedCategory = _getCategoriesForMeal(type).first;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.copper : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type.displayName.split(' ').first,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Search Field ────────────────────────────────────────────────────────────

  Widget _searchField() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search dishes across all categories...',
          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ── Calorie Context Banner ──────────────────────────────────────────────────

  Widget _calorieBudgetHelper(FoodPlannerController ctrl, MealType mealType) {
    int targetForSlot;
    switch (mealType) {
      case MealType.breakfast:
        targetForSlot = (ctrl.targetKcal * 0.25).round();
        break;
      case MealType.lunch:
        targetForSlot = (ctrl.targetKcal * 0.35).round();
        break;
      case MealType.dinner:
        targetForSlot = (ctrl.targetKcal * 0.30).round();
        break;
      case MealType.snacks:
        targetForSlot = (ctrl.targetKcal * 0.10).round();
        break;
    }

    final plannedSlotKcal = ctrl.getSlotCalories(ctrl.selectedDayOffset, mealType);
    int basketKcal = 0;
    ctrl.basket.forEach((id, qty) {
      final dish = ctrl.findDish(id);
      if (dish != null) basketKcal += (dish.kcal > 0 ? dish.kcal : 320) * qty;
    });

    final currentTotal = plannedSlotKcal + basketKcal;
    final progress = targetForSlot > 0
        ? (currentTotal / targetForSlot).clamp(0.0, 1.0)
        : 0.0;
    final isOverBudget = targetForSlot > 0 && currentTotal > targetForSlot;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOverBudget
                ? AppColors.accentRed.withValues(alpha: 0.5)
                : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isOverBudget ? AppColors.accentRed : AppColors.copper)
                        .withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: isOverBudget ? AppColors.accentRed : AppColors.copper,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${mealType.displayName.split(' ').first} Target: ~$targetForSlot kcal',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        basketKcal > 0
                            ? '$plannedSlotKcal planned + $basketKcal in cart = $currentTotal kcal'
                            : '$plannedSlotKcal kcal planned for today',
                        style: TextStyle(
                          color: isOverBudget
                              ? AppColors.accentRed
                              : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    color: isOverBudget ? AppColors.accentRed : AppColors.copper,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? AppColors.accentRed : AppColors.copper,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Unified Category Selector (Single, with Icons) ──────────────────────────

  Widget _categorySelector(List<String> categories) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == _selectedCategory && _searchQuery.isEmpty;
          final icon = _getIconForCategory(cat);

          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              setState(() {
                _selectedCategory = cat;
                _searchQuery = '';
                _searchController.clear();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.copper : AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? AppColors.copper : AppColors.border,
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.copper.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.copper,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForCategory(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('all') || lower.contains('popular')) return Icons.auto_awesome_rounded;
    if (lower.contains('dosa') || lower.contains('idli')) return Icons.bakery_dining_rounded;
    if (lower.contains('appam') || lower.contains('stew')) return Icons.rice_bowl_rounded;
    if (lower.contains('puttu') || lower.contains('poori')) return Icons.breakfast_dining_rounded;
    if (lower.contains('meal') || lower.contains('sadya')) return Icons.dinner_dining_rounded;
    if (lower.contains('biriyani')) return Icons.ramen_dining_rounded;
    if (lower.contains('fish')) return Icons.set_meal_rounded;
    if (lower.contains('chicken')) return Icons.kebab_dining_rounded;
    if (lower.contains('porotta') || lower.contains('bread')) return Icons.flatware_rounded;
    if (lower.contains('grill') || lower.contains('tandoori')) return Icons.outdoor_grill_rounded;
    if (lower.contains('snack') || lower.contains('bite')) return Icons.lunch_dining_rounded;
    if (lower.contains('dessert') || lower.contains('bowl')) return Icons.icecream_rounded;
    if (lower.contains('beverage') || lower.contains('drink')) return Icons.local_drink_rounded;
    if (lower.contains('combo')) return Icons.local_offer_rounded;
    return Icons.restaurant_menu_rounded;
  }

  // ── Empty State ─────────────────────────────────────────────────────────────

  Widget _emptyDishesState() {
    final isSearching = _searchQuery.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.search_off_rounded : Icons.restaurant_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              isSearching
                  ? 'No dishes matching "$_searchQuery"'
                  : 'No items found in this category',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              isSearching
                  ? 'Try searching with a different dish name or clear search.'
                  : 'Select another category above to view delicious options.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSearching) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.copper,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Floating Cart Bar ───────────────────────────────────────────────────────

  Widget _floatingCartBar(BuildContext context, FoodPlannerController ctrl) {
    int totalKcal = 0;
    ctrl.basket.forEach((dishId, qty) {
      final dish = ctrl.findDish(dishId);
      if (dish != null) {
        totalKcal += (dish.kcal > 0 ? dish.kcal : 320) * qty;
      }
    });

    final mealLabel = ctrl.currentSlotMealType.label;

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.accentRed,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${ctrl.basketTotalItems} ${ctrl.basketTotalItems == 1 ? 'ITEM' : 'ITEMS'} · $totalKcal kcal',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              ctrl.confirmBasketToPlan();
              AppToast.showSuccess(
                context,
                '$mealLabel plan saved! Added $totalKcal kcal to your schedule.',
                title: 'Plan Updated',
              );
              Navigator.of(context).popUntil((route) =>
                  route.settings.name == AppRoutes.foodPlanner ||
                  route.isFirst);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CONFIRM $mealLabel',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
