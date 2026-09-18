import 'package:flutter/material.dart';

import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';

/// Interactive Calorie Calculator screen matching Calculator.png through Calculator 8.png.
class FoodPlannerCalculatorScreen extends StatefulWidget {
  const FoodPlannerCalculatorScreen({super.key});

  @override
  State<FoodPlannerCalculatorScreen> createState() =>
      _FoodPlannerCalculatorScreenState();
}

class _FoodPlannerCalculatorScreenState
    extends State<FoodPlannerCalculatorScreen> {
  String _sex = 'Male';
  int _age = 26;
  int _heightFt = 5;
  int _heightIn = 9; // ~175 cm
  int _weightKg = 68;
  String _activity = 'Moderate active';
  String _goal = 'Maintain Weight';

  final List<String> _activities = [
    'Less active',
    'Moderate active',
    'Very active',
  ];

  final List<String> _goals = [
    'Lose weight',
    'Maintain Weight',
    'Gain weight',
  ];

  Map<String, num> _calculateMetrics() {
    final heightCm = (_heightFt * 12 + _heightIn) * 2.54;
    // Exact Mifflin-St Jeor equation:
    double bmr = (10.0 * _weightKg) + (6.25 * heightCm) - (5.0 * _age);
    if (_sex == 'Male') {
      bmr += 5.0;
    } else {
      bmr -= 161.0;
    }

    double pal = 1.2; // Sedentary
    if (_activity == 'Moderate active') pal = 1.55;
    if (_activity == 'Very active') pal = 1.725;

    double tdee = bmr * pal;
    double target = tdee;
    if (_goal == 'Lose weight') target -= 500; // safe 0.5kg/week fat loss deficit
    if (_goal == 'Gain weight') target += 400; // clean surplus

    final targetKcal = target.clamp(1200, 4500).round();
    final proteinG = ((targetKcal * 0.30) / 4).round();
    final carbsG = ((targetKcal * 0.45) / 4).round();
    final fatG = ((targetKcal * 0.25) / 9).round();

    return {
      'bmr': bmr.round(),
      'tdee': tdee.round(),
      'targetKcal': targetKcal,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
    };
  }

  void _showResult() {
    final metrics = _calculateMetrics();
    final target = metrics['targetKcal']!.toInt();
    final bmr = metrics['bmr']!.toInt();
    final tdee = metrics['tdee']!.toInt();
    final protein = metrics['proteinG']!.toInt();
    final carbs = metrics['carbsG']!.toInt();
    final fat = metrics['fatG']!.toInt();
    final planned = FoodPlannerController.instance.getPlannedCaloriesForDay();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CalorieResultDialog(
        targetKcal: target,
        bmrKcal: bmr,
        tdeeKcal: tdee,
        proteinG: protein,
        carbsG: carbs,
        fatG: fat,
        plannedKcal: planned,
        onSet: () {
          FoodPlannerController.instance.setCalorieTarget(target);
          Navigator.of(ctx).pop(); // pop dialog
          AppToast.showSuccess(
            context,
            'Daily target set to $target kcal with real macro targets!',
            title: 'Goal Saved',
          );
          Navigator.of(context).pop(); // pop calculator screen
        },
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Row(
          children: [
            Text('🧮', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text(
              'Calorie calculator',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            children: [
              // ── 1. Select Sex ──────────────────────────────────────────
              _sectionLabel('Select your sex'),
              const SizedBox(height: 12),
              Row(
                children: ['Male', 'Female'].map((s) {
                  final isSelected = _sex == s;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _sex = s),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        height: 52,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentRed
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              // ── 2. How old are you? ────────────────────────────────────
              _sectionLabel('How old are you?'),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(20, (i) {
                    final ageVal = 18 + i;
                    final isSelected = _age == ageVal;
                    return GestureDetector(
                      onTap: () => setState(() => _age = ageVal),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentRed
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$ageVal',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 28),
              // ── 3. How tall are you? ───────────────────────────────────
              _sectionLabel('How tall are you?'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _heightBox(
                    value: '$_heightFt',
                    unit: 'ft',
                    onTap: () => setState(
                        () => _heightFt = _heightFt >= 7 ? 4 : _heightFt + 1),
                  ),
                  const SizedBox(width: 20),
                  _heightBox(
                    value: '$_heightIn',
                    unit: 'in',
                    onTap: () => setState(
                        () => _heightIn = _heightIn >= 11 ? 0 : _heightIn + 1),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // ── 4. How much do you weigh in kg? ────────────────────────
              _sectionLabel('How much do you weigh in kg?'),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(40, (i) {
                    final wVal = 25 + i * 2;
                    final isSelected = _weightKg == wVal;
                    return GestureDetector(
                      onTap: () => setState(() => _weightKg = wVal),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentRed
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$wVal',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 28),
              // ── 5. How active are you? ─────────────────────────────────
              _sectionLabel('How active are you on daily basis?'),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _activities.map((a) {
                    final isSelected = _activity == a;
                    return GestureDetector(
                      onTap: () => setState(() => _activity = a),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentRed
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          a,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 28),
              // ── 6. Goal in maintaining weight? ─────────────────────────
              _sectionLabel('Goal in maintaining your weight?'),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _goals.map((g) {
                    final isSelected = _goal == g;
                    return GestureDetector(
                      onTap: () => setState(() => _goal = g),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentRed
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          g,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          // ── CALCULATE CALORIE Button ────────────────────────────────────
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: GestureDetector(
              onTap: _showResult,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'CALCULATE CALORIE',
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
    );
  }

  Widget _sectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
      ),
    );
  }

  Widget _heightBox({
    required String value,
    required String unit,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 54,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          unit,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ── Calorie Result Dialog ─────────────────────────────────────────────────────

class _CalorieResultDialog extends StatelessWidget {
  const _CalorieResultDialog({
    required this.targetKcal,
    required this.bmrKcal,
    required this.tdeeKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.plannedKcal,
    required this.onSet,
    required this.onClose,
  });

  final int targetKcal;
  final int bmrKcal;
  final int tdeeKcal;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final int plannedKcal;
  final VoidCallback onSet;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final diff = targetKcal - plannedKcal;

    return Dialog(
      backgroundColor: const Color(0xFF1E1B24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.copper, width: 1.2),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daily Nutrition Target',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Green circular gauge
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4ADE80),
                    width: 14,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4ADE80).withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$targetKcal',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'TARGET KCAL',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Scientific breakdown chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Base BMR: $bmrKcal kcal  •  Maintenance (TDEE): $tdeeKcal kcal',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Target Macros Breakdown
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recommended Macronutrient Split',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _macroPill('Protein (30%)', '${proteinG}g', const Color(0xFF4EA8DE)),
                  const SizedBox(width: 8),
                  _macroPill('Carbs (45%)', '${carbsG}g', const Color(0xFFF77F00)),
                  const SizedBox(width: 8),
                  _macroPill('Fat (25%)', '${fatG}g', const Color(0xFFE63946)),
                ],
              ),
              const SizedBox(height: 20),
              // Current planned comparison
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF26232D),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.copper.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.copper, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        diff >= 0
                            ? 'Currently planned today: $plannedKcal kcal ($diff kcal remaining to reach target).'
                            : 'Currently planned today: $plannedKcal kcal (${-diff} kcal over target budget).',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onSet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'SET AS DAILY GOAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _macroPill(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
