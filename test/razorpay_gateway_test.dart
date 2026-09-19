import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/models/payment_method.dart';
import 'package:restaurant_app/services/razorpay_gateway_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RazorpayGatewayService Tests', () {
    final service = RazorpayGatewayService.instance;

    test('Maps bank names to valid Razorpay codes', () {
      expect(RazorpayGatewayService.bankCodeMap['hdfc bank'], equals('HDFC'));
      expect(RazorpayGatewayService.bankCodeMap['state bank of india'], equals('SBIN'));
      expect(RazorpayGatewayService.bankCodeMap['icici bank'], equals('ICIC'));
      expect(RazorpayGatewayService.bankCodeMap['axis bank'], equals('UTIB'));
    });

    test('Processes UPI payment and returns valid transaction result', () async {
      final result = await service.processPayment(
        amount: 250.0,
        kind: PaymentKind.upi,
        subMethod: 'PhonePe',
      );

      expect(result.success, isTrue);
      expect(result.paymentId, isNotNull);
      expect(result.paymentId!.isNotEmpty, isTrue);
      expect(result.paymentMode, contains('PhonePe'));
      
      final map = result.toMap();
      expect(map['txnId'], equals(result.paymentId));
      expect(map['mode'], equals(result.paymentMode));
    });

    test('Processes Card payment and returns valid transaction result', () async {
      final result = await service.processPayment(
        amount: 499.0,
        kind: PaymentKind.card,
        subMethod: 'HDFC VISA (*2453)',
        cardCvv: '789',
      );

      expect(result.success, isTrue);
      expect(result.paymentId, isNotNull);
      expect(result.paymentMode, contains('Card'));
    });

    test('Processes Net Banking payment with bank code', () async {
      final result = await service.processPayment(
        amount: 1200.0,
        kind: PaymentKind.netBanking,
        subMethod: 'State Bank of India',
      );

      expect(result.success, isTrue);
      expect(result.paymentId, isNotNull);
      expect(result.paymentMode, contains('Net Banking'));
    });

    test('Custom UPI ID VPA format handled properly', () async {
      final result = await service.processPayment(
        amount: 150.0,
        kind: PaymentKind.upi,
        customUpiId: 'testuser@okhdfcbank',
      );

      expect(result.success, isTrue);
      expect(result.paymentMode, contains('testuser@okhdfcbank'));
    });
  });
}
