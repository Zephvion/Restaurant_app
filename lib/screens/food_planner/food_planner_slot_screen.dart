import 'package:flutter/material.dart';

import '../../models/meal_plan.dart';
import '../../routes/app_routes.dart';
import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';

/// Screen allowing the user to select the delivery time slot and location for a meal.
class FoodPlannerSlotScreen extends StatefulWidget {
  const FoodPlannerSlotScreen({super.key});

  @override
  State<FoodPlannerSlotScreen> createState() => _FoodPlannerSlotScreenState();
}

class _FoodPlannerSlotScreenState extends State<FoodPlannerSlotScreen> {
  late String _selectedTime;
  late String _selectedLocation;
  bool _repeatPreviousWeek = false;

  final List<String> _breakfastSlots = [
    '6:30AM',
    '7:00AM',
    '7:30AM',
    '8:00AM',
    '8:30AM',
  ];

  final List<String> _lunchSlots = [
    '12:00PM',
    '12:30PM',
    '1:00PM',
    '1:30PM',
  ];

  final List<String> _dinnerSlots = [
    '7:30PM',
    '8:00PM',
    '8:30PM',
    '9:00PM',
  ];

  final List<String> _snacksSlots = [
    '10:30AM',
    '11:00AM',
    '4:00PM',
    '4:30PM',
    '5:00PM',
  ];

  final List<String> _locations = ['HOME', 'OFFICE'];

  @override
  void initState() {
    super.initState();
    final ctrl = FoodPlannerController.instance;
    _selectedTime = ctrl.currentSlotTime;
    _selectedLocation = ctrl.currentSlotLocation;
  }

  List<String> _getSlots(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return _breakfastSlots;
      case MealType.lunch:
        return _lunchSlots;
      case MealType.dinner:
        return _dinnerSlots;
      case MealType.snacks:
        return _snacksSlots;
    }
  }

  void _proceed() {
    final ctrl = FoodPlannerController.instance;
    ctrl.setupSlot(
      mealType: ctrl.currentSlotMealType,
      timeSlot: _selectedTime,
      location: _selectedLocation,
    );
    Navigator.of(context).pushNamed(AppRoutes.foodPlannerMenu);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = FoodPlannerController.instance;
    final mealType = ctrl.currentSlotMealType;
    final slots = _getSlots(mealType);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Jan 2 ,2023 - Tuesday',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Plan your ${mealType.name}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // ── Select Meal Time ──────────────────────────────────
                  const Text(
                    'Select preferred meal time',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: slots.map((time) {
                        final isSelected = _selectedTime == time;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTime = time),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accentRed
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              time,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // ── Select Meal Location ───────────────────────────────
                  const Text(
                    'Select meal setting / location',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: _locations.map((loc) {
                      final isSelected = _selectedLocation == loc;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedLocation = loc),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 14),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accentRed
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            loc,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 48),
                  // ── Repeat previous week toggle ────────────────────────
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
            // ── NEXT button ──────────────────────────────────────────────
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: GestureDetector(
                onTap: _proceed,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'NEXT',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
