import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/dish.dart';
import '../../models/meal_plan.dart';
import '../../routes/app_routes.dart';
import '../../services/menu_service.dart';
import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/network_image_with_fallback.dart';

/// Meal Menu selection screen for the Food Planner matching the Home Page Food Order layout.
/// Features category tabs, dynamic filtering, horizontal featured rails, category circles,
/// combo lists, chef recommendations, and interactive quantity steppers.
class FoodPlannerMenuScreen extends StatefulWidget {
  const FoodPlannerMenuScreen({super.key});

  @override
  State<FoodPlannerMenuScreen> createState() => _FoodPlannerMenuScreenState();
}

class _FoodPlannerMenuScreenState extends State<FoodPlannerMenuScreen> {
  String _selectedCategory = 'Frequent order';
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
          'Frequent order',
          'Dosa & Idli',
          'Appam & Stew',
          'Puttu & Poori',
          'Beverages',
          'Combos',
        ];
      case MealType.lunch:
        return const [
          'Frequent order',
          'Kerala Meals',
          'Biriyani',
          'Fish Curries',
          'Chicken Special',
          'Veg Rice',
          'Beverages',
        ];
      case MealType.dinner:
        return const [
          'Frequent order',
          'Porotta & Breads',
          'Curries & Roast',
          'Grilled & Tandoori',
          'Light Dinner',
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
      if (catLower == 'frequent order' || catLower == 'all') {
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
      if (catLower == 'frequent order' || catLower == 'all') {
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
      if (catLower == 'frequent order' || catLower == 'all') {
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

        var activeDishes = _getDishesForCategory(mealType, _selectedCategory);

        if (_searchQuery.trim().isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          activeDishes = activeDishes.where((d) {
            return d.name.toLowerCase().contains(q) ||
                d.description.toLowerCase().contains(q) ||
                d.category.toLowerCase().contains(q);
          }).toList();
        }

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
                  '${mealType.label.toUpperCase()} MENU',
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
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: AppColors.textPrimary, size: 22),
                onPressed: () {
                  if (totalItems > 0) {
                    Navigator.of(context).pushNamed(AppRoutes.foodPlannerCart);
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  const SizedBox(height: 8),

                  // ── Quick Meal Selector Tabs ──────────────────────────────
                  _mealTypeSegmentedSwitch(ctrl),
                  const SizedBox(height: 14),

                  // ── Search Bar ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _searchField(),
                  ),
                  const SizedBox(height: 16),

                  // ── Category Pills (Horizontal) ───────────────────────────
                  _categoryPills(categories),
                  const SizedBox(height: 20),

                  // ── Featured Dishes Section ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedCategory == 'Frequent order'
                              ? '${mealType.label} Specials'
                              : _selectedCategory,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${activeDishes.length} items',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Main Food Cards Rail ──────────────────────────────────
                  _featuredFoodCardsRail(ctrl, activeDishes),
                  const SizedBox(height: 28),

                  // ── Explore Categories Icons Grid ─────────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Explore by Category',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _categoryCirclesGrid(mealType, categories),
                  const SizedBox(height: 28),

                  // ── Combination / Set Platters Section ────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          mealType == MealType.breakfast
                              ? 'Combination Breakfast'
                              : mealType == MealType.lunch
                                  ? 'Combination Lunch Platters'
                                  : 'Combination Dinner Sets',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _combinationList(ctrl, mealType),
                  const SizedBox(height: 28),

                  // ── Chef Recommended Specials Rail ────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chef Recommended for ${mealType.label}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _recommendedRail(ctrl, mealType),
                ],
              ),

              // ── Floating Cart Bar when items in basket ─────────────────────
              if (totalItems > 0)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24,
                  child: _floatingCartBar(context, ctrl),
                ),
            ],
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
                    type.label,
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
          hintText: 'Search in this menu...',
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

  // ── Category Pills (Horizontal) ─────────────────────────────────────────────

  Widget _categoryPills(List<String> categories) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.copper : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.copper : AppColors.border,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Main Food Cards Rail ────────────────────────────────────────────────────

  Widget _featuredFoodCardsRail(FoodPlannerController ctrl, List<Dish> dishes) {
    if (dishes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              'No items found in this category.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 275,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: dishes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final dish = dishes[index];
          final qty = ctrl.getQuantity(dish.id);

          return GestureDetector(
            onTap: () => _openProduct(dish),
            child: Container(
              width: 185,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: NetworkImageWithFallback(
                        url: dish.imageUrl,
                        fallbackIcon: Icons.restaurant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Title & Veg indicator
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: dish.isVeg
                              ? const Color(0xFF22C55E)
                              : AppColors.accentRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          dish.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Price & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹ ${dish.price.toInt()}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            dish.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Macro badges
                  Text(
                    '🔥 ${dish.kcal} kcal · ⚖️ ${dish.grams} gm',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),

                  // Stepper Add Button
                  _QuantityButton(
                    quantity: qty,
                    onAdd: () => ctrl.addToBasket(dish.id),
                    onIncrement: () => ctrl.addToBasket(dish.id),
                    onDecrement: () => ctrl.removeFromBasket(dish.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Explore Categories Grid ─────────────────────────────────────────────────

  Widget _categoryCirclesGrid(MealType mealType, List<String> categories) {
    final displayCats = categories.where((c) => c != 'Frequent order').toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: displayCats.length,
        itemBuilder: (context, i) {
          final cat = displayCats[i];
          final isSelected = cat == _selectedCategory;
          final icon = _getIconForCategory(cat);

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.copper.withValues(alpha: 0.25)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.copper : AppColors.border,
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.copper
                          : AppColors.surfaceLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : AppColors.copper,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      cat,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.copper
                            : AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
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
    if (lower.contains('dosa') || lower.contains('idli')) return Icons.bakery_dining_rounded;
    if (lower.contains('appam') || lower.contains('stew')) return Icons.rice_bowl_rounded;
    if (lower.contains('puttu') || lower.contains('poori')) return Icons.breakfast_dining_rounded;
    if (lower.contains('meal') || lower.contains('sadya')) return Icons.dinner_dining_rounded;
    if (lower.contains('biriyani')) return Icons.ramen_dining_rounded;
    if (lower.contains('fish')) return Icons.set_meal_rounded;
    if (lower.contains('chicken')) return Icons.kebab_dining_rounded;
    if (lower.contains('porotta') || lower.contains('bread')) return Icons.flatware_rounded;
    if (lower.contains('grill') || lower.contains('tandoori')) return Icons.outdoor_grill_rounded;
    if (lower.contains('beverage')) return Icons.local_drink_rounded;
    return Icons.restaurant_menu_rounded;
  }

  // ── Combination List ────────────────────────────────────────────────────────

  Widget _combinationList(FoodPlannerController ctrl, MealType mealType) {
    final List<Map<String, dynamic>> combos;
    switch (mealType) {
      case MealType.breakfast:
        combos = [
          {
            'id': 'appam_stew_c',
            'title': 'Appam & Vegetable Stew (2 nos)',
            'price': 160,
            'imageUrl': 'assets/images/order/extracted/thumb_appam.webp',
          },
          {
            'id': 'idiyappam_kadala_c',
            'title': 'Idiyappam & Kadala Curry (4 nos)',
            'price': 170,
            'imageUrl': 'assets/images/order/extracted/thumb_idiyappam.webp',
          },
          {
            'id': 'puttu_kadala_c',
            'title': 'Puttu & Spiced Kadala Curry',
            'price': 150,
            'imageUrl': 'assets/images/order/extracted/rec_puttu.webp',
          },
        ];
        break;
      case MealType.lunch:
        combos = [
          {
            'id': 'seafood_sadhya_c',
            'title': 'Paragon Seafood Sadhya Thali',
            'price': 340,
            'imageUrl': 'assets/images/foodplanner/extracted/card_meals.webp',
          },
          {
            'id': 'thalassery_biryani_c',
            'title': 'Thalassery Chicken Biryani Combo',
            'price': 290,
            'imageUrl': 'assets/images/order/extracted/dish_chicken_biryani.webp',
          },
        ];
        break;
      case MealType.dinner:
        combos = [
          {
            'id': 'porotta_beef_c',
            'title': 'Malabar Porotta (3 nos) & Curry',
            'price': 240,
            'imageUrl': 'assets/images/order/extracted/dish_porotta.webp',
          },
          {
            'id': 'appam_roast_c',
            'title': 'Appam (3 nos) & Egg Roast',
            'price': 220,
            'imageUrl': 'assets/images/order/extracted/dish_egg_roast.webp',
          },
        ];
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: combos.map((item) {
          final id = item['id'] as String;
          final title = item['title'] as String;
          final price = item['price'] as int;
          final imageUrl = item['imageUrl'] as String;
          final qty = ctrl.getQuantity(id);

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: NetworkImageWithFallback(
                      url: imageUrl,
                      fallbackIcon: Icons.restaurant,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹ $price',
                        style: const TextStyle(
                          color: AppColors.copper,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: _QuantityButton(
                    quantity: qty,
                    onAdd: () => ctrl.addToBasket(id),
                    onIncrement: () => ctrl.addToBasket(id),
                    onDecrement: () => ctrl.removeFromBasket(id),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Chef Recommended Rail ───────────────────────────────────────────────────

  Widget _recommendedRail(FoodPlannerController ctrl, MealType mealType) {
    final List<Map<String, dynamic>> recommended;
    switch (mealType) {
      case MealType.breakfast:
        recommended = [
          {
            'id': 'plain_dosa_rec',
            'title': 'Plain Dosa (2 nos)',
            'price': 140,
            'imageUrl': 'assets/images/order/extracted/featured_dosa.webp',
          },
          {
            'id': 'puttu_kadala_rec',
            'title': 'Puttu & Kadala',
            'price': 150,
            'imageUrl': 'assets/images/order/extracted/rec_puttu.webp',
          },
        ];
        break;
      case MealType.lunch:
        recommended = [
          {
            'id': 'paragon_biriyani_rec',
            'title': 'Paragon Dum Biryani',
            'price': 260,
            'imageUrl': 'assets/images/order/extracted/dish_chicken_biryani.webp',
          },
          {
            'id': 'kerala_meals_rec',
            'title': 'Special Kerala Meals',
            'price': 220,
            'imageUrl': 'assets/images/foodplanner/extracted/card_meals.webp',
          },
        ];
        break;
      case MealType.dinner:
        recommended = [
          {
            'id': 'malabar_parotta_rec',
            'title': 'Malabar Coin Porotta (5 nos)',
            'price': 160,
            'imageUrl': 'assets/images/order/extracted/dish_porotta.webp',
          },
          {
            'id': 'tandoori_chicken_rec',
            'title': 'Grilled Chicken Tikka',
            'price': 290,
            'imageUrl': 'assets/images/order/extracted/dish_tandoori.webp',
          },
        ];
        break;
    }

    return SizedBox(
      height: 250,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: recommended.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = recommended[index];
          final id = item['id'] as String;
          final title = item['title'] as String;
          final price = item['price'] as int;
          final imageUrl = item['imageUrl'] as String;
          final qty = ctrl.getQuantity(id);

          return Container(
            width: 165,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: NetworkImageWithFallback(
                      url: imageUrl,
                      fallbackIcon: Icons.restaurant,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹ $price',
                  style: const TextStyle(
                    color: AppColors.copper,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '🔥 320 kcal · ⚖️ 300 gm',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                ),
                const Spacer(),
                _QuantityButton(
                  quantity: qty,
                  onAdd: () => ctrl.addToBasket(id),
                  onIncrement: () => ctrl.addToBasket(id),
                  onDecrement: () => ctrl.removeFromBasket(id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Floating Cart Bar ───────────────────────────────────────────────────────

  Widget _floatingCartBar(BuildContext context, FoodPlannerController ctrl) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.copper,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${ctrl.basketTotalItems} ${ctrl.basketTotalItems == 1 ? 'ITEM' : 'ITEMS'} · ₹${ctrl.basketSubtotal.toInt()}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.8,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.foodPlannerCart);
            },
            child: const Row(
              children: [
                Text(
                  'VIEW CART',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quantity Stepper Button ───────────────────────────────────────────────────

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.quantity,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return SizedBox(
        width: double.infinity,
        height: 32,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            padding: EdgeInsets.zero,
          ),
          onPressed: onAdd,
          child: const Text(
            'ADD',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.accentRed,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onDecrement,
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}
