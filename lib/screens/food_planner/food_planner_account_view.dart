import 'package:flutter/material.dart';

import '../../data/food_planner_assets.dart';
import '../../routes/app_routes.dart';
import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';

/// Tab 3: Account & settings screen in Food Planner matching Planner Account.png through Planner Account 5.png.
class FoodPlannerAccountView extends StatefulWidget {
  const FoodPlannerAccountView({super.key});

  @override
  State<FoodPlannerAccountView> createState() => _FoodPlannerAccountViewState();
}

class _FoodPlannerAccountViewState extends State<FoodPlannerAccountView> {
  bool _addressExpanded = true;
  bool _plannerExpanded = true;

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
          onPressed: () {
            FoodPlannerController.instance.setActiveTab(0);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        children: [
          // ── Profile Header ──────────────────────────────────────────
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: Image.asset(
                    FoodPlannerAssets.artiAvatar,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, size: 50),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Arti Abraham',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+91 9874563210',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.edit_outlined,
                        size: 13, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 2),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'artiabraham123@gmail.com',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.edit_outlined,
                        size: 13, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // ── 1. Address Drawer ─────────────────────────────────────────
          _buildAddressSection(),
          const SizedBox(height: 14),
          // ── 2. Food Planner Drawer ────────────────────────────────────
          _buildFoodPlannerSection(),
          const SizedBox(height: 14),
          // ── 3. Calorie Counter Tile ───────────────────────────────────
          _simpleTile(
            icon: Icons.calculate_outlined,
            title: 'Calorie counter',
            onTap: () => FoodPlannerController.instance.setActiveTab(2),
          ),
          const SizedBox(height: 14),
          // ── 4. Payments Tile ──────────────────────────────────────────
          _simpleTile(
            icon: Icons.payment,
            title: 'Payments',
            onTap: () {
              Navigator.of(context)
                  .pushNamed(AppRoutes.foodPlannerManagePayments);
            },
          ),
          const SizedBox(height: 14),
          // ── 5. Order History Tile ─────────────────────────────────────
          _simpleTile(
            icon: Icons.restaurant_outlined,
            title: 'Order history',
            onTap: () {
              Navigator.of(context)
                  .pushNamed(AppRoutes.foodPlannerOrderHistory);
            },
          ),
          const SizedBox(height: 32),
          // ── 6. Logout ─────────────────────────────────────────────────
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(Icons.logout,
                color: AppColors.textSecondary, size: 20),
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _simpleTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon, color: AppColors.textSecondary, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.home_outlined,
                  color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 10),
              const Text(
                'Address',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    setState(() => _addressExpanded = !_addressExpanded),
                child: const Icon(Icons.edit_outlined,
                    size: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
          if (_addressExpanded) ...[
            const SizedBox(height: 18),
            _addressRow(
              type: 'Home',
              address: 'Flat no 9B, Landmark World, Palazhi, Calicut, 673014',
            ),
            const SizedBox(height: 14),
            _addressRow(
              type: 'Office',
              address:
                  'Cybaze technologies, UL Cyberpark, Palazhi, Calicut, 6730',
            ),
          ],
        ],
      ),
    );
  }

  Widget _addressRow({required String type, required String address}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3,
          height: 38,
          color: AppColors.accentRed,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 50,
          child: Text(
            type,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodPlannerSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_menu,
                  color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 10),
              const Text(
                'Food Planner',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    setState(() => _plannerExpanded = !_plannerExpanded),
                child: Icon(
                  _plannerExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
          if (_plannerExpanded) ...[
            const SizedBox(height: 18),
            // Today section with mini stepper
            const Text('Today',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _miniStep('Breakfast', done: true),
                _miniDivider(done: true),
                _miniStep('Lunch', done: true),
                _miniDivider(done: false),
                _miniStep('Dinner', done: false),
              ],
            ),
            const SizedBox(height: 20),
            // This week overview
            const Text('This Week',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(7, (i) {
                  final isDone = i < 2;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFF4CAF50)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 2}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 6),
            const Text('Food planned until Jan 7',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 20),
            // Next week actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Next Week',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Icon(Icons.edit_outlined,
                    size: 16, color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                FoodPlannerController.instance.setActiveTab(0);
              },
              child: const Row(
                children: [
                  Icon(Icons.add, color: AppColors.textSecondary, size: 18),
                  SizedBox(width: 8),
                  Text("Plan next week's menu",
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniStep(String label, {required bool done}) {
    return Column(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? const Color(0xFF4CAF50) : AppColors.surfaceLight,
          ),
          child: Icon(
            Icons.check,
            size: 11,
            color: done ? Colors.white : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: done ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _miniDivider({required bool done}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: done ? const Color(0xFF4CAF50) : AppColors.surfaceLight,
      ),
    );
  }
}
