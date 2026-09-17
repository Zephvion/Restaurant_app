import 'dart:math';
import '../models/address.dart';
import 'session_manager.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  // Restaurant default coordinates (Calicut, Kerala)
  static const double restaurantLat = 11.2588;
  static const double restaurantLng = 75.7804;

  String get currentDeliveryArea => SessionManager.instance.deliveryArea;

  Future<void> updateDeliveryArea(String area) async {
    await SessionManager.instance.setDeliveryArea(area);
  }

  /// Calculates straight-line distance in kilometers between two coordinates
  double calculateDistanceKm({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((endLat - startLat) * p) / 2 +
        cos(startLat * p) *
            cos(endLat * p) *
            (1 - cos((endLng - startLng) * p)) /
            2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  /// Estimates delivery fee based on distance
  double calculateDeliveryFee(Address destination) {
    final dist = calculateDistanceKm(
      startLat: restaurantLat,
      startLng: restaurantLng,
      endLat: destination.lat,
      endLng: destination.lng,
    );
    if (dist <= 3.0) return 20.0;
    if (dist <= 8.0) return 30.0;
    return (30.0 + (dist - 8.0) * 5.0).roundToDouble();
  }
}

