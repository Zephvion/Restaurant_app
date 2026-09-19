import 'package:flutter/material.dart';

import '../../data/food_planner_assets.dart';
import '../../models/meal_plan.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/dashboard_tab_bar.dart';

/// Tab 0: "My week" category-driven meal planner dashboard.
class FoodPlannerWeekView extends StatefulWidget {
  const FoodPlannerWeekView({super.key});

  @override
  State<FoodPlannerWeekView> createState() => _FoodPlannerWeekViewState();
}

class _FoodPlannerWeekViewState extends State<FoodPlannerWeekView> {
  bool _dismissedReminder = false;

  @override
  void initState() {
    super.initState();
    // Proactively generate timely meal planner reminders when visiting Food Planner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.generateContextualPlannerReminders(
        FoodPlannerController.instance,
      );
    });
  }

  void _openSlot(BuildContext context, MealType mealType) {
    FoodPlannerController.instance.setupSlot(
      mealType: mealType,
      timeSlot: mealType == MealType.breakfast
          ? '7:30AM'
          : mealType == MealType.lunch
              ? '12:30PM'
              : mealType == MealType.dinner
                  ? '8:00PM'
                  : '4:30PM',
      location: 'HOME',
    );
    Navigator.of(context).pushNamed(AppRoutes.foodPlannerMenu);
  }

  void _showEditServingsSheet(BuildContext context, PlannedMeal meal) {
    final ctrl = FoodPlannerController.instance;
    int servings = meal.servings > 0 ? meal.servings : 1;
    final unitKcal = (meal.calories / servings).round();
    final unitWeight = (meal.weightGm / servings).round();
    final unitProtein = (meal.protein / servings).round();
    final unitCarbs = (meal.carbs / servings).round();
    final unitFat = (meal.fat / servings).round();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1B24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          meal.imageUrl.startsWith('assets/')
                              ? meal.imageUrl
                              : FoodPlannerAssets.cardDosa,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 54,
                            height: 54,
                            color: AppColors.surface,
                            child: const Icon(Icons.restaurant,
                                color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal.dishName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${meal.mealType.displayName} · ${meal.timeSlot}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Portion & Servings',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Servings Quantity',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: AppColors.accentRed),
                              onPressed: servings > 1
                                  ? () => setSheetState(() => servings--)
                                  : null,
                            ),
                            Text(
                              '$servings',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Color(0xFF4ADE80)),
                              onPressed: () => setSheetState(() => servings++),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Live Calculated Nutrition
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF26232D),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _nutriMetric('Calories', '${unitKcal * servings} kcal', AppColors.accentRed),
                        _nutriMetric('Weight', '${unitWeight * servings} g', Colors.white70),
                        _nutriMetric('Protein', '${unitProtein * servings} g', const Color(0xFF4EA8DE)),
                        _nutriMetric('Carbs', '${unitCarbs * servings} g', const Color(0xFFF77F00)),
                        _nutriMetric('Fat', '${unitFat * servings} g', const Color(0xFFE63946)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ctrl.removeMeal(meal.id);
                            Navigator.of(ctx).pop();
                            AppToast.showSuccess(
                              context,
                              'Removed ${meal.dishName} from plan',
                              title: 'Meal Removed',
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accentRed,
                            side: const BorderSide(color: AppColors.accentRed),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('DELETE DISH'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ctrl.updateMealServings(meal.id, servings);
                            Navigator.of(ctx).pop();
                            AppToast.showSuccess(
                              context,
                              'Updated ${meal.dishName} to $servings serving(s)',
                              title: 'Portion Updated',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'SAVE PORTION',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _nutriMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildContextualReminderCard(
      BuildContext context, FoodPlannerController ctrl) {
    final todayLunch = ctrl.getMealsForSlot(0, MealType.lunch);
    final todayDinner = ctrl.getMealsForSlot(0, MealType.dinner);
    final todayCalories = ctrl.getDayCalories(0);
    final budget = ctrl.dailyCalorieBudget;

    if (todayLunch.isEmpty) {
      return _SmartPlannerReminderCard(
        category: 'MEAL REMINDER',
        iconData: Icons.lunch_dining_rounded,
        message: "Today's Lunch is unlogged. Add items to hit your calorie target!",
        actionLabel: 'Plan Lunch',
        onAction: () => _openSlot(context, MealType.lunch),
        onDismiss: () => setState(() => _dismissedReminder = true),
      );
    } else if (todayDinner.isEmpty) {
      return _SmartPlannerReminderCard(
        category: 'PLAN AHEAD',
        iconData: Icons.dinner_dining_rounded,
        message: "Tonight's Dinner is empty. Schedule dishes early for balanced macros.",
        actionLabel: 'Plan Dinner',
        onAction: () => _openSlot(context, MealType.dinner),
        onDismiss: () => setState(() => _dismissedReminder = true),
      );
    } else if (todayCalories > 0 && todayCalories < budget) {
      return _SmartPlannerReminderCard(
        category: 'CALORIE GOAL',
        iconData: Icons.local_fire_department_rounded,
        message:
            "${budget - todayCalories} kcal remaining for today. Add healthy snacks or a fruit bowl!",
        actionLabel: 'Add Snack',
        onAction: () => _openSlot(context, MealType.snacks),
        onDismiss: () => setState(() => _dismissedReminder = true),
      );
    } else {
      return _SmartPlannerReminderCard(
        category: 'NUTRITION TIP',
        iconData: Icons.water_drop_rounded,
        message:
            "All core meals scheduled! Remember to drink 2.5L water & stay hydrated today.",
        actionLabel: 'View Tips',
        onAction: () =>
            Navigator.of(context).pushNamed(AppRoutes.notifications),
        onDismiss: () => setState(() => _dismissedReminder = true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FoodPlannerController.instance,
      builder: (context, _) {
        final ctrl = FoodPlannerController.instance;
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
                      Builder(
                        builder: (context) {
                          final user = AuthService.instance.currentUser;
                          final userName = (user != null &&
                                  user.displayName.trim().isNotEmpty)
                              ? user.displayName.trim()
                              : (user != null && user.email.contains('@'))
                                  ? user.email.split('@').first
                                  : 'Valued Guest';

                          return Text(
                            'Hello, $userName!',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Weekly Nutrition &\nMeal Planner',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Month / Range Row ──────────────────────────────
                      Builder(
                        builder: (context) {
                          final now = DateTime.now();
                          const months = [
                            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                          ];
                          final startMonth = months[now.month - 1];
                          final endDay = now.add(const Duration(days: 6));
                          final endMonth = months[endDay.month - 1];
                          final rangeStr = startMonth == endMonth
                              ? '$startMonth ${now.day} - ${endDay.day}'
                              : '$startMonth ${now.day} - $endMonth ${endDay.day}';

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                rangeStr,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.of(context)
                                        .pushNamed(AppRoutes.foodPlannerCalculator),
                                    child: const Row(
                                      children: [
                                        Text(
                                          'BMR Calculator',
                                          style: TextStyle(
                                            color: AppColors.copper,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.arrow_forward_ios,
                                            size: 10, color: AppColors.copper),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // ── Date Strip ─────────────────────────────────────
                      _DateStrip(
                        selectedOffset: ctrl.selectedDayOffset,
                        onSelect: (offset) => ctrl.selectDay(offset),
                      ),
                      const SizedBox(height: 18),

                      // ── Daily Calorie & Macro Dashboard Card ────────────
                      _DailyCalorieSummaryBar(
                        plannedKcal: ctrl.getPlannedCaloriesForDay(),
                        targetKcal: ctrl.targetKcal,
                        onViewDetails: () => ctrl.setActiveTab(1),
                        onOpenCalculator: () => Navigator.of(context)
                            .pushNamed(AppRoutes.foodPlannerCalculator),
                      ),
                      const SizedBox(height: 18),

                      // ── Smart Contextual Planner Reminder ────────────────
                      if (!_dismissedReminder) ...[
                        _buildContextualReminderCard(context, ctrl),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // ── Category Meal Cards (Breakfast, Lunch, Dinner, Snacks) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scheduled Meals by Category',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Plan multiple items per meal, adjust servings, or add new dishes',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),

                      for (final mealType in [
                        MealType.breakfast,
                        MealType.lunch,
                        MealType.dinner,
                        MealType.snacks,
                      ]) ...[
                        _CategoryMealSection(
                          mealType: mealType,
                          meals: ctrl.getMealsForSlot(
                              ctrl.selectedDayOffset, mealType),
                          onAdd: (type) => _openSlot(context, type),
                          onEdit: (meal) => _showEditServingsSheet(context, meal),
                          onDelete: (meal) {
                            ctrl.removeMeal(meal.id);
                            AppToast.showSuccess(
                              context,
                              'Removed ${meal.dishName} from ${meal.mealType.displayName}',
                              title: 'Dish Removed',
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Category Meal Section ─────────────────────────────────────────────────────

class _CategoryMealSection extends StatelessWidget {
  const _CategoryMealSection({
    required this.mealType,
    required this.meals,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final MealType mealType;
  final List<PlannedMeal> meals;
  final ValueChanged<MealType> onAdd;
  final ValueChanged<PlannedMeal> onEdit;
  final ValueChanged<PlannedMeal> onDelete;

  IconData get _icon {
    switch (mealType) {
      case MealType.breakfast:
        return Icons.wb_sunny_outlined;
      case MealType.lunch:
        return Icons.restaurant_menu;
      case MealType.dinner:
        return Icons.nights_stay_outlined;
      case MealType.snacks:
        return Icons.local_cafe_outlined;
    }
  }

  Color get _accentColor {
    switch (mealType) {
      case MealType.breakfast:
        return const Color(0xFFF77F00);
      case MealType.lunch:
        return const Color(0xFF4ADE80);
      case MealType.dinner:
        return const Color(0xFF4EA8DE);
      case MealType.snacks:
        return AppColors.copper;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotalKcal = meals.fold<int>(0, (sum, m) => sum + m.calories);
    final subtotalP = meals.fold<int>(0, (sum, m) => sum + m.protein);
    final subtotalC = meals.fold<int>(0, (sum, m) => sum + m.carbs);
    final subtotalF = meals.fold<int>(0, (sum, m) => sum + m.fat);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category Header ───────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealType.displayName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (meals.isNotEmpty)
                      Text(
                        'P: ${subtotalP}g  ·  C: ${subtotalC}g  ·  F: ${subtotalF}g',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              if (subtotalKcal > 0) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$subtotalKcal kcal',
                    style: TextStyle(
                      color: _accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                icon: const Icon(Icons.add_circle,
                    color: AppColors.accentRed, size: 28),
                onPressed: () => onAdd(mealType),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Food Cards List ───────────────────────────────────────
          if (meals.isNotEmpty) ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meals.length,
              separatorBuilder: (_, __) => const Divider(
                color: AppColors.border,
                height: 18,
                thickness: 0.8,
              ),
              itemBuilder: (context, idx) {
                final meal = meals[idx];
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        meal.imageUrl.startsWith('assets/')
                            ? meal.imageUrl
                            : FoodPlannerAssets.cardDosa,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 52,
                          height: 52,
                          color: const Color(0xFF26232D),
                          child: const Icon(Icons.restaurant,
                              color: AppColors.textSecondary, size: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.dishName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${meal.servings} serving(s) · ${meal.weightGm}g · ₹${meal.price.toInt()}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            children: [
                              _macroChip('${meal.calories} kcal',
                                  AppColors.accentRed),
                              _macroChip('P: ${meal.protein}g',
                                  const Color(0xFF4EA8DE)),
                              _macroChip(
                                  'C: ${meal.carbs}g', const Color(0xFFF77F00)),
                              _macroChip(
                                  'F: ${meal.fat}g', const Color(0xFFE63946)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: AppColors.copper, size: 19),
                          onPressed: () => onEdit(meal),
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.accentRed, size: 19),
                          onPressed: () => onDelete(meal),
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () => onAdd(mealType),
                icon: const Icon(Icons.add, size: 18, color: AppColors.copper),
                label: Text(
                  'Add another item to ${mealType.displayName}',
                  style: const TextStyle(
                    color: AppColors.copper,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: () => onAdd(mealType),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF19161F),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.border, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Icon(_icon, color: AppColors.textSecondary, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      'No dishes added to ${mealType.displayName}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '+ Add ${mealType.displayName}',
                        style: const TextStyle(
                          color: AppColors.accentRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _macroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Daily Calorie & Macro Summary Bar ─────────────────────────────────────────

class _DailyCalorieSummaryBar extends StatelessWidget {
  const _DailyCalorieSummaryBar({
    required this.plannedKcal,
    required this.targetKcal,
    required this.onViewDetails,
    required this.onOpenCalculator,
  });

  final int plannedKcal;
  final int targetKcal;
  final VoidCallback onViewDetails;
  final VoidCallback onOpenCalculator;

  @override
  Widget build(BuildContext context) {
    final remainingKcal = (targetKcal - plannedKcal).clamp(0, targetKcal);
    final progress =
        targetKcal > 0 ? (plannedKcal / targetKcal).clamp(0.0, 1.0) : 0.0;
    final stats = FoodPlannerController.instance.calorieStats;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: AppColors.accentRed, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$plannedKcal / $targetKcal kcal',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            remainingKcal > 0
                                ? '$remainingKcal kcal budget remaining'
                                : 'Daily caloric goal achieved!',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onViewDetails,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.copper.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Macro Stats',
                        style: TextStyle(
                          color: AppColors.copper,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios,
                          color: AppColors.copper, size: 9),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceLight,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accentRed),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 14),
          // Macronutrient intake summary
          Row(
            children: [
              _macroProgress(
                'Protein',
                '${stats.proteinG}g',
                (stats.proteinG / ((targetKcal * 0.30) / 4)).clamp(0.0, 1.0),
                const Color(0xFF4EA8DE),
              ),
              const SizedBox(width: 8),
              _macroProgress(
                'Carbs',
                '${stats.carbsG}g',
                (stats.carbsG / ((targetKcal * 0.45) / 4)).clamp(0.0, 1.0),
                const Color(0xFFF77F00),
              ),
              const SizedBox(width: 8),
              _macroProgress(
                'Fat',
                '${stats.fatG}g',
                (stats.fatG / ((targetKcal * 0.25) / 9)).clamp(0.0, 1.0),
                const Color(0xFFE63946),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroProgress(
      String label, String value, double progress, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF26232D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
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
          _NotificationBellButton(onTap: onNotify),
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
                  _NotificationBellButton(
                    onTap: () => Navigator.of(context)
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
    final now = DateTime.now();
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(7, (i) {
          final isSelected = selectedOffset == i;
          final date = now.add(Duration(days: i));
          final dayName = dayNames[date.weekday - 1];

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
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    dayName,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white70 : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
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

// ── Notification Bell with Live Unread Badge ─────────────────────────────────

class _NotificationBellButton extends StatelessWidget {
  const _NotificationBellButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NotificationService.instance,
      builder: (context, _) {
        final count = NotificationService.instance.unreadCount;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
              ),
              onPressed: onTap,
            ),
            if (count > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.copper,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Smart Contextual Planner Reminder Card ───────────────────────────────────

class _SmartPlannerReminderCard extends StatelessWidget {
  const _SmartPlannerReminderCard({
    required this.category,
    required this.iconData,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.onDismiss,
  });

  final String category;
  final IconData iconData;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.copper.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.copper.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: AppColors.copper,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.copper,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.copper,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
