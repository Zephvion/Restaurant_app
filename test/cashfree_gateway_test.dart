import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/models/payment_method.dart';
import 'package:restaurant_app/services/cashfree/cashfree_config.dart';
import 'package:restaurant_app/services/cashfree_gateway_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CashfreeGatewayService Tests', () {
    final service = CashfreeGatewayService.instance;

    test('Maps bank names to valid Cashfree codes', () {
      expect(CashfreeGatewayService.bankCodeMap['hdfc bank'], equals('HDFC'));
      expect(CashfreeGatewayService.bankCodeMap['state bank of india'], equals('SBIN'));
      expect(CashfreeGatewayService.bankCodeMap['icici bank'], equals('ICIC'));
      expect(CashfreeGatewayService.bankCodeMap['axis bank'], equals('UTIB'));
    });

    test('Validates Cashfree Config endpoints and sandbox mode', () {
      expect(CashfreeConfig.apiVersion, equals('2023-08-01'));
      expect(CashfreeConfig.sandboxBaseUrl, contains('sandbox.cashfree.com'));
      expect(CashfreeConfig.productionBaseUrl, contains('api.cashfree.com'));
      expect(CashfreeConfig.isSandbox, isTrue);
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
      expect(result.paymentMode, contains('Netbanking'));
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
