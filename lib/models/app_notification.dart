import 'package:flutter/foundation.dart';

/// An entry on the Notifications screen — either an order status update or a
/// promotional message.
@immutable
class AppNotification {
  const AppNotification({
    this.id = '',
    required this.title,
    this.orderId,
    this.imageUrl,
    this.isPlaced = false,
    this.isPromo = false,
    this.promoText,
    this.timestamp,
    this.read = false,
  });

  final String id;

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

  final DateTime? timestamp;
  final bool read;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
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
