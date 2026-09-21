import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;

class CashfreePlatformBridge {
  static Future<Map<String, dynamic>> openCheckout({
    required String paymentSessionId,
    required bool isSandbox,
  }) {
    final completer = Completer<Map<String, dynamic>>();
    final callbackName = 'cf_cb_${DateTime.now().millisecondsSinceEpoch}';

    js.context[callbackName] = (String resultJson) {
      try {
        final data = jsonDecode(resultJson) as Map<String, dynamic>;
        if (!completer.isCompleted) {
          completer.complete(data);
        }
      } catch (e) {
        if (!completer.isCompleted) {
          completer.complete({'status': 'error', 'error': e.toString()});
        }
      } finally {
        js.context.deleteProperty(callbackName);
      }
    };

    try {
      js.context.callMethod('openCashfreeCheckout', [paymentSessionId, isSandbox, callbackName]);
    } catch (e) {
      js.context.deleteProperty(callbackName);
      if (!completer.isCompleted) {
        completer.complete({'status': 'error', 'error': e.toString()});
      }
    }

    return completer.future;
  }
}
