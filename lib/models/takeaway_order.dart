import 'cart_item.dart';
import 'restaurant.dart';

/// The progression states of a takeaway order matching Figma design.
enum TakeawayStatus {
  preparing,
  packing,
  readyForTakeaway,
  taken;

  static TakeawayStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'preparing':
        return TakeawayStatus.preparing;
      case 'packing':
        return TakeawayStatus.packing;
      case 'taken':
        return TakeawayStatus.taken;
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
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id; // e.g. 'ID4578'
  final String userId;
  final Restaurant restaurant;
  final List<CartItem> items;
  TakeawayStatus status;
  final DateTime createdAt;

  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.quantity);

  double get grandTotal =>
      items.fold(0.0, (sum, item) => sum + item.lineTotal);

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
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'restaurant': restaurant.toMap(),
        'items': items.map((e) => e.toMap()).toList(),
        'status': status.name,
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
      createdAt: map['createdAt'] != null
          ? (DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}
