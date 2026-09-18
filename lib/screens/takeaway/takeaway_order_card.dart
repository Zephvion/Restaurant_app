import 'package:flutter/material.dart';

import '../../models/takeaway_order.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';

/// Takeaway Order Card displaying restaurant name, status label, items breakdown,
/// grand total, progress stepper (Preparing -> Packing -> Taken), order ID,
/// and a call restaurant action.
class TakeawayOrderCard extends StatelessWidget {
  const TakeawayOrderCard({super.key, required this.order});
  final TakeawayOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Restaurant name & Status row ─────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.restaurant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.copper,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accentRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    order.statusLabel,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 10),
            // Items detailed breakdown
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity}x ${item.dish.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '\$${item.lineTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Paid',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${order.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.accentRed,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          // ── Progress Stepper ────────────────────────────────────────────
          TakeawayProgressStepper(status: order.status),
          const SizedBox(height: 20),
          // ── Order ID & Call Action ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ORDER ID : ${order.id}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              GestureDetector(
                onTap: () {
                  AppToast.showInfo(
                    context,
                    'Calling ${order.restaurant.name}...',
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      'Call restaurant',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.phone, color: AppColors.accentRed, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Progress Stepper ──────────────────────────────────────────────────────────

class TakeawayProgressStepper extends StatelessWidget {
  const TakeawayProgressStepper({super.key, required this.status});
  final TakeawayStatus status;

  @override
  Widget build(BuildContext context) {
    final isPreparingDone = status == TakeawayStatus.preparing ||
        status == TakeawayStatus.packing ||
        status == TakeawayStatus.readyForTakeaway ||
        status == TakeawayStatus.taken;

    final isPackingDone = status == TakeawayStatus.packing ||
        status == TakeawayStatus.readyForTakeaway ||
        status == TakeawayStatus.taken;

    final isTakenDone = status == TakeawayStatus.taken;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _stepItem(label: 'Preparing', active: isPreparingDone),
        _divider(active: isPackingDone),
        _stepItem(label: 'Packing', active: isPackingDone),
        _divider(active: isTakenDone),
        _stepItem(label: 'Taken', active: isTakenDone),
      ],
    );
  }

  Widget _stepItem({required String label, required bool active}) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? const Color(0xFF4CAF50) : AppColors.surfaceLight,
          ),
          child: Icon(
            Icons.check,
            size: 14,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _divider({required bool active}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: List.generate(
            6,
            (index) => Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                color: active ? const Color(0xFF4CAF50) : AppColors.surfaceLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

