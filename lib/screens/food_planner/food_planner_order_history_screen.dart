import 'package:flutter/material.dart';

import '../../data/food_planner_assets.dart';
import '../../theme/app_colors.dart';

/// Order History screen for Food Planner matching Planner Account 7.png.
class FoodPlannerOrderHistoryScreen extends StatefulWidget {
  const FoodPlannerOrderHistoryScreen({super.key});

  @override
  State<FoodPlannerOrderHistoryScreen> createState() =>
      _FoodPlannerOrderHistoryScreenState();
}

class _FoodPlannerOrderHistoryScreenState
    extends State<FoodPlannerOrderHistoryScreen> {
  int _selectedDayOffset = 0;

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
        title: const Text(
          'Order History',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios,
                    size: 11, color: AppColors.textSecondary),
                SizedBox(width: 4),
                Text(
                  'Jan 2 - 8',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios,
                    size: 11, color: AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        children: [
          // ── Date Strip ────────────────────────────────────────────────
          _dateStrip(),
          const SizedBox(height: 24),
          // ── Day's Planned Meals Rail ──────────────────────────────────
          _mealsRail(),
          const SizedBox(height: 28),
          // ── Payment Receipt Card ──────────────────────────────────────
          _paymentReceiptCard(),
        ],
      ),
    );
  }

  Widget _dateStrip() {
    const days = ['Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(7, (i) {
          final isSelected = _selectedDayOffset == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayOffset = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              width: 52,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentRed : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
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

  Widget _mealsRail() {
    return SizedBox(
      height: 240,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _mealCard(
            period: 'BREAKFAST - 7:30AM',
            name: 'Dosa',
            imageUrl: FoodPlannerAssets.dosa,
          ),
          const SizedBox(width: 14),
          _mealCard(
            period: 'LUNCH - 12:30PM',
            name: 'Meals',
            imageUrl: FoodPlannerAssets.meals,
          ),
          const SizedBox(width: 14),
          _mealCard(
            period: 'DINNER - 8:00PM',
            name: 'Chappathi Curry',
            imageUrl: FoodPlannerAssets.chappathi,
          ),
        ],
      ),
    );
  }

  Widget _mealCard({
    required String period,
    required String name,
    required String imageUrl,
  }) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 140,
              height: 160,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.restaurant),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            period,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            name,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          const Text('🔥 320 kcal  ⚖️ 300 gm',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _paymentReceiptCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '₹ 245',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Paid',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              Text('artiabraham@oksbi',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.border),
          ),
          _receiptRow('Meals', 'LUNCH', '₹ 50'),
          const SizedBox(height: 8),
          _receiptRow('Chappathi', 'DINNER', '₹ 50'),
          const SizedBox(height: 14),
          _simpleRow('Subtotal', '₹ 150'),
          const SizedBox(height: 6),
          _simpleRow('GST', '₹ 35'),
          const SizedBox(height: 6),
          _simpleRow('Delivery partner fee for 8km', '₹ 60'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.border),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand Total',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              Text('₹ 245',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String name, String tag, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(name,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13)),
            const SizedBox(width: 8),
            Text(tag,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        Text(price,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _simpleRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
