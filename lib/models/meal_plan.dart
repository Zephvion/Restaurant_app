/// Meal period types for weekly food planning.
enum MealType {
  breakfast,
  lunch,
  dinner,
}

extension MealTypeExt on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'BREAKFAST';
      case MealType.lunch:
        return 'LUNCH';
      case MealType.dinner:
        return 'DINNER';
    }
  }
}

/// A planned meal on a specific day in the Food Planner.
class PlannedMeal {
  PlannedMeal({
    required this.id,
    required this.dayOffset,
    required this.mealType,
    required this.timeSlot,
    required this.location,
    required this.dishName,
    required this.imageUrl,
    this.calories = 320,
    this.weightGm = 300,
    this.price = 80.0,
    this.protein = 50,
    this.carbs = 50,
    this.fat = 50,
  });

  final String id;
  final int dayOffset; // 0..6 (e.g. 0 for Tuesday Jan 2)
  final MealType mealType;
  final String timeSlot; // e.g. '7:30AM'
  final String location; // 'HOME' or 'OFFICE'
  final String dishName;
  final String imageUrl;
  final int calories;
  final int weightGm;
  final double price;
  final int protein;
  final int carbs;
  final int fat;
}

/// Order tracking status for Food Planner active deliveries.
enum PlannerOrderStatus {
  orderAccepted,
  taken,
  done,
}

/// An active or historical order placed through the Food Planner.
class PlannerTrackOrder {
  PlannerTrackOrder({
    required this.orderId,
    required this.etaMins,
    required this.status,
    required this.driverName,
    required this.driverPhone,
    required this.driverPhotoUrl,
    required this.paymentLabel,
    required this.deliveryTimeWindow,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
  });

  final String orderId;
  final int etaMins;
  final PlannerOrderStatus status;
  final String driverName;
  final String driverPhone;
  final String driverPhotoUrl;
  final String paymentLabel;
  final String deliveryTimeWindow;
  final List<PlannerOrderItem> items;
  final double subtotal;
  final double deliveryFee;

  double get grandTotal => subtotal + deliveryFee;
}

class PlannerOrderItem {
  const PlannerOrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String name;
  final int quantity;
  final double price;
}

/// User's daily calorie targets & statistics.
class CalorieStats {
  CalorieStats({
    this.targetKcal = 2000,
    this.remainingKcal = 800,
    this.proteinG = 50,
    this.carbsG = 75,
    this.fatG = 100,
  });

  final int targetKcal;
  final int remainingKcal;
  final int proteinG;
  final int carbsG;
  final int fatG;

  CalorieStats copyWith({
    int? targetKcal,
    int? remainingKcal,
    int? proteinG,
    int? carbsG,
    int? fatG,
  }) {
    return CalorieStats(
      targetKcal: targetKcal ?? this.targetKcal,
      remainingKcal: remainingKcal ?? this.remainingKcal,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
    );
  }
}
