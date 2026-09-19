import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class RazorpayPlatformBridge {
  static Future<Map<String, dynamic>> openCheckout(
    Map<String, dynamic> options,
  ) {
    final completer = Completer<Map<String, dynamic>>();
    final callbackName = 'rzp_cb_${DateTime.now().millisecondsSinceEpoch}';

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
      final jsonString = jsonEncode(options);
      js.context.callMethod('openRazorpayCheckout', [jsonString, callbackName]);
    } catch (e) {
      js.context.deleteProperty(callbackName);
      if (!completer.isCompleted) {
        completer.complete({'status': 'error', 'error': e.toString()});
      }
    }

    return completer.future;
  }
}
