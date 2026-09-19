// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;

Future<Map<String, double>?> getBrowserCoordinates() async {
  try {
    final completer = Completer<Map<String, double>?>();
    html.window.navigator.geolocation.getCurrentPosition(
      enableHighAccuracy: true,
      timeout: const Duration(seconds: 5),
      maximumAge: const Duration(seconds: 30),
    ).then((pos) {
      final lat = pos.coords?.latitude?.toDouble();
      final lng = pos.coords?.longitude?.toDouble();
      if (lat != null && lng != null) {
        completer.complete({'lat': lat, 'lng': lng});
      } else {
        completer.complete(null);
      }
    }).catchError((_) {
      completer.complete(null);
    });
    return await completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );
  } catch (_) {
    return null;
  }
}
