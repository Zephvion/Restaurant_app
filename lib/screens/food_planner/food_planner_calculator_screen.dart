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
  String? _sex = 'Male';
  late final TextEditingController _ageController;
  late final TextEditingController _heightFtController;
  late final TextEditingController _heightInController;
  late final TextEditingController _heightCmController;
  late final TextEditingController _weightController;
  bool _isHeightInCm = false;
  String? _activity = 'Moderate active';
  String? _goal = 'Maintain Weight';

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

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(text: '25');
    _heightFtController = TextEditingController(text: '5');
    _heightInController = TextEditingController(text: '8');
    _heightCmController = TextEditingController(text: '173');
    _weightController = TextEditingController(text: '70');

    _ageController.addListener(() => setState(() {}));
    _heightFtController.addListener(() {
      if (!_isHeightInCm) _syncCmFromFtIn();
      setState(() {});
    });
    _heightInController.addListener(() {
      if (!_isHeightInCm) _syncCmFromFtIn();
      setState(() {});
    });
    _heightCmController.addListener(() {
      if (_isHeightInCm) _syncFtInFromCm();
      setState(() {});
    });
    _weightController.addListener(() => setState(() {}));
  }

  void _syncCmFromFtIn() {
    final ft = int.tryParse(_heightFtController.text) ?? 5;
    final inch = int.tryParse(_heightInController.text) ?? 0;
    final totalIn = ft * 12 + inch;
    final cm = (totalIn * 2.54).round();
    _heightCmController.value = TextEditingValue(
      text: cm.toString(),
      selection: TextSelection.collapsed(offset: cm.toString().length),
    );
  }

  void _syncFtInFromCm() {
    final cm = double.tryParse(_heightCmController.text) ?? 170.0;
    final totalIn = cm / 2.54;
    final ft = (totalIn / 12).floor();
    final inch = (totalIn % 12).round();
    _heightFtController.value = TextEditingValue(
      text: ft.toString(),
      selection: TextSelection.collapsed(offset: ft.toString().length),
    );
    _heightInController.value = TextEditingValue(
      text: inch.toString(),
      selection: TextSelection.collapsed(offset: inch.toString().length),
    );
  }

  void _updateAge(int age) {
    _ageController.text = '$age';
    setState(() {});
  }

  void _updateWeight(double weight) {
    _weightController.text = weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1);
    setState(() {});
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();
    _heightCmController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  int? get _parsedAge => int.tryParse(_ageController.text);
  double? get _parsedWeight => double.tryParse(_weightController.text);
  double? get _parsedHeightCm {
    if (_isHeightInCm) {
      return double.tryParse(_heightCmController.text);
    } else {
      final ft = int.tryParse(_heightFtController.text);
      if (ft == null || ft <= 0) return null;
      final inch = int.tryParse(_heightInController.text) ?? 0;
      return (ft * 12 + inch) * 2.54;
    }
  }

  bool get _isComplete =>
      _sex != null &&
      _parsedAge != null &&
      _parsedAge! >= 10 &&
      _parsedAge! <= 120 &&
      _parsedHeightCm != null &&
      _parsedHeightCm! > 50 &&
      _parsedHeightCm! < 280 &&
      _parsedWeight != null &&
      _parsedWeight! > 20 &&
      _parsedWeight! < 350 &&
      _activity != null &&
      _goal != null;

  List<String> _getMissingFields() {
    final missing = <String>[];
    if (_sex == null) missing.add('Sex');
    if (_parsedAge == null || _parsedAge! < 10) missing.add('Age (min 10)');
    if (_parsedHeightCm == null || _parsedHeightCm! <= 50) missing.add('Valid Height');
    if (_parsedWeight == null || _parsedWeight! <= 20) missing.add('Valid Weight');
    if (_activity == null) missing.add('Activity Level');
    if (_goal == null) missing.add('Goal');
    return missing;
  }

  Map<String, num> _calculateMetrics() {
    if (!_isComplete) return {};
    final age = _parsedAge!;
    final weightKg = _parsedWeight!;
    final heightCm = _parsedHeightCm!;

    // Exact Mifflin-St Jeor equation:
    double bmr = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * age);
    if (_sex == 'Male') {
      bmr += 5.0;
    } else {
      bmr -= 161.0;
    }

    double pal = 1.2; // Less active (Sedentary)
    if (_activity == 'Moderate active') pal = 1.55;
    if (_activity == 'Very active') pal = 1.725;

    double tdee = bmr * pal;
    double target = tdee;
    if (_goal == 'Lose weight') target -= 500; // safe 0.5kg/week fat loss deficit
    if (_goal == 'Gain weight') target += 400; // clean surplus

    final minSafety = _sex == 'Female' ? 1200 : 1500;
    final targetKcal = target.clamp(minSafety, 4500).round();
    final proteinG = ((targetKcal * 0.30) / 4.0).round();
    final carbsG = ((targetKcal * 0.45) / 4.0).round();
    final fatG = ((targetKcal * 0.25) / 9.0).round();

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
    if (!_isComplete) {
      final missing = _getMissingFields().join(', ');
      AppBanner.showWarning(
        context,
        'Please enter all details ($missing) before calculating BMR.',
        title: 'Details Required',
      );
      return;
    }

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
              // ── 2. How old are you? ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionLabel('How old are you?'),
                  if (_parsedAge != null)
                    Text(
                      '$_parsedAge yrs',
                      style: const TextStyle(
                        color: AppColors.accentRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _typedNumberBox(
                    controller: _ageController,
                    hintText: '25',
                    suffix: 'yrs',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(width: 12),
                  _stepButton(
                    icon: Icons.remove,
                    onTap: () {
                      final current = _parsedAge ?? 25;
                      if (current > 10) _updateAge(current - 1);
                    },
                  ),
                  const SizedBox(width: 8),
                  _stepButton(
                    icon: Icons.add,
                    onTap: () {
                      final current = _parsedAge ?? 25;
                      if (current < 120) _updateAge(current + 1);
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [18, 21, 25, 30, 40, 50].map((preset) {
                          final isSel = _parsedAge == preset;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              label: Text('$preset'),
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: isSel ? AppColors.accentRed : AppColors.surface,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              onPressed: () => _updateAge(preset),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── 3. How tall are you? ───────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionLabel('How tall are you?'),
                  _unitToggle(
                    selected: _isHeightInCm ? 'cm' : 'ft / in',
                    options: const ['ft / in', 'cm'],
                    onSelect: (u) => setState(() => _isHeightInCm = u == 'cm'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (!_isHeightInCm)
                Row(
                  children: [
                    _typedNumberBox(
                      controller: _heightFtController,
                      hintText: '5',
                      suffix: 'ft',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(width: 8),
                    _stepButton(
                      icon: Icons.remove,
                      onTap: () {
                        final ft = (int.tryParse(_heightFtController.text) ?? 5) - 1;
                        if (ft >= 2) {
                          _heightFtController.text = '$ft';
                          _syncCmFromFtIn();
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(width: 6),
                    _stepButton(
                      icon: Icons.add,
                      onTap: () {
                        final ft = (int.tryParse(_heightFtController.text) ?? 5) + 1;
                        if (ft <= 8) {
                          _heightFtController.text = '$ft';
                          _syncCmFromFtIn();
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(width: 14),
                    _typedNumberBox(
                      controller: _heightInController,
                      hintText: '8',
                      suffix: 'in',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(width: 8),
                    _stepButton(
                      icon: Icons.remove,
                      onTap: () {
                        final inch = (int.tryParse(_heightInController.text) ?? 8) - 1;
                        if (inch >= 0) {
                          _heightInController.text = '$inch';
                          _syncCmFromFtIn();
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(width: 6),
                    _stepButton(
                      icon: Icons.add,
                      onTap: () {
                        final inch = (int.tryParse(_heightInController.text) ?? 8) + 1;
                        if (inch <= 11) {
                          _heightInController.text = '$inch';
                          _syncCmFromFtIn();
                          setState(() {});
                        }
                      },
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    _typedNumberBox(
                      controller: _heightCmController,
                      hintText: '172',
                      suffix: 'cm',
                      width: 110,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(width: 10),
                    _stepButton(
                      icon: Icons.remove,
                      onTap: () {
                        final cm = ((double.tryParse(_heightCmController.text) ?? 170) - 1).round();
                        if (cm >= 60) {
                          _heightCmController.text = '$cm';
                          _syncFtInFromCm();
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _stepButton(
                      icon: Icons.add,
                      onTap: () {
                        final cm = ((double.tryParse(_heightCmController.text) ?? 170) + 1).round();
                        if (cm <= 260) {
                          _heightCmController.text = '$cm';
                          _syncFtInFromCm();
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [155, 165, 170, 175, 180, 185].map((preset) {
                            final isSel = _parsedHeightCm?.round() == preset;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ActionChip(
                                label: Text('$preset cm'),
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                backgroundColor: isSel ? AppColors.accentRed : AppColors.surface,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                onPressed: () {
                                  _heightCmController.text = '$preset';
                                  _syncFtInFromCm();
                                  setState(() {});
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // ── 4. How much do you weigh in kg? ────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionLabel('How much do you weigh in kg?'),
                  if (_parsedWeight != null)
                    Text(
                      '${_parsedWeight!.toStringAsFixed(_parsedWeight! % 1 == 0 ? 0 : 1)} kg',
                      style: const TextStyle(
                        color: AppColors.accentRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _typedNumberBox(
                    controller: _weightController,
                    hintText: '65.0',
                    suffix: 'kg',
                    width: 110,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(width: 10),
                  _stepButton(
                    icon: Icons.remove,
                    onTap: () {
                      final cur = _parsedWeight ?? 65.0;
                      if (cur > 25) _updateWeight(cur - 1);
                    },
                  ),
                  const SizedBox(width: 8),
                  _stepButton(
                    icon: Icons.add,
                    onTap: () {
                      final cur = _parsedWeight ?? 65.0;
                      if (cur < 300) _updateWeight(cur + 1);
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [50, 60, 65, 70, 75, 80, 85, 90].map((w) {
                          final isSel = _parsedWeight?.round() == w;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              label: Text('$w kg'),
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: isSel ? AppColors.accentRed : AppColors.surface,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              onPressed: () => _updateWeight(w.toDouble()),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
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
                  color: _isComplete ? AppColors.accentRed : AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: _isComplete
                      ? [
                          BoxShadow(
                            color: AppColors.accentRed.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  _isComplete
                      ? 'CALCULATE CALORIE'
                      : 'ENTER ALL DETAILS TO CALCULATE',
                  style: TextStyle(
                    color: _isComplete ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 1.2,
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

  Widget _stepButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.textPrimary, size: 18),
      ),
    );
  }

  Widget _unitToggle({
    required String selected,
    required List<String> options,
    required ValueChanged<String> onSelect,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final isSel = selected == opt;
          return GestureDetector(
            onTap: () => onSelect(opt),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSel ? AppColors.accentRed : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                opt,
                style: TextStyle(
                  color: isSel ? Colors.white : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _typedNumberBox({
    required TextEditingController controller,
    required String hintText,
    required String suffix,
    required ValueChanged<String> onChanged,
    double width = 80,
  }) {
    return Container(
      width: width,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ),
          Text(
            suffix,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
