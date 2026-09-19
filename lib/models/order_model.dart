import 'address.dart';

enum OrderStatus {
  placed,
  accepted,
  taken,
  outForDelivery,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.accepted:
        return 'Order accepted';
      case OrderStatus.taken:
        return 'Taken';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Done';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static OrderStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'placed':
        return OrderStatus.placed;
      case 'accepted':
      case 'order accepted':
        return OrderStatus.accepted;
      case 'taken':
        return OrderStatus.taken;
      case 'outfordelivery':
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
      case 'done':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.accepted;
    }
  }
}

class OrderItemModel {
  final String dishId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  const OrderItemModel({
    required this.dishId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl = '',
  });

  double get lineTotal => price * quantity;

  Map<String, dynamic> toMap() => {
        'dishId': dishId,
        'name': name,
        'price': price,
        'quantity': quantity,
        'imageUrl': imageUrl,
      };

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      dishId: map['dishId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: map['imageUrl'] as String? ?? '',
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double subtotal;
  final double gst;
  final double deliveryFee;
  final double discount;
  final double grandTotal;
  final String? appliedCoupon;
  final Address deliveryAddress;
  final String paymentMethodLabel;
  final OrderStatus status;
  final int estimatedDeliveryMinutes;
  final String deliveryPartnerName;
  final String deliveryPartnerPhone;
  final String deliveryPartnerPhotoUrl;
  final double riderLat;
  final double riderLng;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final String? refundStatus;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.gst,
    required this.deliveryFee,
    required this.discount,
    required this.grandTotal,
    this.appliedCoupon,
    required this.deliveryAddress,
    required this.paymentMethodLabel,
    this.status = OrderStatus.accepted,
    this.prepTimeMinutes = 15,
    this.transitMinutes = 12,
    this.estimatedDeliveryMinutes = 27,
    this.deliveryPartnerName = 'John Doe',
    this.deliveryPartnerPhone = '+91 987654321',
    this.deliveryPartnerPhotoUrl =
        'https://images.unsplash.com/photo-1633332755192-727a05c4013d?auto=format&fit=crop&w=120&q=70',
    this.riderLat = 11.2588,
    this.riderLng = 75.7804,
    this.cancellationReason,
    this.cancelledAt,
    this.refundStatus,
    required this.createdAt,
  });

  final int prepTimeMinutes;
  final int transitMinutes;

  bool get isCancelled => status == OrderStatus.cancelled;

  bool get canBeCancelled =>
      status != OrderStatus.delivered && status != OrderStatus.cancelled;

  /// Estimated time when delivery will arrive
  DateTime get estimatedDeliveryAt =>
      createdAt.add(Duration(minutes: estimatedDeliveryMinutes));

  String get formattedEstimatedDeliveryTime {
    final t = estimatedDeliveryAt;
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

  OrderModel copyWith({
    String? id,
    String? userId,
    List<OrderItemModel>? items,
    double? subtotal,
    double? gst,
    double? deliveryFee,
    double? discount,
    double? grandTotal,
    String? appliedCoupon,
    Address? deliveryAddress,
    String? paymentMethodLabel,
    OrderStatus? status,
    int? prepTimeMinutes,
    int? transitMinutes,
    int? estimatedDeliveryMinutes,
    String? deliveryPartnerName,
    String? deliveryPartnerPhone,
    String? deliveryPartnerPhotoUrl,
    double? riderLat,
    double? riderLng,
    String? cancellationReason,
    DateTime? cancelledAt,
    String? refundStatus,
    DateTime? createdAt,
  }) {
    final prep = prepTimeMinutes ?? this.prepTimeMinutes;
    final transit = transitMinutes ?? this.transitMinutes;
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      gst: gst ?? this.gst,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      grandTotal: grandTotal ?? this.grandTotal,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethodLabel: paymentMethodLabel ?? this.paymentMethodLabel,
      status: status ?? this.status,
      prepTimeMinutes: prep,
      transitMinutes: transit,
      estimatedDeliveryMinutes:
          estimatedDeliveryMinutes ?? (prep + transit),
      deliveryPartnerName: deliveryPartnerName ?? this.deliveryPartnerName,
      deliveryPartnerPhone: deliveryPartnerPhone ?? this.deliveryPartnerPhone,
      deliveryPartnerPhotoUrl:
          deliveryPartnerPhotoUrl ?? this.deliveryPartnerPhotoUrl,
      riderLat: riderLat ?? this.riderLat,
      riderLng: riderLng ?? this.riderLng,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      refundStatus: refundStatus ?? this.refundStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'items': items.map((e) => e.toMap()).toList(),
        'subtotal': subtotal,
        'gst': gst,
        'deliveryFee': deliveryFee,
        'discount': discount,
        'grandTotal': grandTotal,
        'appliedCoupon': appliedCoupon,
        'deliveryAddress': deliveryAddress.toMap(),
        'paymentMethodLabel': paymentMethodLabel,
        'status': status.name,
        'prepTimeMinutes': prepTimeMinutes,
        'transitMinutes': transitMinutes,
        'estimatedDeliveryMinutes': estimatedDeliveryMinutes,
        'deliveryPartnerName': deliveryPartnerName,
        'deliveryPartnerPhone': deliveryPartnerPhone,
        'deliveryPartnerPhotoUrl': deliveryPartnerPhotoUrl,
        'riderLat': riderLat,
        'riderLng': riderLng,
        'cancellationReason': cancellationReason,
        'cancelledAt': cancelledAt?.toIso8601String(),
        'refundStatus': refundStatus,
        'createdAt': createdAt.toIso8601String(),
      };

  factory OrderModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((e) => OrderItemModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return OrderModel(
      id: id ?? (map['id'] as String? ?? ''),
      userId: map['userId'] as String? ?? '',
      items: items,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      gst: (map['gst'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (map['grandTotal'] as num?)?.toDouble() ?? 0.0,
      appliedCoupon: map['appliedCoupon'] as String?,
      deliveryAddress: map['deliveryAddress'] != null
          ? Address.fromMap(
              Map<String, dynamic>.from(map['deliveryAddress'] as Map))
          : const Address(
              id: 'addr_1',
              label: 'Home',
              details: 'Palazhi , Calicut',
              isDefault: true,
            ),
      paymentMethodLabel:
          map['paymentMethodLabel'] as String? ?? 'Card ending with *8754',
      status: OrderStatus.fromString(map['status'] as String?),
      prepTimeMinutes:
          (map['prepTimeMinutes'] as num?)?.toInt() ?? 15,
      transitMinutes:
          (map['transitMinutes'] as num?)?.toInt() ?? 12,
      estimatedDeliveryMinutes:
          (map['estimatedDeliveryMinutes'] as num?)?.toInt() ?? 27,
      deliveryPartnerName:
          map['deliveryPartnerName'] as String? ?? 'John Doe',
      deliveryPartnerPhone:
          map['deliveryPartnerPhone'] as String? ?? '+91 987654321',
      deliveryPartnerPhotoUrl: map['deliveryPartnerPhotoUrl'] as String? ??
          'https://images.unsplash.com/photo-1633332755192-727a05c4013d?auto=format&fit=crop&w=120&q=70',
      riderLat: (map['riderLat'] as num?)?.toDouble() ?? 11.2588,
      riderLng: (map['riderLng'] as num?)?.toDouble() ?? 75.7804,
      cancellationReason: map['cancellationReason'] as String?,
      cancelledAt: map['cancelledAt'] != null
          ? DateTime.tryParse(map['cancelledAt'].toString())
          : null,
      refundStatus: map['refundStatus'] as String?,
      createdAt: map['createdAt'] != null
          ? (DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}

