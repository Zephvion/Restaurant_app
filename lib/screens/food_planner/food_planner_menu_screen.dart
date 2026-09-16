import 'package:flutter/material.dart';

import '../../data/food_planner_assets.dart';
import '../../data/mock_data.dart';
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

  final List<String> _categories = [
    'Frequent order',
    'Veg',
    'Fish',
    'Egg',
    'Chicken',
    'Meals',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FoodPlannerController.instance,
      builder: (context, _) {
        final ctrl = FoodPlannerController.instance;
        final totalItems = ctrl.basketTotalItems;
        final mealType = ctrl.currentSlotMealType;

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
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  'Plan your ${mealType.name}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.textPrimary),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.search),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined,
                        color: AppColors.textPrimary),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.foodPlannerCart),
                  ),
                  if (totalItems > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.accentRed,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$totalItems',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  const SizedBox(height: 12),
                  // ── Category Tabs ───────────────────────────────────────
                  _categoryTabs(),
                  const SizedBox(height: 16),
                  // ── Menu / Sort By Row ──────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MENU',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'SORT BY',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.swap_vert,
                                size: 16, color: AppColors.textSecondary),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Featured Horizontal Rail ────────────────────────────
                  _featuredRail(ctrl),
                  const SizedBox(height: 28),
                  // ── Combination Breakfast Section ───────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Combination Breakfast',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _combinationList(ctrl),
                  const SizedBox(height: 28),
                  // ── Recommended Breakfast Section ───────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Recommended Breakfast',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _recommendedRail(ctrl),
                ],
              ),
              // ── Floating Bottom Basket Bar ──────────────────────────────
              if (totalItems > 0)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: _FloatingBasketBar(
                    totalItems: totalItems,
                    onNext: () {
                      Navigator.of(context)
                          .pushNamed(AppRoutes.foodPlannerCart);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _categoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              margin: const EdgeInsets.only(right: 18),
              padding: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppColors.accentRed : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _featuredRail(FoodPlannerController ctrl) {
    final featured = [
      {
        'dish': MockData.plainDosa,
        'asset': FoodPlannerAssets.featuredDosa,
      },
      {
        'dish': MockData.kuzhipaniyaram,
        'asset': FoodPlannerAssets.featuredKuzhi,
      },
    ];

    return SizedBox(
      height: 256,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: featured.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = featured[index];
          final dish = item['dish'] as dynamic;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: Image.asset(
                        asset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.network(
                          dish.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.restaurant, size: 40),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        const SizedBox(height: 2),
                        const Text(
                          '🔥 320 kcal  ⚖️ 300 gm',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 10),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹ ${dish.price.toInt()}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            _QuantityButton(
                              quantity: qty,
                              onAdd: () => ctrl.addToBasket(dish.id),
                              onIncrement: () => ctrl.addToBasket(dish.id),
                              onDecrement: () => ctrl.removeFromBasket(dish.id),
                            ),
                          ],
                        ),
                      ],
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

  Widget _combinationList(FoodPlannerController ctrl) {
    final combos = [
      const {
        'id': 'appam_stew',
        'title': 'Appam & Stew - 2 nos',
        'price': 180,
        'asset': FoodPlannerAssets.thumbAppam,
        'fallback': FoodPlannerAssets.appamStew,
      },
      const {
        'id': 'idiyappam_kadala',
        'title': 'Idiyappam & Kadala curry - 4 nos',
        'price': 180,
        'asset': FoodPlannerAssets.thumbIdiyappam,
        'fallback': FoodPlannerAssets.idiyappam,
      },
      const {
        'id': 'puttu_kadala',
        'title': 'Puttu & Kadala curry - 2 nos',
        'price': 180,
        'asset': FoodPlannerAssets.thumbPuttu,
        'fallback': FoodPlannerAssets.puttuKadala,
      },
      const {
        'id': 'poori_masala',
        'title': 'Poori Masala - 2 nos',
        'price': 180,
        'asset': FoodPlannerAssets.thumbPoori,
        'fallback': FoodPlannerAssets.pooriMasala,
      },
      const {
        'id': 'idli_sambar',
        'title': 'Idli & Sambar - 4 nos',
        'price': 180,
        'asset': FoodPlannerAssets.thumbIdli,
        'fallback': FoodPlannerAssets.idliSambar,
      },
    ];

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
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.restaurant, size: 30),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '🔥 320 kcal   ⚖️ 300 gm',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 6),
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

  Widget _recommendedRail(FoodPlannerController ctrl) {
    final recommended = [
      const {
        'id': 'plain_dosa_2',
        'title': 'Plain Dosa - 2 nos',
        'price': 180,
        'asset': FoodPlannerAssets.recDosa,
        'fallback': FoodPlannerAssets.dosa,
      },
      const {
        'id': 'puttu_kadala_2',
        'title': 'Puttu and Kadala',
        'price': 180,
        'asset': FoodPlannerAssets.recPuttu,
        'fallback': FoodPlannerAssets.puttuKadala,
      },
    ];

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
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: AppColors.textPrimary, size: 18),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: const Icon(Icons.remove,
                color: AppColors.textPrimary, size: 16),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: onIncrement,
            child:
                const Icon(Icons.add, color: AppColors.textPrimary, size: 16),
          ),
        ],
      ),
    );
  }
}

// ── Floating Basket Bar ───────────────────────────────────────────────────────

class _FloatingBasketBar extends StatelessWidget {
  const _FloatingBasketBar({
    required this.totalItems,
    required this.onNext,
  });

  final int totalItems;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart_outlined,
              color: AppColors.textPrimary, size: 20),
          const SizedBox(width: 10),
          Text(
            '$totalItems Item${totalItems > 1 ? 's' : ''} added to basket',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onNext,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'NEXT',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
