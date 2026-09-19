import 'razorpay_bridge_stub.dart'
    if (dart.library.html) 'razorpay_bridge_web.dart';

abstract class RazorpayBridge {
  static Future<Map<String, dynamic>> openCheckout(
    Map<String, dynamic> options,
  ) {
    return RazorpayPlatformBridge.openCheckout(options);
  }
}
