import 'package:flutter/material.dart';

import '../../data/food_planner_assets.dart';
import '../../models/meal_plan.dart';
import '../../routes/app_routes.dart';
import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/dashboard_tab_bar.dart';

/// Tab 0: "My week" view in Food Planner matching Landing screen.png, Date.png, and Edit.png.
class FoodPlannerWeekView extends StatefulWidget {
  const FoodPlannerWeekView({super.key});

  @override
  State<FoodPlannerWeekView> createState() => _FoodPlannerWeekViewState();
}

class _FoodPlannerWeekViewState extends State<FoodPlannerWeekView> {
  bool _repeatPreviousWeek = false;

  void _openSlot(BuildContext context, MealType mealType) {
    FoodPlannerController.instance.setupSlot(
      mealType: mealType,
      timeSlot: mealType == MealType.breakfast
          ? '7:30AM'
          : mealType == MealType.lunch
              ? '12:30PM'
              : '8:00PM',
      location: 'HOME',
    );
    Navigator.of(context).pushNamed(AppRoutes.foodPlannerSlot);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FoodPlannerController.instance,
      builder: (context, _) {
        final ctrl = FoodPlannerController.instance;
        final meals = ctrl.getMealsForSelectedDay();
        final hasMeals = meals.isNotEmpty;
        final hasSelectedDay = ctrl.selectedDayOffset >= 0;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            top: !hasSelectedDay,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ── Top Header / Banner ──────────────────────────────────
                if (!hasSelectedDay)
                  const _BannerHeader()
                else
                  _PlainHeader(
                    onBack: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.home);
                      }
                    },
                    onNotify: () => Navigator.of(context)
                        .pushNamed(AppRoutes.notifications),
                  ),

                // ── Swiggy-style Section Switcher ───────────────────────────
                const DashboardTabBar(
                  activeId: 'food_planner',
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
                ),

                // ── Header Text & Date Strip ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hello, Arti!',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ready to plan\nyour week?',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Month / Range Row ──────────────────────────────
                      Row(
                        children: [
                          if (!hasSelectedDay)
                            const Expanded(
                              child: Text(
                                'Select a date to start planning your meal',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          else
                            const Spacer(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                hasSelectedDay ? 'Jan 2 - 8' : 'Jan',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 11, color: AppColors.textSecondary),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Date Strip ─────────────────────────────────────
                      _DateStrip(
                        selectedOffset: ctrl.selectedDayOffset,
                        onSelect: (offset) => ctrl.selectDay(offset),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // ── Meals Rail or Empty Placeholders ────────────────
                if (hasMeals) ...[
                  _PopulatedMealsRail(
                    meals: meals,
                    onEdit: (m) => _openSlot(context, m.mealType),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start adding 1-3 meals for the day and set the delivery timing',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _EmptyMealPlaceholders(
                          onAdd: (mealType) => _openSlot(context, mealType),
                        ),
                        const SizedBox(height: 20),
                        // Repeat previous week toggle
                        GestureDetector(
                          onTap: () {
                            setState(() =>
                                _repeatPreviousWeek = !_repeatPreviousWeek);
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _repeatPreviousWeek
                                      ? AppColors.accentRed
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _repeatPreviousWeek
                                        ? AppColors.accentRed
                                        : AppColors.textSecondary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Repeat previous week's menu",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Plain Header (for Landing screen.png) ────────────────────────────────────

class _PlainHeader extends StatelessWidget {
  const _PlainHeader({required this.onBack, required this.onNotify});
  final VoidCallback onBack;
  final VoidCallback onNotify;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: onBack,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: Colors.white),
            onPressed: onNotify,
          ),
        ],
      ),
    );
  }
}

// ── Banner Header (for Date.png) ──────────────────────────────────────────────

class _BannerHeader extends StatelessWidget {
  const _BannerHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            FoodPlannerAssets.dateHeader,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(
              FoodPlannerAssets.date,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.home);
                      }
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AppRoutes.notifications),
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

// ── Date Strip ────────────────────────────────────────────────────────────────

class _DateStrip extends StatelessWidget {
  const _DateStrip({
    required this.selectedOffset,
    required this.onSelect,
  });

  final int selectedOffset;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const days = ['Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(7, (i) {
          final isSelected = selectedOffset == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              width: 52,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentRed : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${i + 2}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isSelected)
                    Text(
                      days[i],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Populated Meals Rail (Landing screen.png) ──────────────────────────────────

class _PopulatedMealsRail extends StatelessWidget {
  const _PopulatedMealsRail({
    required this.meals,
    required this.onEdit,
  });

  final List<PlannedMeal> meals;
  final ValueChanged<PlannedMeal> onEdit;

  String _getMealAsset(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return FoodPlannerAssets.cardDosa;
      case MealType.lunch:
        return FoodPlannerAssets.cardMeals;
      case MealType.dinner:
        return FoodPlannerAssets.cardChappathi;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: meals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final meal = meals[index];
          final assetPath = _getMealAsset(meal.mealType);

          return SizedBox(
            width: 170,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dish Image Card with edit pencil
                Container(
                  width: 170,
                  height: 215,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        meal.imageUrl.startsWith('assets/')
                            ? meal.imageUrl
                            : assetPath,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (_, __, ___) => Image.network(
                          meal.imageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.restaurant,
                                size: 40, color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      // Top gradient for pencil button contrast
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 55,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => onEdit(meal),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_outlined,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${meal.mealType.label.toUpperCase()} · ${meal.timeSlot}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meal.dishName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department_outlined,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          '${meal.calories} kcal',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.scale_outlined,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          '${meal.weightGm} gm',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Empty Meal Placeholders (Edit.png) ─────────────────────────────────────────

class _EmptyMealPlaceholders extends StatelessWidget {
  const _EmptyMealPlaceholders({required this.onAdd});
  final ValueChanged<MealType> onAdd;

  @override
  Widget build(BuildContext context) {
    const types = [MealType.breakfast, MealType.lunch, MealType.dinner];
    return SizedBox(
      height: 290,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final type = types[index];
          return SizedBox(
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Empty placeholder card matching Edit.png
                Container(
                  width: 160,
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(Icons.fastfood_outlined,
                            size: 38, color: AppColors.surfaceLight),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => onAdd(type),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  type.label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Item',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
