import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/data/mock_data.dart';
import 'package:restaurant_app/models/address.dart';
import 'package:restaurant_app/models/cart_item.dart';
import 'package:restaurant_app/models/order_model.dart';
import 'package:restaurant_app/models/takeaway_order.dart';
import 'package:restaurant_app/state/food_planner_controller.dart';
import 'package:restaurant_app/state/takeaway_controller.dart';

void main() {
  group('Takeaway Order Cancellation and Payment Details', () {
    test('TakeawayOrder supports cancellation state and payment method', () {
      final now = DateTime.now();
      final order = TakeawayOrder(
        id: 'TKO-TEST-101',
        userId: 'usr_test',
        restaurant: MockData.restaurants.first,
        items: [
          CartItem(
            dish: MockData.plainDosa,
            quantity: 2,
          ),
        ],
        createdAt: now,
        status: TakeawayStatus.preparing,
        paymentMethod: 'UPI - Google Pay',
        transactionId: 'TXN-998811',
      );

      expect(order.canBeCancelled, isTrue);
      expect(order.isCancelled, isFalse);
      expect(order.paymentMethod, equals('UPI - Google Pay'));
      expect(order.transactionId, equals('TXN-998811'));
      expect(order.formattedDate, isNotEmpty);
      expect(order.formattedTime, isNotEmpty);

      // Cancel order
      final cancelledOrder = order.copyWith(
        status: TakeawayStatus.cancelled,
        cancellationReason: 'Ordered by mistake',
        cancelledAt: now.add(const Duration(minutes: 2)),
      );

      expect(cancelledOrder.isCancelled, isTrue);
      expect(cancelledOrder.canBeCancelled, isFalse);
      expect(cancelledOrder.status, equals(TakeawayStatus.cancelled));
      expect(cancelledOrder.cancellationReason, equals('Ordered by mistake'));
      expect(cancelledOrder.cancelledAt, isNotNull);

      // Serialization round-trip
      final map = cancelledOrder.toMap();
      final fromMap = TakeawayOrder.fromMap(map, id: 'TKO-TEST-101');
      expect(fromMap.id, equals('TKO-TEST-101'));
      expect(fromMap.status, equals(TakeawayStatus.cancelled));
      expect(fromMap.cancellationReason, equals('Ordered by mistake'));
      expect(fromMap.paymentMethod, equals('UPI - Google Pay'));
      expect(fromMap.transactionId, equals('TXN-998811'));
    });

    test('TakeawayController places order with payment method and supports cancellation & reorder', () async {
      final ctrl = TakeawayController.instance;
      ctrl.clearCart();

      // Add items
      ctrl.add(MockData.plainDosa);
      ctrl.add(MockData.meals);
      expect(ctrl.totalQuantity, equals(2));

      // Place order with payment method
      final placed = await ctrl.placeOrder(
        restaurantOverride: MockData.restaurants.first,
        paymentMethod: 'Credit/Debit Card',
        transactionId: 'TXN-CARD-1234',
      );

      expect(placed.paymentMethod, equals('Credit/Debit Card'));
      expect(placed.transactionId, equals('TXN-CARD-1234'));
      expect(ctrl.totalQuantity, equals(0)); // Cart cleared

      // Cancel placed order
      await ctrl.cancelOrder(
        placed.id,
        reason: 'Change in schedule / plans',
      );

      final found = ctrl.orders.firstWhere((o) => o.id == placed.id);
      expect(found.isCancelled, isTrue);
      expect(found.cancellationReason, equals('Change in schedule / plans'));

      // Reorder items
      ctrl.reorder(found);
      expect(ctrl.totalQuantity, equals(2));
      expect(ctrl.cartItems.any((i) => i.dish.id == MockData.plainDosa.id), isTrue);
      expect(ctrl.cartItems.any((i) => i.dish.id == MockData.meals.id), isTrue);
      ctrl.clearCart();
    });
  });

  group('OrderModel (Delivery) Cancellation Support', () {
    test('OrderModel serialization and cancellation fields', () {
      final now = DateTime.now();
      final order = OrderModel(
        id: 'ORD-TEST-202',
        userId: 'usr_test',
        items: const [],
        subtotal: 250.0,
        discount: 0.0,
        deliveryFee: 30.0,
        gst: 12.5,
        grandTotal: 292.5,
        paymentMethodLabel: 'UPI',
        deliveryAddress: const Address(label: 'Home', details: '123 Main St'),
        status: OrderStatus.placed,
        createdAt: now,
      );

      expect(order.canBeCancelled, isTrue);
      expect(order.isCancelled, isFalse);

      final cancelled = order.copyWith(
        status: OrderStatus.cancelled,
        cancellationReason: 'Delivery address incorrect',
        cancelledAt: now.add(const Duration(minutes: 1)),
        refundStatus: 'Initiated to UPI',
      );

      expect(cancelled.isCancelled, isTrue);
      expect(cancelled.canBeCancelled, isFalse);
      expect(cancelled.cancellationReason, equals('Delivery address incorrect'));
      expect(cancelled.refundStatus, equals('Initiated to UPI'));

      final map = cancelled.toMap();
      final fromMap = OrderModel.fromMap(map, id: 'ORD-TEST-202');
      expect(fromMap.id, equals('ORD-TEST-202'));
      expect(fromMap.status, equals(OrderStatus.cancelled));
      expect(fromMap.cancellationReason, equals('Delivery address incorrect'));
      expect(fromMap.refundStatus, equals('Initiated to UPI'));
    });
  });

  group('Food Preparation Time & Dynamic Delivery / Takeaway Timeline', () {
    final chickenBiryani = MockData.dishes.firstWhere((d) => d.id == 'chicken_biriyani');

    test('Dishes have realistic preparation times configured', () {
      expect(MockData.plainDosa.prepTimeMinutes, equals(10));
      expect(MockData.meals.prepTimeMinutes, equals(20));
      expect(chickenBiryani.prepTimeMinutes, equals(25));
      expect(MockData.freshJuiceOrange.prepTimeMinutes, equals(5));
    });

    test('TakeawayOrder dynamically computes prep time and estimated ready time', () {
      final now = DateTime(2026, 9, 19, 12, 0);
      final order = TakeawayOrder(
        id: 'TKO-PREP-1',
        userId: 'usr_1',
        restaurant: MockData.restaurants.first,
        items: [
          CartItem(dish: MockData.plainDosa, quantity: 1), // 10m
          CartItem(dish: chickenBiryani, quantity: 1), // 25m
        ],
        createdAt: now,
        status: TakeawayStatus.preparing,
        paymentMethod: 'UPI - PhonePe',
      );

      // Total prep time is max(10, 25) = 25m
      expect(order.prepTimeMinutes, equals(25));
      expect(order.estimatedReadyAt, equals(now.add(const Duration(minutes: 25))));
      expect(order.formattedReadyTime, contains('12:25'));
    });

    test('OrderModel dynamically computes prep time, transit time, and estimated delivery timeline', () {
      final now = DateTime(2026, 9, 19, 12, 0);
      final order = OrderModel(
        id: 'ORD-PREP-1',
        userId: 'usr_1',
        items: const [],
        subtotal: 300,
        discount: 0,
        deliveryFee: 30,
        gst: 15,
        grandTotal: 345,
        paymentMethodLabel: 'Net Banking - HDFC Bank',
        deliveryAddress: const Address(label: 'Home', details: '123 Main St'),
        status: OrderStatus.placed,
        createdAt: now,
        prepTimeMinutes: 25,
        transitMinutes: 12,
        estimatedDeliveryMinutes: 37,
      );

      expect(order.prepTimeMinutes, equals(25));
      expect(order.transitMinutes, equals(12));
      expect(order.estimatedDeliveryMinutes, equals(37));
      expect(order.estimatedDeliveryAt, equals(now.add(const Duration(minutes: 37))));
      expect(order.formattedEstimatedDeliveryTime, contains('12:37'));
    });

    test('Takeaway supports multiple payment methods (UPI, Cards, Net Banking, Pay at Counter)', () async {
      final ctrl = TakeawayController.instance;

      for (final method in ['Google Pay', 'Credit Card (*2453)', 'Net Banking (SBI)', 'Pay at Counter']) {
        ctrl.clearCart();
        ctrl.add(MockData.plainDosa);

        final order = await ctrl.placeOrder(
          paymentMethod: method,
          transactionId: 'TXN-$method',
        );

        expect(order.paymentMethod, equals(method));
        expect(order.prepTimeMinutes, greaterThanOrEqualTo(10));
        expect(order.formattedReadyTime, isNotEmpty);
      }
      ctrl.clearCart();
    });
  });

  group('Dynamic Real-Time Calendar Date Support', () {
    test('FoodPlannerController formats dynamic selectedDate correctly', () {
      final ctrl = FoodPlannerController.instance;
      ctrl.selectDay(0);
      final now = DateTime.now();
      expect(ctrl.selectedDate.year, equals(now.year));
      expect(ctrl.selectedDate.month, equals(now.month));
      expect(ctrl.selectedDate.day, equals(now.day));
      expect(ctrl.formattedSelectedDate, contains('${now.year}'));

      ctrl.selectDay(1); // tomorrow
      final tomorrow = now.add(const Duration(days: 1));
      expect(ctrl.selectedDate.day, equals(tomorrow.day));
    });
  });
}
