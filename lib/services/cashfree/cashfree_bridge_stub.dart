class CashfreePlatformBridge {
  static Future<Map<String, dynamic>> openCheckout({
    required String paymentSessionId,
    required bool isSandbox,
  }) async {
    // Stub implementation for non-web environments (mobile / test)
    await Future.delayed(const Duration(milliseconds: 600));
    return {
      'status': 'success',
      'paymentId': 'cf_pay_${DateTime.now().millisecondsSinceEpoch}',
      'orderId': 'cf_ord_${DateTime.now().millisecondsSinceEpoch}',
    };
  }
}
