import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<Map<String, double>?> getBrowserCoordinates() async {
  try {
    final completer = Completer<Map<String, double>?>();

    void onSuccess(web.GeolocationPosition pos) {
      final lat = pos.coords.latitude;
      final lng = pos.coords.longitude;
      completer.complete({'lat': lat, 'lng': lng});
    }

    void onError(web.GeolocationPositionError err) {
      completer.complete(null);
    }

    final options = web.PositionOptions(
      enableHighAccuracy: true,
      timeout: 8000,
      maximumAge: 30000,
    );

    web.window.navigator.geolocation.getCurrentPosition(
      onSuccess.toJS,
      onError.toJS,
      options,
    );

    return await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => null,
    );
  } catch (_) {
    return null;
  }
}
