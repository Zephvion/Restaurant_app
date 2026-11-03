import 'dart:math';
import '../data/mock_data.dart';
import '../models/address.dart';
import '../models/restaurant.dart';
import 'gps_detection_service.dart';
import 'session_manager.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  // Default fallback coordinates (Bengaluru active city default)
  static const double defaultLat = 12.9753;
  static const double defaultLng = 77.5910;

  // Calicut legacy coordinates
  static const double restaurantLat = 11.2588;
  static const double restaurantLng = 75.7804;

  String get currentDeliveryArea => SessionManager.instance.deliveryArea;

  Future<void> updateDeliveryArea(String area) async {
    await SessionManager.instance.setDeliveryArea(area);
  }

  /// Returns the detected city based on user's active address or live GPS proximity.
  String get detectedCity {
    final userAddr = SessionManager.instance.getSelectedAddress() ??
        GpsDetectionService.instance.lastDetectedAddress;
    final text = '${userAddr?.label} ${userAddr?.details}'.toLowerCase();

    if (text.contains('bengaluru') ||
        text.contains('bangalore') ||
        text.contains('karnataka')) {
      return 'Bengaluru';
    } else if (text.contains('kochi') ||
        text.contains('cochin') ||
        text.contains('ernakulam')) {
      return 'Kochi';
    } else if (text.contains('trivandrum') ||
        text.contains('thiruvananthapuram')) {
      return 'Trivandrum';
    } else if (text.contains('calicut') || text.contains('kozhikode')) {
      return 'Calicut';
    }

    final lat = userAddr?.lat ?? defaultLat;
    final lng = userAddr?.lng ?? defaultLng;
    return getNearestRestaurant(lat: lat, lng: lng).city;
  }

  /// Returns the detected state for the detected city.
  String get detectedState {
    final city = detectedCity;
    if (city.toLowerCase() == 'bengaluru') return 'Karnataka';
    return 'Kerala';
  }

  /// Returns user coordinates (lat, lng)
  Map<String, double> get userCoordinates {
    final userAddr = SessionManager.instance.getSelectedAddress() ??
        GpsDetectionService.instance.lastDetectedAddress;
    return {
      'lat': userAddr?.lat ?? defaultLat,
      'lng': userAddr?.lng ?? defaultLng,
    };
  }

  /// Finds the closest Paragon restaurant outlet to the given coordinates.
  Restaurant getNearestRestaurant({
    required double lat,
    required double lng,
    String? preferredCity,
  }) {
    const list = MockData.restaurants;
    if (list.isEmpty) {
      return const Restaurant(
        id: 'default_paragon',
        name: 'Paragon Restaurant',
        address: 'Kannur road',
        city: 'Calicut',
        lat: restaurantLat,
        lng: restaurantLng,
      );
    }

    // If preferred city is specified, prioritize outlets in that city
    if (preferredCity != null && preferredCity.isNotEmpty) {
      final inCity = list
          .where((r) => r.city.toLowerCase() == preferredCity.toLowerCase())
          .toList();
      if (inCity.isNotEmpty) {
        inCity.sort((a, b) {
          final distA = calculateDistanceKm(
              startLat: lat, startLng: lng, endLat: a.lat, endLng: a.lng);
          final distB = calculateDistanceKm(
              startLat: lat, startLng: lng, endLat: b.lat, endLng: b.lng);
          return distA.compareTo(distB);
        });
        return inCity.first;
      }
    }

    Restaurant nearest = list.first;
    double minDistance = double.infinity;

    for (final r in list) {
      final d = calculateDistanceKm(
        startLat: lat,
        startLng: lng,
        endLat: r.lat,
        endLng: r.lng,
      );
      if (d < minDistance) {
        minDistance = d;
        nearest = r;
      }
    }

    return nearest;
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

  /// Distance from the user's location to the given restaurant branch
  double getDistanceToRestaurant(
    Restaurant r, {
    double? userLat,
    double? userLng,
  }) {
    final addr = SessionManager.instance.getSelectedAddress() ??
        GpsDetectionService.instance.lastDetectedAddress;
    final activeLat = userLat ?? addr?.lat ?? defaultLat;
    final activeLng = userLng ?? addr?.lng ?? defaultLng;
    return calculateDistanceKm(
      startLat: activeLat,
      startLng: activeLng,
      endLat: r.lat,
      endLng: r.lng,
    );
  }

  /// Estimates delivery fee dynamically based on distance from the closest outlet
  double calculateDeliveryFee(Address destination) {
    final nearest =
        getNearestRestaurant(lat: destination.lat, lng: destination.lng);
    final dist = calculateDistanceKm(
      startLat: nearest.lat,
      startLng: nearest.lng,
      endLat: destination.lat,
      endLng: destination.lng,
    );
    if (dist <= 3.0) return 20.0;
    if (dist <= 8.0) return 30.0;
    return (30.0 + (dist - 8.0) * 5.0).roundToDouble();
  }
}
