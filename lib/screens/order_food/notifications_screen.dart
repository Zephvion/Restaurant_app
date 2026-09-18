import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/app_notification.dart';
import '../../models/meal_plan.dart';
import '../../routes/app_routes.dart';
import '../../services/notification_service.dart';
import '../../state/food_planner_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_banner.dart';

/// Notifications — Food Planner meal logging reminders, calorie budget updates,
/// macro goal alerts, and health tips.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifications & Reminders',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(Icons.done_all_rounded, color: AppColors.copper),
            onPressed: () {
              NotificationService.instance.markAllAsRead();
              AppToast.showSuccess(context, 'All notifications marked as read');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: NotificationService.instance.streamNotifications(),
        initialData: NotificationService.instance.notifications,
        builder: (context, snapshot) {
          final notifications = snapshot.data ?? MockData.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.copper.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_off_outlined,
                        color: AppColors.copper,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'All Caught Up!',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No pending reminders or meal updates. Your food plan is looking great!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.copper,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                          AppRoutes.foodPlanner,
                        );
                      },
                      icon: const Icon(Icons.restaurant_menu_rounded, size: 18),
                      label: const Text(
                        'Open Food Planner',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final n = notifications[i];
              if (n.isPromo) {
                return _PromoNotification(text: n.promoText ?? '');
              }
              return _FoodPlannerNotificationCard(
                notification: n,
                onTapAction: () => _handleNotificationAction(context, n),
                onDismiss: () {
                  NotificationService.instance.deleteNotification(n.id);
                  AppToast.showInfo(context, 'Notification dismissed');
                },
              );
            },
          );
        },
      ),
    );
  }

  void _handleNotificationAction(BuildContext context, AppNotification n) {
    NotificationService.instance.markAsRead(n.id);

    // If notification targets a specific meal slot (lunch, dinner, etc.), configure slot first
    if (n.actionMealType != null) {
      final ctrl = FoodPlannerController.instance;
      MealType targetType = MealType.lunch;
      if (n.actionMealType == 'breakfast') {
        targetType = MealType.breakfast;
      } else if (n.actionMealType == 'dinner') {
        targetType = MealType.dinner;
      } else if (n.actionMealType == 'snacks') {
        targetType = MealType.snacks;
      }

      ctrl.setupSlot(
        mealType: targetType,
        timeSlot: targetType == MealType.lunch
            ? '1:00PM'
            : targetType == MealType.dinner
                ? '8:00PM'
                : '8:00AM',
        location: 'HOME',
      );
    }

    final route = n.actionRoute ?? AppRoutes.foodPlanner;
    Navigator.of(context).pushNamed(route);
  }
}

class _FoodPlannerNotificationCard extends StatelessWidget {
  const _FoodPlannerNotificationCard({
    required this.notification,
    required this.onTapAction,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onTapAction;
  final VoidCallback onDismiss;

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'calendar':
        return Icons.calendar_month_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'analytics':
        return Icons.insights_rounded;
      case 'meal':
      default:
        return Icons.restaurant_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'CALORIE GOAL':
        return const Color(0xFFFF8A65);
      case 'MEAL PLANNING':
        return AppColors.copper;
      case 'HEALTH TIP':
        return const Color(0xFF38BDF8);
      case 'WEEKLY SUMMARY':
        return const Color(0xFFA78BFA);
      case 'MEAL REMINDER':
      default:
        return const Color(0xFF4ADE80);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(notification.category);
    final iconData = _getIconData(notification.iconName);
    final isUnread = !notification.read;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread
            ? AppColors.surface
            : AppColors.backgroundElevated.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnread
              ? catColor.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.05),
          width: isUnread ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category badge + unread dot + dismiss ─────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(iconData, size: 13, color: catColor),
                    const SizedBox(width: 5),
                    Text(
                      notification.category.toUpperCase(),
                      style: TextStyle(
                        color: catColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isUnread) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: catColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: catColor.withValues(alpha: 0.6),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              GestureDetector(
                onTap: onDismiss,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Title & Message ───────────────────────────────────────────────
          Text(
            notification.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          if (notification.message != null &&
              notification.message!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              notification.message!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],

          // ── Interactive Action Button (if applicable) ─────────────────────
          if (notification.actionLabel != null &&
              notification.actionLabel!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: onTapAction,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: catColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          notification.actionLabel!,
                          style: TextStyle(
                            color: catColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: catColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PromoNotification extends StatelessWidget {
  const _PromoNotification({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [AppColors.maroon, AppColors.accentRed],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.card_giftcard, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
