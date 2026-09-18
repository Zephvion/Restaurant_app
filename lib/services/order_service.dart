import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/address.dart';
import '../models/cart_item.dart';
import '../models/order_model.dart';
import '../models/payment_method.dart';
import 'auth_service.dart';
import 'firebase_initializer.dart';
import 'session_manager.dart';

class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  final Map<String, OrderModel> _localOrders = {};
  final Map<String, StreamController<OrderModel>> _orderStreams = {};

  Future<void> init() async {
    // Populate an initial default mock order for tracking demo
    final defaultOrder = OrderModel(
      id: MockData.orderId,
      userId: AuthService.instance.currentUser?.uid ?? 'usr_demo',
      items: [
        const OrderItemModel(
          dishId: 'dish_dosa',
          name: 'Plain Dosa',
          price: 80,
          quantity: 1,
          imageUrl:
              'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=400&q=70',
        ),
        const OrderItemModel(
          dishId: 'dish_orange_juice',
          name: 'Fresh Juice - Orange',
          price: 110,
          quantity: 1,
          imageUrl:
              'https://images.unsplash.com/photo-1613478223719-2ab802602423?auto=format&fit=crop&w=400&q=70',
        ),
      ],
      subtotal: 190,
      gst: 28,
      deliveryFee: 30,
      discount: 0,
      grandTotal: 220,
      deliveryAddress: MockData.addresses.first,
      paymentMethodLabel: 'Card Payment Ending with *8754',
      status: OrderStatus.taken,
      estimatedDeliveryMinutes: 15,
      deliveryPartnerName: MockData.deliveryPartnerName,
      deliveryPartnerPhone: MockData.deliveryPartnerPhone,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    );

    _localOrders[defaultOrder.id] = defaultOrder;
  }

  /// Places a new order and returns the generated order
  Future<OrderModel> placeOrder({
    required List<CartItem> items,
    required Address address,
    required PaymentMethod payment,
    required double subtotal,
    required double gst,
    required double deliveryFee,
    required double discount,
    required double grandTotal,
    String? coupon,
  }) async {
    final orderId = 'PO${10000000 + DateTime.now().millisecondsSinceEpoch % 90000000}';
    final uid = AuthService.instance.currentUser?.uid ??
        SessionManager.instance.currentUserId ??
        'usr_guest';

    final orderItems = items
        .map((e) => OrderItemModel(
              dishId: e.dish.id,
              name: e.dish.name,
              price: e.dish.price,
              quantity: e.quantity,
              imageUrl: e.dish.imageUrl,
            ))
        .toList();

    final order = OrderModel(
      id: orderId,
      userId: uid,
      items: orderItems,
      subtotal: subtotal,
      gst: gst,
      deliveryFee: deliveryFee,
      discount: discount,
      grandTotal: grandTotal,
      appliedCoupon: coupon,
      deliveryAddress: address,
      paymentMethodLabel: '${payment.title} (${payment.subtitle ?? payment.kind.name})',
      status: OrderStatus.accepted,
      estimatedDeliveryMinutes: 20,
      deliveryPartnerName: MockData.deliveryPartnerName,
      deliveryPartnerPhone: MockData.deliveryPartnerPhone,
      createdAt: DateTime.now(),
    );

    _localOrders[orderId] = order;
    await SessionManager.instance.setActiveOrderId(orderId);

    if (FirebaseInitializer.isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .set(order.toMap());
      } catch (e) {
        debugPrint('Error placing order in Firestore: $e');
      }
    }

    _simulateOrderProgression(orderId);
    return order;
  }

  /// Real-time stream of an order by ID
  Stream<OrderModel?> streamOrder(String orderId) {
    if (FirebaseInitializer.isFirebaseReady) {
      return FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final order = OrderModel.fromMap(snapshot.data()!, id: snapshot.id);
          _localOrders[orderId] = order;
          return order;
        }
        return _localOrders[orderId];
      });
    }

    // Local stream fallback
    if (!_orderStreams.containsKey(orderId)) {
      _orderStreams[orderId] = StreamController<OrderModel>.broadcast();
    }
    final stream = _orderStreams[orderId]!;
    final current = _localOrders[orderId];
    if (current != null) {
      Future.microtask(() => stream.add(current));
    }
    return stream.stream;
  }

  /// Get order by ID
  Future<OrderModel?> getOrder(String orderId) async {
    if (FirebaseInitializer.isFirebaseReady) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .get();
        if (doc.exists && doc.data() != null) {
          return OrderModel.fromMap(doc.data()!, id: doc.id);
        }
      } catch (e) {
        debugPrint('Error getting order from Firestore: $e');
      }
    }
    return _localOrders[orderId];
  }

  /// Fetch user's orders for order history
  Future<List<OrderModel>> getUserOrders(String userId) async {
    if (FirebaseInitializer.isFirebaseReady) {
      try {
        final query = await FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();
        if (query.docs.isNotEmpty) {
          return query.docs
              .map((doc) => OrderModel.fromMap(doc.data(), id: doc.id))
              .toList();
        }
      } catch (e) {
        debugPrint('Error fetching user orders from Firestore: $e');
      }
    }

    return _localOrders.values
        .where((o) => o.userId == userId || userId.isEmpty || o.userId == 'usr_demo')
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Simulates realistic order step progression for interactive testing
  void _simulateOrderProgression(String orderId) {
    Timer(const Duration(seconds: 10), () {
      _updateStatusLocal(orderId, OrderStatus.taken, 12);
    });
    Timer(const Duration(seconds: 25), () {
      _updateStatusLocal(orderId, OrderStatus.outForDelivery, 5);
    });
    Timer(const Duration(seconds: 45), () {
      _updateStatusLocal(orderId, OrderStatus.delivered, 0);
    });
  }

  /// Updates delivery address for an active order in real-time
  Future<void> updateDeliveryAddress(String orderId, Address newAddress) async {
    final current = _localOrders[orderId];
    if (current != null) {
      final updated = current.copyWith(
        deliveryAddress: newAddress,
      );
      _localOrders[orderId] = updated;
      _orderStreams[orderId]?.add(updated);

      if (FirebaseInitializer.isFirebaseReady) {
        try {
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId)
              .update({'deliveryAddress': newAddress.toMap()});
        } catch (e) {
          debugPrint('Error updating delivery address in Firestore: $e');
        }
      }
    }
  }

  void _updateStatusLocal(String orderId, OrderStatus status, int eta) {
    final current = _localOrders[orderId];
    if (current != null) {
      final updated = current.copyWith(
        status: status,
        estimatedDeliveryMinutes: eta,
      );
      _localOrders[orderId] = updated;
      _orderStreams[orderId]?.add(updated);

      if (FirebaseInitializer.isFirebaseReady) {
        FirebaseFirestore.instance.collection('orders').doc(orderId).update({
          'status': status.name,
          'estimatedDeliveryMinutes': eta,
        }).catchError((_) {});
      }
    }
  }
}

