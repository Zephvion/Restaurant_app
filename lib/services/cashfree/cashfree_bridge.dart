import 'cashfree_bridge_stub.dart'
    if (dart.library.html) 'cashfree_bridge_web.dart';

abstract class CashfreeBridge {
  static Future<Map<String, dynamic>> openCheckout({
    required String paymentSessionId,
    required bool isSandbox,
  }) {
    return CashfreePlatformBridge.openCheckout(
      paymentSessionId: paymentSessionId,
      isSandbox: isSandbox,
    );
  }
}
