import 'cart_item.dart';
import 'restaurant.dart';

/// The progression states of a takeaway order matching Figma design.
enum TakeawayStatus {
  preparing,
  packing,
  readyForTakeaway,
  taken,
}

/// A confirmed takeaway order placed by the user.
class TakeawayOrder {
  TakeawayOrder({
    required this.id,
    required this.restaurant,
    required this.items,
    this.status = TakeawayStatus.readyForTakeaway,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id; // e.g. 'ID4578'
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
}
