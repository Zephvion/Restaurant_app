import 'package:flutter/foundation.dart';

/// An entry on the Notifications screen — food planner reminders,
/// calorie budget updates, nutrition tips, or promotional messages.
@immutable
class AppNotification {
  const AppNotification({
    this.id = '',
    required this.title,
    this.message,
    this.category = 'MEAL REMINDER',
    this.iconName = 'meal',
    this.actionLabel,
    this.actionRoute,
    this.actionMealType,
    this.orderId,
    this.imageUrl,
    this.isPlaced = false,
    this.isPromo = false,
    this.promoText,
    this.timestamp,
    this.read = false,
  });

  final String id;

  /// Main headline: "Log Today's Lunch! 🍛", "Daily Calorie Budget Update 🎯"
  final String title;

  /// Body / explanation: "Keep your calorie tracking consistent. Tap to log your afternoon meal."
  final String? message;

  /// Category tag: 'MEAL REMINDER', 'CALORIE GOAL', 'MEAL PLANNING', 'HEALTH TIP', 'WEEKLY SUMMARY'
  final String category;

  /// Identifier for icon: 'meal', 'fire', 'calendar', 'water', 'analytics', 'gift'
  final String iconName;

  /// Action button label: 'Log Lunch', 'View Stats', 'Plan Dinner'
  final String? actionLabel;

  /// Target route: e.g. AppRoutes.foodPlannerMenu, AppRoutes.foodPlannerCalculator
  final String? actionRoute;

  /// Target meal slot (breakfast, lunch, dinner, snacks) if applicable
  final String? actionMealType;

  /// Legacy order reference (if any)
  final String? orderId;

  /// Thumbnail image (optional)
  final String? imageUrl;

  /// Legacy order placed flag
  final bool isPlaced;

  /// Promotional offer flag
  final bool isPromo;
  final String? promoText;

  final DateTime? timestamp;
  final bool read;

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? category,
    String? iconName,
    String? actionLabel,
    String? actionRoute,
    String? actionMealType,
    String? orderId,
    String? imageUrl,
    bool? isPlaced,
    bool? isPromo,
    String? promoText,
    DateTime? timestamp,
    bool? read,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      actionLabel: actionLabel ?? this.actionLabel,
      actionRoute: actionRoute ?? this.actionRoute,
      actionMealType: actionMealType ?? this.actionMealType,
      orderId: orderId ?? this.orderId,
      imageUrl: imageUrl ?? this.imageUrl,
      isPlaced: isPlaced ?? this.isPlaced,
      isPromo: isPromo ?? this.isPromo,
      promoText: promoText ?? this.promoText,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'message': message,
        'category': category,
        'iconName': iconName,
        'actionLabel': actionLabel,
        'actionRoute': actionRoute,
        'actionMealType': actionMealType,
        'orderId': orderId,
        'imageUrl': imageUrl,
        'isPlaced': isPlaced,
        'isPromo': isPromo,
        'promoText': promoText,
        'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
        'read': read,
      };

  factory AppNotification.fromMap(Map<String, dynamic> map, {String? id}) {
    return AppNotification(
      id: id ?? (map['id'] as String? ?? ''),
      title: map['title'] as String? ?? '',
      message: map['message'] as String?,
      category: map['category'] as String? ?? 'MEAL REMINDER',
      iconName: map['iconName'] as String? ?? 'meal',
      actionLabel: map['actionLabel'] as String?,
      actionRoute: map['actionRoute'] as String?,
      actionMealType: map['actionMealType'] as String?,
      orderId: map['orderId'] as String?,
      imageUrl: map['imageUrl'] as String?,
      isPlaced: map['isPlaced'] as bool? ?? false,
      isPromo: map['isPromo'] as bool? ?? false,
      promoText: map['promoText'] as String?,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString())
          : null,
      read: map['read'] as bool? ?? false,
    );
  }
}
