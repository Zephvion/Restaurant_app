import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('openCashfreeCheckout')
external void _openCashfreeCheckout(
  JSString paymentSessionId,
  JSBoolean isSandbox,
  JSString callbackName,
);

class CashfreePlatformBridge {
  static Future<Map<String, dynamic>> openCheckout({
    required String paymentSessionId,
    required bool isSandbox,
  }) {
    final completer = Completer<Map<String, dynamic>>();
    final callbackName = 'cf_cb_${DateTime.now().millisecondsSinceEpoch}';

    void callback(JSString resultJson) {
      try {
        final data =
            jsonDecode(resultJson.toDart) as Map<String, dynamic>;
        if (!completer.isCompleted) {
          completer.complete(data);
        }
      } catch (e) {
        if (!completer.isCompleted) {
          completer.complete({'status': 'error', 'error': e.toString()});
        }
      } finally {
        _deleteGlobalProperty(callbackName);
      }
    }

    _setGlobalProperty(callbackName, callback.toJS);

    try {
      _openCashfreeCheckout(
        paymentSessionId.toJS,
        isSandbox.toJS,
        callbackName.toJS,
      );
    } catch (e) {
      _deleteGlobalProperty(callbackName);
      if (!completer.isCompleted) {
        completer.complete({'status': 'error', 'error': e.toString()});
      }
    }

    return completer.future;
  }

  static void _setGlobalProperty(String name, JSAny value) {
    globalContext.setProperty(name.toJS, value);
  }

  static void _deleteGlobalProperty(String name) {
    globalContext.delete(name.toJS);
  }
}
