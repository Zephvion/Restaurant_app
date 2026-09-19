import 'cart_item.dart';
import 'restaurant.dart';

/// The progression states of a takeaway order matching Figma design.
enum TakeawayStatus {
  preparing,
  packing,
  readyForTakeaway,
  taken,
  cancelled;

  static TakeawayStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'preparing':
        return TakeawayStatus.preparing;
      case 'packing':
        return TakeawayStatus.packing;
      case 'taken':
        return TakeawayStatus.taken;
      case 'cancelled':
        return TakeawayStatus.cancelled;
      case 'readyfortakeaway':
      case 'ready_for_takeaway':
      case 'ready':
      default:
        return TakeawayStatus.readyForTakeaway;
    }
  }
}

/// A confirmed takeaway order placed by the user.
class TakeawayOrder {
  TakeawayOrder({
    required this.id,
    this.userId = '',
    required this.restaurant,
    required this.items,
    this.status = TakeawayStatus.readyForTakeaway,
    this.paymentMethod = 'UPI (Google Pay)',
    this.transactionId,
    this.cancellationReason,
    this.cancelledAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id; // e.g. 'ID4578'
  final String userId;
  final Restaurant restaurant;
  final List<CartItem> items;
  TakeawayStatus status;
  final String paymentMethod;
  final String? transactionId;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final DateTime createdAt;

  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.quantity);

  double get grandTotal =>
      items.fold(0.0, (sum, item) => sum + item.lineTotal);

  bool get isCancelled => status == TakeawayStatus.cancelled;

  bool get canBeCancelled =>
      status != TakeawayStatus.taken && status != TakeawayStatus.cancelled;

  /// Preparation time in minutes calculated dynamically based on ordered dishes.
  int get prepTimeMinutes {
    if (items.isEmpty) return 15;
    int maxPrep = 0;
    for (final item in items) {
      if (item.dish.prepTimeMinutes > maxPrep) {
        maxPrep = item.dish.prepTimeMinutes;
      }
    }
    final extra = items.length > 3 ? 3 : 0;
    return (maxPrep > 0 ? maxPrep : 15) + extra;
  }

  /// Estimated time when takeaway is ready for pickup at the counter
  DateTime get estimatedReadyAt =>
      createdAt.add(Duration(minutes: prepTimeMinutes));

  /// Formatted pickup readiness time (e.g. "12:15 PM")
  String get formattedReadyTime {
    final t = estimatedReadyAt;
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  /// Formatted order time (e.g. "11:30 AM")
  String get formattedTime {
    final h = createdAt.hour % 12 == 0 ? 12 : createdAt.hour % 12;
    final m = createdAt.minute.toString().padLeft(2, '0');
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  /// Formatted order date (e.g. "Sep 19, 2026")
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
  }

  /// Status display label
  String get statusLabel {
    switch (status) {
      case TakeawayStatus.preparing:
        return 'Preparing';
      case TakeawayStatus.packing:
        return 'Packing';
      case TakeawayStatus.readyForTakeaway:
        return 'Ready for takeaway';
      case TakeawayStatus.taken:
        return 'Taken';
      case TakeawayStatus.cancelled:
        return 'Cancelled';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'restaurant': restaurant.toMap(),
        'items': items.map((e) => e.toMap()).toList(),
        'status': status.name,
        'paymentMethod': paymentMethod,
        'transactionId': transactionId,
        'cancellationReason': cancellationReason,
        'cancelledAt': cancelledAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory TakeawayOrder.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((e) => CartItem.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return TakeawayOrder(
      id: id ?? (map['id'] as String? ?? ''),
      userId: map['userId'] as String? ?? '',
      restaurant: map['restaurant'] != null
          ? Restaurant.fromMap(Map<String, dynamic>.from(map['restaurant'] as Map))
          : const Restaurant(
              id: 'rest_1',
              name: 'Paragon Restaurant',
              address: 'Kannur Road, Near CH Flyover',
              city: 'Calicut',
            ),
      items: items,
      status: TakeawayStatus.fromString(map['status'] as String?),
      paymentMethod: map['paymentMethod'] as String? ?? 'UPI (Google Pay)',
      transactionId: map['transactionId'] as String?,
      cancellationReason: map['cancellationReason'] as String?,
      cancelledAt: map['cancelledAt'] != null
          ? DateTime.tryParse(map['cancelledAt'].toString())
          : null,
      createdAt: map['createdAt'] != null
          ? (DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  TakeawayOrder copyWith({
    String? id,
    String? userId,
    Restaurant? restaurant,
    List<CartItem>? items,
    TakeawayStatus? status,
    String? paymentMethod,
    String? transactionId,
    String? cancellationReason,
    DateTime? cancelledAt,
    DateTime? createdAt,
  }) {
    return TakeawayOrder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurant: restaurant ?? this.restaurant,
      items: items ?? this.items,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
