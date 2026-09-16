import 'package:flutter/foundation.dart';

/// An entry on the Notifications screen — either an order status update or a
/// promotional message.
@immutable
class AppNotification {
  const AppNotification({
    required this.title,
    this.orderId,
    this.imageUrl,
    this.isPlaced = false,
    this.isPromo = false,
    this.promoText,
  });

  /// "Arriving Soon", "Order Placed"…
  final String title;

  /// Order reference (shown as "Order ID  PO78965412").
  final String? orderId;

  /// Thumbnail for order notifications.
  final String? imageUrl;

  /// Shows the green tick beside the title.
  final bool isPlaced;

  /// Renders the promo style (gift icon + offer text) instead of an order row.
  final bool isPromo;
  final String? promoText;
}
