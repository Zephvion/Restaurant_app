import 'package:flutter/material.dart';

import '../../data/food_planner_assets.dart';
import '../../data/mock_data.dart';
import '../../models/dish.dart';
import '../../models/meal_plan.dart';
import '../../routes/app_routes.dart';
import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';

/// Product detail screen matching Product screen.png and Product add to cart.png.
class FoodPlannerProductScreen extends StatefulWidget {
  const FoodPlannerProductScreen({super.key});

  @override
  State<FoodPlannerProductScreen> createState() =>
      _FoodPlannerProductScreenState();
}

class _FoodPlannerProductScreenState extends State<FoodPlannerProductScreen> {
  @override
  Widget build(BuildContext context) {
    final dish = (ModalRoute.of(context)?.settings.arguments as Dish?) ??
        MockData.plainDosa;

    return AnimatedBuilder(
      animation: FoodPlannerController.instance,
      builder: (context, _) {
        final ctrl = FoodPlannerController.instance;
        final qty = ctrl.getQuantity(dish.id);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  // ── Food Photo Header ────────────────────────────────────
                  _ImageHeader(dish: dish),
                  // ── Product Details ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dish.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (index) => const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '4.7',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              '₹ ${dish.price.toInt()}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '₹ 100',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          dish.description.isNotEmpty
                              ? dish.description
                              : "Serves in 2 nos' with Sambar , Coconut chutney and Onion chutney. Dosa is high in carbohydrates and contains no added sugars or saturated fats.",
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // ── Macro stats row ────────────────────────────────
                        const _MacroBadgesRow(),
                        const SizedBox(height: 32),
                        // ── Ingredients ────────────────────────────────────
                        const _IngredientsSection(),
                        const SizedBox(height: 32),
                        // ── Storage terms ──────────────────────────────────
                        const Text(
                          'Terms & Conditions of storage',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Enjoy it warm or store it in the refrigerator. Keep them wrapped up, let them cool fully, and then place them in an airtight container.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // ── Reviews ────────────────────────────────────────
                        const Text(
                          'Reviews',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(3, (index) => const _ReviewCard()),
                      ],
                    ),
                  ),
                ],
              ),
              // ── Bottom Action Bar ────────────────────────────────────────
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: qty == 0
                    ? GestureDetector(
                        onTap: () => ctrl.addToBasket(dish.id),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'ADD TO CART',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => ctrl.removeFromBasket(dish.id),
                                  child: const Icon(Icons.remove,
                                      color: Colors.white, size: 20),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    '$qty',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => ctrl.addToBasket(dish.id),
                                  child: const Icon(Icons.add,
                                      color: Colors.white, size: 20),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                ctrl.confirmPlannedMeal(dish: dish);
                                AppToast.showSuccess(
                                  context,
                                  'Added ${dish.name} to your ${ctrl.currentSlotMealType.displayName} plan! (+${dish.kcal > 0 ? dish.kcal : 320} kcal)',
                                  title: 'Added to Plan',
                                );
                                Navigator.of(context).popUntil((route) =>
                                    route.settings.name ==
                                        AppRoutes.foodPlanner ||
                                    route.isFirst);
                              },
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.accentRed,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'CONFIRM TO ${ctrl.currentSlotMealType.label}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Image Header ─────────────────────────────────────────────────────────────

class _ImageHeader extends StatelessWidget {
  const _ImageHeader({required this.dish});
  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            FoodPlannerAssets.productHeroDosa,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.network(
              dish.imageUrl.isNotEmpty
                  ? dish.imageUrl
                  : FoodPlannerAssets.dosa,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.search),
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

// ── Macro Badges Row ─────────────────────────────────────────────────────────

class _MacroBadgesRow extends StatelessWidget {
  const _MacroBadgesRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _MacroBadge(value: '4.7', label: 'Carbs'),
        _MacroBadge(value: '300', label: 'gms'),
        _MacroBadge(value: '1.3', label: 'Fat'),
        _MacroBadge(value: '2.3', label: 'Protein'),
      ],
    );
  }
}

class _MacroBadge extends StatelessWidget {
  const _MacroBadge({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ingredients Section ───────────────────────────────────────────────────────

class _IngredientsSection extends StatelessWidget {
  const _IngredientsSection();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Parboiled Rice (idli-dosa rice)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            SizedBox(height: 6),
            Text('• Whole Urad Dal',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Salt',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            SizedBox(height: 6),
            Text('• Coconut Oil',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ],
    );
  }
}

// ── Review Card ───────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  const _ReviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(
                FoodPlannerAssets.artiAvatar,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Asif Muhammad',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(
                    5,
                    (i) => const Icon(Icons.star, color: Colors.amber, size: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
