import 'package:flutter/material.dart';

import '../../data/food_planner_assets.dart';
import '../../data/mock_data.dart';
import '../../models/dish.dart';
import '../../models/meal_plan.dart';
import '../../routes/app_routes.dart';
import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';

/// Meal Menu selection screen for the Food Planner matching Plan food.png and Add to cart.png.
class FoodPlannerMenuScreen extends StatefulWidget {
  const FoodPlannerMenuScreen({super.key});

  @override
  State<FoodPlannerMenuScreen> createState() => _FoodPlannerMenuScreenState();
}

class _FoodPlannerMenuScreenState extends State<FoodPlannerMenuScreen> {
  String _selectedCategory = 'Frequent order';

  List<String> _getCategoriesForMeal(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return const ['Frequent order', 'Dosa & Idli', 'Appam & Stew', 'Puttu & Poori', 'Beverages'];
      case MealType.lunch:
        return const ['Frequent order', 'Kerala Meals', 'Biriyani', 'Fish Curries', 'Chicken Special', 'Veg Rice'];
      case MealType.dinner:
        return const ['Frequent order', 'Porotta & Breads', 'Curries & Roast', 'Grilled & Tandoori', 'Light Dinner'];
    }
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
                const Text(
                  'Jan 2 ,2023 - Tuesday',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${mealType.label} ( ${ctrl.currentSlotTime} ) - ${ctrl.currentSlotLocation}',
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
                icon: const Icon(Icons.search,
                    color: AppColors.textPrimary, size: 22),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.search),
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
                  // ── Category Pills ──────────────────────────────────────────
                  _categoryPills(categories),
                  const SizedBox(height: 20),

                  // ── Frequent Order / Featured Horizontal Rail ───────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      mealType == MealType.breakfast
                          ? 'Frequent Order'
                          : mealType == MealType.lunch
                              ? 'Popular Lunch Specials'
                              : 'Popular Dinner Specials',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _featuredRail(ctrl, mealType),
                  const SizedBox(height: 28),

                  // ── Combination Section ─────────────────────────────────────
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

                  // ── Recommended Horizontal Rail ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          mealType == MealType.breakfast
                              ? 'Recommended for Breakfast'
                              : mealType == MealType.lunch
                                  ? 'Chef Recommended Lunch'
                                  : 'Chef Recommended Dinner',
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

              // ── Floating Cart Bar when items in basket ───────────────────────
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

  Widget _featuredRail(FoodPlannerController ctrl, MealType mealType) {
    final List<Map<String, dynamic>> featured;
    switch (mealType) {
      case MealType.breakfast:
        featured = [
          {
            'dish': MockData.plainDosa,
            'asset': FoodPlannerAssets.featuredDosa,
          },
          {
            'dish': MockData.kuzhipaniyaram,
            'asset': FoodPlannerAssets.featuredKuzhi,
          },
        ];
        break;
      case MealType.lunch:
        featured = [
          {
            'dish': MockData.meals,
            'asset': FoodPlannerAssets.cardMeals,
          },
          {
            'dish': MockData.plainDosa,
            'asset': FoodPlannerAssets.featuredDosa,
          },
        ];
        break;
      case MealType.dinner:
        featured = [
          {
            'dish': MockData.meals,
            'asset': FoodPlannerAssets.cardChappathi,
          },
          {
            'dish': MockData.kuzhipaniyaram,
            'asset': FoodPlannerAssets.featuredKuzhi,
          },
        ];
        break;
    }

    return SizedBox(
      height: 256,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: featured.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = featured[index];
          final dish = item['dish'] as Dish;
          final asset = item['asset'] as String;
          final qty = ctrl.getQuantity(dish.id);

          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.foodPlannerProduct,
                arguments: dish,
              );
            },
            child: Container(
              width: 175,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: Image.asset(
                        asset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.network(
                          dish.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.surfaceLight,
                            child: const Icon(Icons.restaurant,
                                color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    dish.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹ ${dish.price.toInt()}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '🔥 ${dish.kcal} kcal  ⚖️ ${dish.grams} gm',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  const Spacer(),
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

  Widget _combinationList(FoodPlannerController ctrl, MealType mealType) {
    final List<Map<String, dynamic>> combos;
    switch (mealType) {
      case MealType.breakfast:
        combos = [
          {
            'id': 'appam_stew',
            'title': 'Appam & Stew - 2 nos',
            'price': 180,
            'asset': FoodPlannerAssets.thumbAppam,
            'fallback': FoodPlannerAssets.appamStew,
          },
          {
            'id': 'idiyappam_kadala',
            'title': 'Idiyappam & Kadala curry - 4 nos',
            'price': 180,
            'asset': FoodPlannerAssets.thumbIdiyappam,
            'fallback': FoodPlannerAssets.idiyappam,
          },
          {
            'id': 'puttu_kadala',
            'title': 'Puttu & Kadala curry - 2 nos',
            'price': 180,
            'asset': FoodPlannerAssets.thumbPuttu,
            'fallback': FoodPlannerAssets.puttuKadala,
          },
          {
            'id': 'poori_masala',
            'title': 'Poori Masala - 2 nos',
            'price': 180,
            'asset': FoodPlannerAssets.thumbPoori,
            'fallback': FoodPlannerAssets.pooriMasala,
          },
          {
            'id': 'idli_sambar',
            'title': 'Idli & Sambar - 4 nos',
            'price': 180,
            'asset': FoodPlannerAssets.thumbIdli,
            'fallback': FoodPlannerAssets.idliSambar,
          },
        ];
        break;
      case MealType.lunch:
        combos = [
          {
            'id': 'seafood_sadhya',
            'title': 'Paragon Seafood Sadhya Thali',
            'price': 340,
            'asset': FoodPlannerAssets.cardMeals,
            'fallback': FoodPlannerAssets.meals,
          },
          {
            'id': 'thalassery_biryani_combo',
            'title': 'Thalassery Chicken Biryani Combo',
            'price': 290,
            'asset': FoodPlannerAssets.cardMeals,
            'fallback': FoodPlannerAssets.meals,
          },
          {
            'id': 'veg_executive_meal',
            'title': 'Grand Kerala Veg Feast',
            'price': 220,
            'asset': FoodPlannerAssets.cardMeals,
            'fallback': FoodPlannerAssets.meals,
          },
        ];
        break;
      case MealType.dinner:
        combos = [
          {
            'id': 'porotta_beef_combo',
            'title': 'Kerala Porotta (3 nos) & Curry',
            'price': 260,
            'asset': FoodPlannerAssets.cardChappathi,
            'fallback': FoodPlannerAssets.chappathi,
          },
          {
            'id': 'appam_roast_combo',
            'title': 'Appam (3 nos) & Vegetable Stew',
            'price': 280,
            'asset': FoodPlannerAssets.thumbAppam,
            'fallback': FoodPlannerAssets.appamStew,
          },
          {
            'id': 'wheat_phulka_combo',
            'title': 'Wheat Phulka (4 nos) & Paneer Gravy',
            'price': 240,
            'asset': FoodPlannerAssets.thumbPoori,
            'fallback': FoodPlannerAssets.pooriMasala,
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
          final asset = item['asset'] as String;
          final fallback = item['fallback'] as String;
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
                    child: Image.asset(
                      asset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.network(
                        fallback,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceLight,
                          child: const Icon(Icons.restaurant,
                              color: AppColors.textSecondary),
                        ),
                      ),
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
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹ $price',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _QuantityButton(
                  quantity: qty,
                  onAdd: () => ctrl.addToBasket(id),
                  onIncrement: () => ctrl.addToBasket(id),
                  onDecrement: () => ctrl.removeFromBasket(id),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _recommendedRail(FoodPlannerController ctrl, MealType mealType) {
    final List<Map<String, dynamic>> recommended;
    switch (mealType) {
      case MealType.breakfast:
        recommended = [
          {
            'id': 'plain_dosa_2',
            'title': 'Plain Dosa - 2 nos',
            'price': 180,
            'asset': FoodPlannerAssets.recDosa,
            'fallback': FoodPlannerAssets.dosa,
          },
          {
            'id': 'puttu_kadala_2',
            'title': 'Puttu and Kadala',
            'price': 180,
            'asset': FoodPlannerAssets.recPuttu,
            'fallback': FoodPlannerAssets.puttuKadala,
          },
        ];
        break;
      case MealType.lunch:
        recommended = [
          {
            'id': 'paragon_biriyani_rec',
            'title': 'Paragon Dum Biryani',
            'price': 260,
            'asset': FoodPlannerAssets.cardMeals,
            'fallback': FoodPlannerAssets.meals,
          },
          {
            'id': 'kerala_meals_rec',
            'title': 'Special Kerala Meals',
            'price': 220,
            'asset': FoodPlannerAssets.cardMeals,
            'fallback': FoodPlannerAssets.meals,
          },
        ];
        break;
      case MealType.dinner:
        recommended = [
          {
            'id': 'malabar_parotta_rec',
            'title': 'Malabar Coin Porotta (5 nos)',
            'price': 160,
            'asset': FoodPlannerAssets.cardChappathi,
            'fallback': FoodPlannerAssets.chappathi,
          },
          {
            'id': 'tandoori_chicken_rec',
            'title': 'Grilled Chicken Tikka',
            'price': 290,
            'asset': FoodPlannerAssets.featuredDosa,
            'fallback': FoodPlannerAssets.dosa,
          },
        ];
        break;
    }

    return SizedBox(
      height: 272,
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
          final asset = item['asset'] as String;
          final fallback = item['fallback'] as String;
          final qty = ctrl.getQuantity(id);

          return Container(
            width: 165,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset(
                      asset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.network(
                        fallback,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.restaurant, size: 30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹ $price',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text('🔥 320 kcal  ⚖️ 300 gm',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 10)),
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

  Widget _floatingCartBar(BuildContext context, FoodPlannerController ctrl) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.copper,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${ctrl.basketTotalItems} ${ctrl.basketTotalItems == 1 ? 'ITEM' : 'ITEMS'} ADDED',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
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
                    fontWeight: FontWeight.w700,
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
