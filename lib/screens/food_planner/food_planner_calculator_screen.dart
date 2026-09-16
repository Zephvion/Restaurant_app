import 'package:flutter/material.dart';

import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';

/// Interactive Calorie Calculator screen matching Calculator.png through Calculator 8.png.
class FoodPlannerCalculatorScreen extends StatefulWidget {
  const FoodPlannerCalculatorScreen({super.key});

  @override
  State<FoodPlannerCalculatorScreen> createState() =>
      _FoodPlannerCalculatorScreenState();
}

class _FoodPlannerCalculatorScreenState
    extends State<FoodPlannerCalculatorScreen> {
  String _sex = 'Female';
  int _age = 22;
  int _heightFt = 6;
  int _heightIn = 0;
  int _weightKg = 30;
  String _activity = 'Less active';
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

  int _calculateTarget() {
    // Mifflin-St Jeor estimate
    int bmr = (10 * _weightKg) + (6 * ((_heightFt * 12 + _heightIn) * 2.54).toInt()) - (5 * _age);
    if (_sex == 'Male') {
      bmr += 5;
    } else {
      bmr -= 161;
    }

    double mult = 1.2;
    if (_activity == 'Moderate active') mult = 1.4;
    if (_activity == 'Very active') mult = 1.6;

    double target = bmr * mult;
    if (_goal == 'Lose weight') target -= 300;
    if (_goal == 'Gain weight') target += 300;

    return target.clamp(1200, 3500).toInt();
  }

  void _showResult() {
    final target = _calculateTarget();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CalorieResultDialog(
        targetKcal: target,
        onSet: () {
          FoodPlannerController.instance.setCalorieTarget(target);
          Navigator.of(ctx).pop(); // pop dialog
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
    required this.onSet,
    required this.onClose,
  });

  final int targetKcal;
  final VoidCallback onSet;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background.withValues(alpha: 0.95),
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onClose,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Your calorie intake',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Green circular gauge
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF4CAF50),
                        width: 18,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$targetKcal',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'kcal',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    'This is your required intake of\ncalories per day',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 48),
                  GestureDetector(
                    onTap: onSet,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(27),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'SET',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
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
