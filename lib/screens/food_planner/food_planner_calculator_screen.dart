import 'package:flutter/material.dart';

import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';

/// Interactive BMI & Calorie Calculator screen.
///
/// Features:
/// - Real-time BMI calculation & interactive multi-zone health spectrum gauge.
/// - Shows underweight, healthy (18.5 - 24.9), overweight, and obese ranges.
/// - Calculates BMR (Mifflin-St Jeor), TDEE, and daily target calorie intake based on goals.
/// - Calculates recommended healthy weight range for user's specific height.
/// - Supports both first-time onboarding flow and standalone calculator tab.
class FoodPlannerCalculatorScreen extends StatefulWidget {
  const FoodPlannerCalculatorScreen({
    super.key,
    this.isFirstTimeOnboarding = false,
    this.isEmbedded = false,
    this.onSetupComplete,
  });

  final bool isFirstTimeOnboarding;
  final bool isEmbedded;
  final VoidCallback? onSetupComplete;

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
  late final TextEditingController _customCalorieController;
  late final ScrollController _scrollController;
  bool _isHeightInCm = true;
  bool _hasCalculated = false;
  String? _activity = 'Moderate active';
  String? _goal = 'Maintain Weight';

  final List<Map<String, String>> _activities = [
    {
      'name': 'Less active',
      'desc': 'Sedentary desk job, little or no exercise (1.2x)',
    },
    {
      'name': 'Moderate active',
      'desc': 'Light exercise/sports 3-5 days/week (1.55x)',
    },
    {
      'name': 'Very active',
      'desc': 'Hard exercise/sports 6-7 days/week (1.725x)',
    },
  ];

  final List<Map<String, String>> _goals = [
    {
      'name': 'Lose weight',
      'desc': 'Safe 500 kcal deficit (~0.5 kg fat loss/week)',
    },
    {
      'name': 'Maintain Weight',
      'desc': 'Balanced calories for sustaining current weight',
    },
    {
      'name': 'Gain weight',
      'desc': 'Clean 400 kcal surplus for lean muscle building',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _ageController = TextEditingController();
    _heightFtController = TextEditingController();
    _heightInController = TextEditingController();
    _heightCmController = TextEditingController();
    _weightController = TextEditingController();
    _customCalorieController = TextEditingController();

    // If user previously completed assessment, pre-populate for convenient inspection
    final saved = FoodPlannerController.instance.userBmiStats;
    if (saved != null) {
      if (saved['age'] != null) _ageController.text = '${saved['age']}';
      if (saved['heightCm'] != null) {
        _heightCmController.text = '${saved['heightCm']}';
        _syncFtInFromCm();
      }
      if (saved['weightKg'] != null) {
        _weightController.text = '${saved['weightKg']}';
      }
      if (saved['sex'] is String) _sex = saved['sex'] as String;
      if (saved['activity'] is String) _activity = saved['activity'] as String;
      if (saved['goal'] is String) _goal = saved['goal'] as String;
      if (saved['customKcal'] != null) {
        _customCalorieController.text = '${saved['customKcal']}';
      }
      _hasCalculated = true;
    }

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
    _customCalorieController.addListener(() => setState(() {}));
  }

  void _syncCmFromFtIn() {
    final ft = int.tryParse(_heightFtController.text);
    if (ft == null) return;
    final inch = int.tryParse(_heightInController.text) ?? 0;
    final totalIn = ft * 12 + inch;
    final cm = (totalIn * 2.54).round();
    _heightCmController.value = TextEditingValue(
      text: cm.toString(),
      selection: TextSelection.collapsed(offset: cm.toString().length),
    );
  }

  void _syncFtInFromCm() {
    final cm = double.tryParse(_heightCmController.text);
    if (cm == null) return;
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

  @override
  void dispose() {
    _scrollController.dispose();
    _ageController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();
    _heightCmController.dispose();
    _weightController.dispose();
    _customCalorieController.dispose();
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

  Map<String, dynamic> _calculateMetrics() {
    if (!_isComplete) return {};
    final age = _parsedAge!;
    final weightKg = _parsedWeight!;
    final heightCm = _parsedHeightCm!;
    final heightM = heightCm / 100.0;

    // Exact BMI
    final bmi = weightKg / (heightM * heightM);

    // Healthy weight range for this height (BMI 18.5 to 24.9)
    final minHealthyWeight = 18.5 * (heightM * heightM);
    final maxHealthyWeight = 24.9 * (heightM * heightM);

    // Exact Mifflin-St Jeor equation:
    double bmr = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * age);
    if (_sex == 'Male') {
      bmr += 5.0;
    } else {
      bmr -= 161.0;
    }

    double pal = 1.2;
    if (_activity == 'Moderate active') pal = 1.55;
    if (_activity == 'Very active') pal = 1.725;

    double tdee = bmr * pal;
    double target = tdee;
    if (_goal == 'Lose weight') target -= 500;
    if (_goal == 'Gain weight') target += 400;

    final minSafety = _sex == 'Female' ? 1200 : 1500;
    int targetKcal = target.clamp(minSafety, 4500).round();

    // If user wrote a custom calorie target, respect their written target!
    final customKcal = int.tryParse(_customCalorieController.text.trim());
    if (customKcal != null && customKcal >= 800 && customKcal <= 6000) {
      targetKcal = customKcal;
    }

    final proteinG = ((targetKcal * 0.30) / 4.0).round();
    final carbsG = ((targetKcal * 0.45) / 4.0).round();
    final fatG = ((targetKcal * 0.25) / 9.0).round();

    String bmiCategory;
    Color bmiColor;
    if (bmi < 18.5) {
      bmiCategory = 'Underweight';
      bmiColor = const Color(0xFF38BDF8);
    } else if (bmi <= 24.9) {
      bmiCategory = 'Healthy Weight';
      bmiColor = const Color(0xFF22C55E);
    } else if (bmi <= 29.9) {
      bmiCategory = 'Overweight';
      bmiColor = const Color(0xFFF59E0B);
    } else {
      bmiCategory = 'Obese';
      bmiColor = const Color(0xFFEF4444);
    }

    return {
      'bmi': double.parse(bmi.toStringAsFixed(1)),
      'bmiCategory': bmiCategory,
      'minHealthyWeight': double.parse(minHealthyWeight.toStringAsFixed(1)),
      'maxHealthyWeight': double.parse(maxHealthyWeight.toStringAsFixed(1)),
      'bmr': bmr.round(),
      'tdee': tdee.round(),
      'targetKcal': targetKcal,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
      'age': age,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'sex': _sex,
      'activity': _activity,
      'goal': _goal,
      'customKcal': customKcal,
    };
  }

  void _onCalculateTapped() {
    if (!_isComplete) {
      final missing = <String>[];
      if (_parsedAge == null) missing.add('Age');
      if (_parsedHeightCm == null) missing.add('Height');
      if (_parsedWeight == null) missing.add('Weight');
      AppBanner.showWarning(
        context,
        'Please enter your ${missing.join(', ')} to calculate your BMI and daily caloric budget.',
        title: 'Information Required',
      );
      return;
    }

    setState(() {
      _hasCalculated = true;
    });

    final metrics = _calculateMetrics();
    AppToast.showSuccess(
      context,
      'Calculated: BMI ${metrics['bmi']} kg/m² (${metrics['bmiCategory']}) • Daily Target ${metrics['targetKcal']} kcal',
      title: 'BMI Calculated',
    );

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _saveAndProceed() async {
    if (!_isComplete) {
      _onCalculateTapped();
      return;
    }

    final metrics = _calculateMetrics();
    final target = metrics['targetKcal'] as int;
    final bmi = metrics['bmi'];
    final category = metrics['bmiCategory'];

    // 1. Persist user BMI stats & daily goal in controller + session manager
    await FoodPlannerController.instance.saveUserBmiStats(metrics);

    if (!mounted) return;

    // 2. Show clear confirmation toast
    AppToast.showSuccess(
      context,
      'Daily Calorie Target updated to $target kcal (BMI: $bmi • $category)!',
      title: 'Nutrition Goal Activated',
    );

    // 3. Immediately switch to Week View (tab 0) so user sees updated meal planner
    FoodPlannerController.instance.setActiveTab(0);

    // 4. Pop if pushed via Navigator
    if (widget.onSetupComplete != null) {
      widget.onSetupComplete!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _calculateMetrics();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: widget.isFirstTimeOnboarding
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: AppColors.textPrimary, size: 20),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    FoodPlannerController.instance.setActiveTab(0);
                  }
                },
              ),
        title: Row(
          children: [
            const Text('🧮', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.isFirstTimeOnboarding
                    ? 'Personalize Your Plan'
                    : 'BMI & Calorie Calculator',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (widget.isFirstTimeOnboarding)
            TextButton(
              onPressed: () {
                FoodPlannerController.instance.markBmiSetupCompleted();
                widget.onSetupComplete?.call();
              },
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            children: [
              if (widget.isFirstTimeOnboarding) ...[
                // Friendly onboarding welcome banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFA855F7).withValues(alpha: 0.20),
                        const Color(0xFF6366F1).withValues(alpha: 0.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFA855F7).withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.health_and_safety_rounded,
                          color: Color(0xFFA855F7), size: 30),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Step 1: Your Health Profile',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Calculate your BMI and daily calorie budget to unlock smart meal suggestions tailored to your goals.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // ── Interactive Real-Time BMI Health Gauge Card ──────────────
              _buildBmiSpectrumCard(metrics),
              const SizedBox(height: 20),

              // ── 1. Select Sex ────────────────────────────────────────────
              _sectionLabel('1. Biological Sex'),
              const SizedBox(height: 10),
              Row(
                children: ['Male', 'Female'].map((s) {
                  final isSelected = _sex == s;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _sex = s),
                      child: Container(
                        margin: EdgeInsets.only(right: s == 'Male' ? 10 : 0),
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFA855F7)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFA855F7)
                                : AppColors.border.withValues(alpha: 0.4),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              s == 'Male' ? Icons.male : Icons.female,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              s,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── 2. Age ───────────────────────────────────────────────────
              _sectionLabel('2. Age'),
              const SizedBox(height: 10),
              _typedInputCard(
                controller: _ageController,
                label: 'Age in Years',
                hintText: 'Enter your age (e.g. 25)',
                suffix: 'yrs',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // ── 3. Height ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionLabel('3. Height'),
                  _unitToggle(
                    selected: _isHeightInCm ? 'cm' : 'ft/in',
                    options: ['cm', 'ft/in'],
                    onSelect: (u) => setState(() => _isHeightInCm = u == 'cm'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_isHeightInCm)
                _typedInputCard(
                  controller: _heightCmController,
                  label: 'Height in Centimeters',
                  hintText: 'Enter height in cm (e.g. 175)',
                  suffix: 'cm',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) {
                    _syncFtInFromCm();
                    setState(() {});
                  },
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _typedInputCard(
                        controller: _heightFtController,
                        label: 'Feet',
                        hintText: 'e.g. 5',
                        suffix: 'ft',
                        keyboardType: TextInputType.number,
                        onChanged: (_) {
                          _syncCmFromFtIn();
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _typedInputCard(
                        controller: _heightInController,
                        label: 'Inches',
                        hintText: 'e.g. 9',
                        suffix: 'in',
                        keyboardType: TextInputType.number,
                        onChanged: (_) {
                          _syncCmFromFtIn();
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // ── 4. Weight ────────────────────────────────────────────────
              _sectionLabel('4. Weight'),
              const SizedBox(height: 10),
              _typedInputCard(
                controller: _weightController,
                label: 'Weight in Kilograms',
                hintText: 'Enter weight in kg (e.g. 70)',
                suffix: 'kg',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                helperText: metrics.containsKey('minHealthyWeight')
                    ? 'Healthy for your height: ${metrics['minHealthyWeight']} - ${metrics['maxHealthyWeight']} kg'
                    : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // ── 5. Activity Level ────────────────────────────────────────
              _sectionLabel('5. Activity Level'),
              const SizedBox(height: 10),
              Column(
                children: _activities.map((a) {
                  final isSelected = _activity == a['name'];
                  return GestureDetector(
                    onTap: () => setState(() => _activity = a['name']),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFA855F7).withValues(alpha: 0.16)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFA855F7)
                              : AppColors.border.withValues(alpha: 0.4),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? const Color(0xFFA855F7)
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a['name']!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  a['desc']!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),

              // ── 6. Primary Goal ──────────────────────────────────────────
              _sectionLabel('6. Primary Goal'),
              const SizedBox(height: 10),
              Column(
                children: _goals.map((g) {
                  final isSelected = _goal == g['name'];
                  return GestureDetector(
                    onTap: () => setState(() => _goal = g['name']),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFA855F7).withValues(alpha: 0.16)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFA855F7)
                              : AppColors.border.withValues(alpha: 0.4),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: isSelected
                                ? const Color(0xFFA855F7)
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  g['name']!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  g['desc']!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── 7. Custom Calorie Target (Optional) ──────────────────────
              _sectionLabel('7. Custom Calorie Target (Optional)'),
              const SizedBox(height: 6),
              const Text(
                'Write your own daily calorie budget if you have a specific target in mind, or leave empty to use your calculated nutrition goal.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              _typedInputCard(
                controller: _customCalorieController,
                label: 'Custom Calorie Goal',
                hintText: 'Write target kcal (e.g. 2000)',
                suffix: 'kcal',
                keyboardType: TextInputType.number,
                helperText: _customCalorieController.text.isNotEmpty
                    ? 'Custom target active: ${_customCalorieController.text} kcal/day'
                    : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // ── Dedicated Calculate BMI & Nutrition Goal Action Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _onCalculateTapped,
                  icon: const Icon(Icons.calculate_rounded, size: 20),
                  label: const Text(
                    'CALCULATE BMI & NUTRITION GOAL',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 1.1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    shadowColor: const Color(0xFF22C55E).withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA855F7).withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _saveAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA855F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          widget.isFirstTimeOnboarding
                              ? (metrics.containsKey('targetKcal')
                                  ? 'SAVE & START MEAL PLANNER (${metrics['targetKcal']} KCAL)'
                                  : 'SAVE & START MEAL PLANNER')
                              : (metrics.containsKey('targetKcal')
                                  ? 'SET AS DAILY GOAL (${metrics['targetKcal']} KCAL)'
                                  : 'SET AS DAILY NUTRITION GOAL'),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── BMI Spectrum & Results Card ───────────────────────────────────────────

  Widget _buildBmiSpectrumCard(Map<String, dynamic> metrics) {
    final hasMetrics = metrics.isNotEmpty;
    final bmi = hasMetrics
        ? ((metrics['bmi'] as num?)?.toDouble() ?? 21.7)
        : 21.7;
    final category = hasMetrics
        ? ((metrics['bmiCategory'] as String?) ?? 'Healthy Target')
        : 'Healthy Target';

    Color color = const Color(0xFF22C55E);
    if (hasMetrics && metrics['bmiColor'] is Color) {
      color = metrics['bmiColor'] as Color;
    } else if (hasMetrics) {
      if (bmi < 18.5) {
        color = const Color(0xFF38BDF8);
      } else if (bmi <= 24.9) {
        color = const Color(0xFF22C55E);
      } else if (bmi <= 29.9) {
        color = const Color(0xFFF59E0B);
      } else {
        color = const Color(0xFFEF4444);
      }
    }

    final targetKcalStr =
        hasMetrics && metrics['targetKcal'] != null ? '${metrics['targetKcal']} kcal' : '-- kcal';
    final bmrStr =
        hasMetrics && metrics['bmr'] != null ? '${metrics['bmr']} kcal' : '-- kcal';
    final tdeeStr =
        hasMetrics && metrics['tdee'] != null ? '${metrics['tdee']} kcal' : '-- kcal';
    final minH =
        hasMetrics && metrics['minHealthyWeight'] != null ? '${metrics['minHealthyWeight']}' : '55';
    final maxH =
        hasMetrics && metrics['maxHealthyWeight'] != null ? '${metrics['maxHealthyWeight']}' : '74';
    final currentW = _parsedWeight ??
        (hasMetrics && metrics['weightKg'] != null ? (metrics['weightKg'] as num).toDouble() : null);
    final minHW =
        hasMetrics && metrics['minHealthyWeight'] != null ? (metrics['minHealthyWeight'] as num).toDouble() : null;
    final maxHW =
        hasMetrics && metrics['maxHealthyWeight'] != null ? (metrics['maxHealthyWeight'] as num).toDouble() : null;
    String? weightAdvice;
    if (currentW != null && minHW != null && maxHW != null) {
      if (currentW < minHW) {
        final diff = (minHW - currentW).toStringAsFixed(1);
        weightAdvice = 'You are $diff kg below the healthy range threshold';
      } else if (currentW > maxHW) {
        final diff = (currentW - maxHW).toStringAsFixed(1);
        weightAdvice = 'You are $diff kg above the healthy range threshold';
      } else {
        weightAdvice = 'Your weight is in the optimal healthy range 👍';
      }
    }

    // Relative needle position along BMI range 14 to 36
    final clampedBmi = bmi.clamp(14.0, 36.0);
    final relativePos = ((clampedBmi - 14.0) / (36.0 - 14.0)).clamp(0.02, 0.98);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOUR BMI SCORE',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        hasMetrics ? '$bmi' : '--.-',
                        style: TextStyle(
                          color: color,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'kg/m²',
                        style: TextStyle(
                          color: color.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            hasMetrics ? category : '18.5 – 24.9',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: color,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Segmented Spectrum Bar ────────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      // Segmented colored track
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Row(
                          children: [
                            // Underweight (< 18.5)
                            Expanded(
                              flex: 45,
                              child: Container(
                                height: 10,
                                color: const Color(0xFF38BDF8),
                              ),
                            ),
                            const SizedBox(width: 2),
                            // Normal / Healthy (18.5 - 24.9)
                            Expanded(
                              flex: 64,
                              child: Container(
                                height: 10,
                                color: const Color(0xFF22C55E),
                              ),
                            ),
                            const SizedBox(width: 2),
                            // Overweight (25 - 29.9)
                            Expanded(
                              flex: 50,
                              child: Container(
                                height: 10,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 2),
                            // Obese (30+)
                            Expanded(
                              flex: 60,
                              child: Container(
                                height: 10,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Range labels
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('14', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                          Text('18.5', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.w600)),
                          Text('24.9', style: TextStyle(color: Color(0xFF22C55E), fontSize: 10, fontWeight: FontWeight.w700)),
                          Text('29.9', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.w600)),
                          Text('35+', style: TextStyle(color: Color(0xFFEF4444), fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  // Pointer Needle
                  Positioned(
                    left: (barWidth * relativePos) - 6,
                    top: -6,
                    child: Container(
                      width: 12,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Healthy Weight recommendation for this height
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF22C55E).withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF22C55E), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasMetrics
                            ? 'Ideal healthy weight range for your height: $minH – $maxH kg'
                            : 'Healthy BMI target: 18.5 – 24.9 kg/m² (write stats below to calculate)',
                        style: const TextStyle(
                          color: Color(0xFF22C55E),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (weightAdvice != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text(
                      weightAdvice,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // BMI Calculation Formula explanation card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calculate_outlined,
                    size: 15, color: Color(0xFFA855F7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasMetrics && currentW != null
                        ? 'Formula: ${currentW.toStringAsFixed(1)} kg ÷ (${((_parsedHeightCm ?? (metrics['heightCm'] as num).toDouble()) / 100).toStringAsFixed(2)} m)² = $bmi kg/m²'
                        : 'Formula: BMI = weight (kg) ÷ [height (m)]²',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Daily Target Calorie pill
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA855F7).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        targetKcalStr,
                        style: const TextStyle(
                          color: Color(0xFFA855F7),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'Target Goal',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        bmrStr,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'Base BMR',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        tdeeStr,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'TDEE Burn',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (hasMetrics && metrics.containsKey('proteinG')) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _macroPill(
                    label: 'Protein (30%)',
                    value: '${metrics['proteinG']}g',
                    color: const Color(0xFF4EA8DE),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _macroPill(
                    label: 'Carbs (45%)',
                    value: '${metrics['carbsG']}g',
                    color: const Color(0xFFF77F00),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _macroPill(
                    label: 'Fat (25%)',
                    value: '${metrics['fatG']}g',
                    color: const Color(0xFFE63946),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Helper UI Widgets ─────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _unitToggle({
    required String selected,
    required List<String> options,
    required ValueChanged<String> onSelect,
  }) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final isSel = selected == opt;
          return GestureDetector(
            onTap: () => onSelect(opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFFA855F7) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                opt,
                style: TextStyle(
                  color: isSel ? Colors.white : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _typedInputCard({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String suffix,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.number,
    Widget? trailingWidget,
    String? helperText,
  }) {
    final hasText = controller.text.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasText
              ? const Color(0xFFA855F7).withValues(alpha: 0.7)
              : AppColors.border.withValues(alpha: 0.5),
          width: hasText ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (trailingWidget != null) trailingWidget,
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.38),
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
              if (hasText)
                GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white70,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFA855F7).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  suffix,
                  style: const TextStyle(
                    color: Color(0xFFA855F7),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (helperText != null && helperText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              helperText,
              style: const TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _macroPill({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.9),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
