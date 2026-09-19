import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/address.dart';
import 'gps/browser_gps.dart';
import 'session_manager.dart';

/// Representation of a real live GPS fix and reverse-geocoded address.
class LiveLocationResult {
  const LiveLocationResult({
    required this.lat,
    required this.lng,
    required this.label,
    required this.details,
    required this.city,
    required this.state,
    required this.source,
  });

  final double lat;
  final double lng;
  final String label;
  final String details;
  final String city;
  final String state;
  final String source; // 'browser_gps', 'ip_network', or 'fallback'

  Address toAddress({String? id, bool isDefault = true}) {
    return Address(
      id: id ?? 'gps_${DateTime.now().millisecondsSinceEpoch}',
      label: label,
      details: details,
      lat: lat,
      lng: lng,
      isDefault: isDefault,
    );
  }
}

/// Service that acquires the user's authentic device or network location
/// and resolves the exact street, locality, and city using OpenStreetMap Nominatim.
class GpsDetectionService {
  GpsDetectionService._();
  static final GpsDetectionService instance = GpsDetectionService._();

  static LiveLocationResult? _lastDetected;
  LiveLocationResult? get lastDetected => _lastDetected;
  Address? get lastDetectedAddress => _lastDetected?.toAddress();

  /// Detects the user's real live coordinates and reverse-geocodes their address.
  Future<LiveLocationResult> detectLiveLocation() async {
    final result = await _detectInternal();
    _lastDetected = result;
    final selected = SessionManager.instance.getSelectedAddress();
    if (selected == null || selected.details.toLowerCase().contains('palazhi')) {
      final addr = result.toAddress();
      await SessionManager.instance.saveSelectedAddress(addr);
      await SessionManager.instance.setDeliveryArea(addr.label);
    }
    return result;
  }

  Future<LiveLocationResult> _detectInternal() async {
    // 1. Try High-Precision Browser / Device Geolocation first
    try {
      final browserCoords = await getBrowserCoordinates();
      if (browserCoords != null &&
          browserCoords['lat'] != null &&
          browserCoords['lng'] != null) {
        final lat = browserCoords['lat']!;
        final lng = browserCoords['lng']!;
        final geocoded = await _reverseGeocode(lat, lng);
        if (geocoded != null) {
          return LiveLocationResult(
            lat: lat,
            lng: lng,
            label: geocoded['label'] ?? 'Current Location',
            details: geocoded['details'] ??
                'GPS: ${lat.toStringAsFixed(4)}° N, ${lng.toStringAsFixed(4)}° E',
            city: geocoded['city'] ?? 'Bengaluru',
            state: geocoded['state'] ?? 'Karnataka',
            source: 'browser_gps',
          );
        }
        return LiveLocationResult(
          lat: lat,
          lng: lng,
          label: 'Live GPS Location',
          details:
              'Current GPS Position: ${lat.toStringAsFixed(4)}° N, ${lng.toStringAsFixed(4)}° E',
          city: 'Current Area',
          state: '',
          source: 'browser_gps',
        );
      }
    } catch (_) {
      // Continue to IP-based high-accuracy geolocation
    }

    // 2. High-Accuracy IP-based Geolocation Fallback
    try {
      final ipLocation = await _fetchIpLocation();
      if (ipLocation != null) {
        final lat = ipLocation['lat'] as double;
        final lng = ipLocation['lng'] as double;
        final city = ipLocation['city'] as String;
        final region = ipLocation['region'] as String;
        final zip = ipLocation['zip'] as String;

        // Try reverse-geocoding the IP coordinates for granular street details
        final geocoded = await _reverseGeocode(lat, lng);
        if (geocoded != null) {
          return LiveLocationResult(
            lat: lat,
            lng: lng,
            label: geocoded['label'] ?? city,
            details: geocoded['details'] ?? '$city, $region - $zip',
            city: geocoded['city'] ?? city,
            state: geocoded['state'] ?? region,
            source: 'ip_network',
          );
        }

        return LiveLocationResult(
          lat: lat,
          lng: lng,
          label: '$city, $region',
          details: '$city, $region - $zip (GPS: ${lat.toStringAsFixed(4)}° N, ${lng.toStringAsFixed(4)}° E)',
          city: city,
          state: region,
          source: 'ip_network',
        );
      }
    } catch (_) {
      // Continue to ultimate fallback
    }

    // 3. Ultimate Fallback (Calicut default)
    return const LiveLocationResult(
      lat: 11.2588,
      lng: 75.7804,
      label: 'Paragon, Calicut',
      details: 'Kannur Road, Near CH Flyover, Kozhikode, Kerala - 673011',
      city: 'Kozhikode',
      state: 'Kerala',
      source: 'fallback',
    );
  }

  /// Fetches IP-based location from open geolocation endpoints.
  Future<Map<String, dynamic>?> _fetchIpLocation() async {
    try {
      final uri = Uri.parse('http://ip-api.com/json');
      final resp = await http.get(uri).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        if (data['status'] == 'success') {
          return {
            'lat': (data['lat'] as num).toDouble(),
            'lng': (data['lon'] as num).toDouble(),
            'city': data['city'] ?? 'Bengaluru',
            'region': data['regionName'] ?? 'Karnataka',
            'zip': data['zip'] ?? '',
          };
        }
      }
    } catch (_) {
      // Try secondary endpoint
      try {
        final uri2 = Uri.parse('https://ipapi.co/json/');
        final resp2 = await http.get(uri2).timeout(const Duration(seconds: 4));
        if (resp2.statusCode == 200) {
          final data2 = jsonDecode(resp2.body) as Map<String, dynamic>;
          if (data2['latitude'] != null && data2['longitude'] != null) {
            return {
              'lat': (data2['latitude'] as num).toDouble(),
              'lng': (data2['longitude'] as num).toDouble(),
              'city': data2['city'] ?? 'Bengaluru',
              'region': data2['region'] ?? 'Karnataka',
              'zip': data2['postal'] ?? '',
            };
          }
        }
      } catch (_) {}
    }
    return null;
  }

  /// Reverse-geocodes coordinates to a real address using OpenStreetMap Nominatim.
  Future<Map<String, String>?> _reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );
      final resp = await http.get(
        uri,
        headers: {'User-Agent': 'ParagonRestaurantApp/1.0'},
      ).timeout(const Duration(seconds: 4));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;

        final road = address?['road'] as String?;
        final suburb = address?['suburb'] as String? ??
            address?['neighbourhood'] as String? ??
            address?['residential'] as String?;
        final city = address?['city'] as String? ??
            address?['town'] as String? ??
            address?['county'] as String? ??
            'Bengaluru';
        final state = address?['state'] as String? ?? 'Karnataka';
        final postcode = address?['postcode'] as String? ?? '';

        final labelParts = <String>[];
        if (suburb != null && suburb.isNotEmpty) labelParts.add(suburb);
        if (city.isNotEmpty && !labelParts.contains(city)) labelParts.add(city);
        final label = labelParts.isNotEmpty ? labelParts.join(', ') : city;

        final detailParts = <String>[];
        if (road != null && road.isNotEmpty) detailParts.add(road);
        if (suburb != null && suburb.isNotEmpty && suburb != road) {
          detailParts.add(suburb);
        }
        if (city.isNotEmpty) detailParts.add(city);
        if (state.isNotEmpty) detailParts.add(state);

        var details = detailParts.join(', ');
        if (postcode.isNotEmpty) details = '$details - $postcode';

        return {
          'label': label,
          'details': details,
          'city': city,
          'state': state,
        };
      }
    } catch (_) {}
    return null;
  }
}
