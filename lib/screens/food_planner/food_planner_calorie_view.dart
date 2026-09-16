import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../data/food_planner_assets.dart';
import '../../routes/app_routes.dart';
import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';

/// Tab 2: Calorie Counter view in Food Planner matching Calorie counter.png and today's calorie counter.png.
class FoodPlannerCalorieView extends StatefulWidget {
  const FoodPlannerCalorieView({super.key});

  @override
  State<FoodPlannerCalorieView> createState() => _FoodPlannerCalorieViewState();
}

class _FoodPlannerCalorieViewState extends State<FoodPlannerCalorieView> {
  String _selectedDateTab = 'Today';
  bool _isDrawerOpen = true;

  final List<String> _dateTabs = [
    'Dec 29',
    'Yesterday',
    'Today',
    'Jan 1',
    'Jan 2',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FoodPlannerController.instance,
      builder: (context, _) {
        final stats = FoodPlannerController.instance.calorieStats;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 20),
              onPressed: () {
                FoodPlannerController.instance.setActiveTab(0);
              },
            ),
            title: const Text(
              'Your Daily Stats',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.calculate_outlined,
                    color: AppColors.textPrimary, size: 24),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(AppRoutes.foodPlannerCalculator);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 200),
                children: [
                  // ── Date Tabs ─────────────────────────────────────────
                  _dateTabsRow(),
                  const SizedBox(height: 36),
                  // ── Circular Calorie Gauge ────────────────────────────
                  _CalorieRing(
                    remainingKcal: stats.remainingKcal,
                    targetKcal: stats.targetKcal,
                  ),
                  const SizedBox(height: 48),
                  // ── Macro Progress Bars ───────────────────────────────
                  _MacroProgressRow(
                    protein: stats.proteinG,
                    carbs: stats.carbsG,
                    fat: stats.fatG,
                  ),
                ],
              ),
              // ── Expandable Food Calorie Intake Drawer ──────────────────
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  constraints: BoxConstraints(
                    maxHeight: _isDrawerOpen
                        ? MediaQuery.of(context).size.height * 0.52
                        : 64,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      // Header / toggle handle
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isDrawerOpen = !_isDrawerOpen),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            children: [
                              Icon(
                                _isDrawerOpen
                                    ? Icons.keyboard_arrow_down
                                    : Icons.keyboard_arrow_up,
                                color: AppColors.textSecondary,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Todays food calorie intake',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_isDrawerOpen)
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            children: const [
                              _MealCalorieTile(
                                period: 'BREAKFAST',
                                name: 'Dosa',
                                calories: 320,
                                weight: 300,
                                imageUrl: FoodPlannerAssets.dosa,
                                protein: 50,
                                carbs: 50,
                                fat: 50,
                              ),
                              SizedBox(height: 16),
                              _MealCalorieTile(
                                period: 'NOON',
                                name: 'Meals',
                                calories: 320,
                                weight: 300,
                                imageUrl: FoodPlannerAssets.meals,
                                protein: 50,
                                carbs: 50,
                                fat: 50,
                              ),
                              SizedBox(height: 16),
                              _MealCalorieTile(
                                period: 'DINNER',
                                name: 'Chappathi Curry',
                                calories: 320,
                                weight: 300,
                                imageUrl: FoodPlannerAssets.chappathi,
                                protein: 50,
                                carbs: 50,
                                fat: 50,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dateTabsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _dateTabs.map((tab) {
          final isSelected = tab == _selectedDateTab;
          return GestureDetector(
            onTap: () => setState(() => _selectedDateTab = tab),
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
                tab,
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
}

// ── Circular Calorie Gauge ───────────────────────────────────────────────────

class _CalorieRing extends StatelessWidget {
  const _CalorieRing({
    required this.remainingKcal,
    required this.targetKcal,
  });

  final int remainingKcal;
  final int targetKcal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 210,
        height: 210,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(210, 210),
              painter: _RingPainter(
                progress: (targetKcal - remainingKcal) / targetKcal,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Remaining',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$remainingKcal',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'kcal',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;

    // Background track
    final trackPaint = Paint()
      ..color = const Color(0xFF282A2D)
      ..strokeWidth = 22
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress green arc
    final progPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 22
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.1, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progPaint,
    );

    // White dot at the tip of arc
    final tipAngle = -math.pi / 2 + sweepAngle;
    final tipX = center.dx + radius * math.cos(tipAngle);
    final tipY = center.dy + radius * math.sin(tipAngle);
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(tipX, tipY), 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Macro Progress Row ────────────────────────────────────────────────────────

class _MacroProgressRow extends StatelessWidget {
  const _MacroProgressRow({
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final int protein;
  final int carbs;
  final int fat;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _bar(value: '$protein', label: 'protien', color: Colors.amber),
        _bar(value: '$carbs', label: 'Carbs', color: Colors.amber),
        _bar(value: '$fat', label: 'Fat', color: AppColors.accentRed),
      ],
    );
  }

  Widget _bar({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 76,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(3),
          ),
          alignment: Alignment.centerLeft,
          child: Container(
            width: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ── Meal Calorie Tile ─────────────────────────────────────────────────────────

class _MealCalorieTile extends StatelessWidget {
  const _MealCalorieTile({
    required this.period,
    required this.name,
    required this.calories,
    required this.weight,
    required this.imageUrl,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final String period;
  final String name;
  final int calories;
  final int weight;
  final String imageUrl;
  final int protein;
  final int carbs;
  final int fat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          period,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.restaurant),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '🔥 $calories kcal   ⚖️ $weight gm',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _miniBar(value: '$protein', label: 'Protien', color: Colors.amber),
                      _miniBar(value: '$carbs', label: 'Carbs', color: Colors.amber),
                      _miniBar(value: '$fat', label: 'Fat', color: AppColors.accentRed),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniBar({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: Alignment.centerLeft,
          child: Container(
            width: 30,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 9),
        ),
      ],
    );
  }
}
