import 'package:geolocator/geolocator.dart';

/// Native mobile GPS implementation using geolocator package.
/// Handles permission requests and returns high-accuracy coordinates.
Future<Map<String, double>?> getBrowserCoordinates() async {
  try {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Prompt user to enable location services
      await Geolocator.openLocationSettings();
      return null;
    }

    // Check and request permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, open app settings
      await Geolocator.openAppSettings();
      return null;
    }

    // Get current position with high accuracy
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );

    return {
      'lat': position.latitude,
      'lng': position.longitude,
    };
  } catch (_) {
    return null;
  }
}
