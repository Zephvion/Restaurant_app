/// Meal period types for weekly food planning.
enum MealType {
  breakfast,
  lunch,
  dinner,
  snacks,
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
      case MealType.snacks:
        return 'SNACKS';
    }
  }

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snacks:
        return 'Snacks & Drinks';
    }
  }

  static MealType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      case 'snacks':
      case 'snack':
        return MealType.snacks;
      case 'breakfast':
      default:
        return MealType.breakfast;
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
    this.dishId = '',
    this.servings = 1,
    this.calories = 320,
    this.weightGm = 300,
    this.price = 80.0,
    this.protein = 20,
    this.carbs = 40,
    this.fat = 10,
  });

  final String id;
  final int dayOffset; // 0..6 (e.g. 0 for Tuesday Jan 2)
  final MealType mealType;
  final String timeSlot; // e.g. '7:30AM'
  final String location; // 'HOME' or 'OFFICE'
  final String dishName;
  final String imageUrl;
  final String dishId;
  final int servings;
  final int calories;
  final int weightGm;
  final double price;
  final int protein;
  final int carbs;
  final int fat;

  PlannedMeal copyWith({
    String? id,
    int? dayOffset,
    MealType? mealType,
    String? timeSlot,
    String? location,
    String? dishName,
    String? imageUrl,
    String? dishId,
    int? servings,
    int? calories,
    int? weightGm,
    double? price,
    int? protein,
    int? carbs,
    int? fat,
  }) {
    return PlannedMeal(
      id: id ?? this.id,
      dayOffset: dayOffset ?? this.dayOffset,
      mealType: mealType ?? this.mealType,
      timeSlot: timeSlot ?? this.timeSlot,
      location: location ?? this.location,
      dishName: dishName ?? this.dishName,
      imageUrl: imageUrl ?? this.imageUrl,
      dishId: dishId ?? this.dishId,
      servings: servings ?? this.servings,
      calories: calories ?? this.calories,
      weightGm: weightGm ?? this.weightGm,
      price: price ?? this.price,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'dayOffset': dayOffset,
        'mealType': mealType.name,
        'timeSlot': timeSlot,
        'location': location,
        'dishName': dishName,
        'imageUrl': imageUrl,
        'dishId': dishId,
        'servings': servings,
        'calories': calories,
        'weightGm': weightGm,
        'price': price,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory PlannedMeal.fromMap(Map<String, dynamic> map, {String? id}) {
    return PlannedMeal(
      id: id ?? (map['id'] as String? ?? ''),
      dayOffset: (map['dayOffset'] as num?)?.toInt() ?? 0,
      mealType: MealTypeExt.fromString(map['mealType'] as String?),
      timeSlot: map['timeSlot'] as String? ?? '7:30AM',
      location: map['location'] as String? ?? 'HOME',
      dishName: map['dishName'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      dishId: map['dishId'] as String? ?? '',
      servings: (map['servings'] as num?)?.toInt() ?? 1,
      calories: (map['calories'] as num?)?.toInt() ?? 320,
      weightGm: (map['weightGm'] as num?)?.toInt() ?? 300,
      price: (map['price'] as num?)?.toDouble() ?? 80.0,
      protein: (map['protein'] as num?)?.toInt() ?? 20,
      carbs: (map['carbs'] as num?)?.toInt() ?? 40,
      fat: (map['fat'] as num?)?.toInt() ?? 10,
    );
  }
}

/// Order tracking status for Food Planner active deliveries.
enum PlannerOrderStatus {
  orderAccepted,
  taken,
  done;

  static PlannerOrderStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'taken':
        return PlannerOrderStatus.taken;
      case 'done':
        return PlannerOrderStatus.done;
      case 'orderaccepted':
      case 'order_accepted':
      default:
        return PlannerOrderStatus.orderAccepted;
    }
  }
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

  Map<String, dynamic> toMap() => {
        'orderId': orderId,
        'etaMins': etaMins,
        'status': status.name,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'driverPhotoUrl': driverPhotoUrl,
        'paymentLabel': paymentLabel,
        'deliveryTimeWindow': deliveryTimeWindow,
        'items': items.map((e) => e.toMap()).toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
      };

  factory PlannerTrackOrder.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((e) => PlannerOrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return PlannerTrackOrder(
      orderId: map['orderId'] as String? ?? '',
      etaMins: (map['etaMins'] as num?)?.toInt() ?? 15,
      status: PlannerOrderStatus.fromString(map['status'] as String?),
      driverName: map['driverName'] as String? ?? 'John Doe',
      driverPhone: map['driverPhone'] as String? ?? '+91 987654321',
      driverPhotoUrl: map['driverPhotoUrl'] as String? ?? '',
      paymentLabel: map['paymentLabel'] as String? ?? '',
      deliveryTimeWindow: map['deliveryTimeWindow'] as String? ?? '',
      items: items,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0.0,
    );
  }
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

  Map<String, dynamic> toMap() => {
        'name': name,
        'quantity': quantity,
        'price': price,
      };

  factory PlannerOrderItem.fromMap(Map<String, dynamic> map) {
    return PlannerOrderItem(
      name: map['name'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
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

  Map<String, dynamic> toMap() => {
        'targetKcal': targetKcal,
        'remainingKcal': remainingKcal,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
      };

  factory CalorieStats.fromMap(Map<String, dynamic> map) {
    return CalorieStats(
      targetKcal: (map['targetKcal'] as num?)?.toInt() ?? 2000,
      remainingKcal: (map['remainingKcal'] as num?)?.toInt() ?? 800,
      proteinG: (map['proteinG'] as num?)?.toInt() ?? 50,
      carbsG: (map['carbsG'] as num?)?.toInt() ?? 75,
      fatG: (map['fatG'] as num?)?.toInt() ?? 100,
    );
  }
}
