import 'package:flutter/material.dart';

import '../../models/takeaway_order.dart';
import '../../state/takeaway_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';
import '../../widgets/order_cancellation_sheet.dart';

/// Takeaway Order Card displaying restaurant name, real-time date/time, status label,
/// items breakdown, grand total, progress stepper (or cancelled status), order ID,
/// call restaurant action, cancellation action, and 1-tap reorder.
class TakeawayOrderCard extends StatelessWidget {
  const TakeawayOrderCard({super.key, required this.order});
  final TakeawayOrder order;

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.isCancelled;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCancelled
              ? AppColors.accentRed.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.06),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.copper,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.formattedDate} · ${order.formattedTime}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCancelled
                      ? AppColors.accentRed.withValues(alpha: 0.15)
                      : const Color(0xFF1B2E1D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCancelled
                        ? AppColors.accentRed.withValues(alpha: 0.4)
                        : const Color(0xFF388E3C),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isCancelled
                            ? AppColors.accentRed
                            : const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.statusLabel,
                      style: TextStyle(
                        color: isCancelled
                            ? AppColors.accentRed
                            : const Color(0xFF4CAF50),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 12),
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
                Text(
                  'Paid via ${order.paymentMethod}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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

          const SizedBox(height: 12),

          // ── Prep Time & Ready By Indicator ──────────────────────────────
          if (!isCancelled) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.copper.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_filled,
                      color: AppColors.copper, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Prep Time: ~${order.prepTimeMinutes} mins · Ready by ${order.formattedReadyTime}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Progress Stepper or Cancelled Details ───────────────────────
          if (!isCancelled)
            TakeawayProgressStepper(
              status: order.status,
              prepTimeMinutes: order.prepTimeMinutes,
              formattedReadyTime: order.formattedReadyTime,
            )
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.accentRed.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.accentRed, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Order Cancelled ${order.cancelledAt != null ? "at ${order.cancelledAt!.hour % 12 == 0 ? 12 : order.cancelledAt!.hour % 12}:${order.cancelledAt!.minute.toString().padLeft(2, '0')} ${order.cancelledAt!.hour >= 12 ? 'PM' : 'AM'}" : ""}',
                        style: const TextStyle(
                          color: AppColors.accentRed,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (order.cancellationReason != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Reason: ${order.cancellationReason}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '100% Refund of \$${order.grandTotal.toStringAsFixed(2)} initiated to ${order.paymentMethod}',
                    style: const TextStyle(
                      color: Color(0xFF81C784),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),

          // ── Order ID, Call Action & Cancel / Reorder Actions ───────────
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
                  AppBanner.show(
                    context,
                    message: 'Calling ${order.restaurant.name}...',
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

          const SizedBox(height: 12),

          // Cancellation or Reorder Action button
          if (order.canBeCancelled)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text(
                  'Cancel Order (Free Refund)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentRed,
                  side: BorderSide(
                    color: AppColors.accentRed.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  OrderCancellationSheet.show(
                    context: context,
                    orderId: order.id,
                    amount: order.grandTotal,
                    paymentMode: order.paymentMethod,
                    isTakeaway: true,
                    onConfirmCancel: (reason) async {
                      await TakeawayController.instance.cancelOrder(
                        order.id,
                        reason: reason,
                      );
                      if (context.mounted) {
                        AppBanner.showSuccess(
                          context,
                          'Takeaway order #${order.id} cancelled. 100% refund initiated!',
                          title: 'Order Cancelled',
                        );
                      }
                    },
                  );
                },
              ),
            )
          else if (isCancelled)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text(
                  'Reorder Items',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  TakeawayController.instance.reorder(order);
                  AppBanner.showSuccess(
                    context,
                    'Items from #${order.id} added back to your takeaway basket!',
                    title: 'Items Reordered',
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── Progress Stepper ──────────────────────────────────────────────────────────

class TakeawayProgressStepper extends StatelessWidget {
  const TakeawayProgressStepper({
    super.key,
    required this.status,
    this.prepTimeMinutes,
    this.formattedReadyTime,
  });

  final TakeawayStatus status;
  final int? prepTimeMinutes;
  final String? formattedReadyTime;

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

    final prepLabel = prepTimeMinutes != null
        ? 'Preparing\n(~${prepTimeMinutes}m)'
        : 'Preparing';

    final readyLabel = status == TakeawayStatus.taken
        ? 'Taken'
        : (formattedReadyTime != null
            ? 'Ready\n($formattedReadyTime)'
            : 'Ready');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _stepItem(label: prepLabel, active: isPreparingDone),
        _divider(active: isPackingDone),
        _stepItem(label: 'Packing', active: isPackingDone),
        _divider(active: isTakenDone),
        _stepItem(label: readyLabel, active: isTakenDone || status == TakeawayStatus.readyForTakeaway),
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
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 10,
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

