import 'dart:async';

class RazorpayPlatformBridge {
  static Future<Map<String, dynamic>> openCheckout(
    Map<String, dynamic> options,
  ) async {
    return {
      'status': 'unsupported',
      'error': 'Web checkout not available on this platform',
    };
  }
}
