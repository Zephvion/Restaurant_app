import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import '../models/address.dart';
import 'location_service.dart';

/// A single GPS coordinate waypoint along a route.
class RoutePoint {
  const RoutePoint({
    required this.lat,
    required this.lng,
    this.streetName,
  });

  final double lat;
  final double lng;
  final String? streetName;

  Map<String, dynamic> toMap() => {
        'lat': lat,
        'lng': lng,
        'streetName': streetName,
      };
}

/// Dynamic delivery vehicle telemetry at a specific progress point.
class RoutePosition {
  const RoutePosition({
    required this.lat,
    required this.lng,
    required this.bearingDegrees,
    required this.distanceRemainingKm,
    required this.distanceCoveredKm,
    required this.speedKmh,
    this.currentStreet = 'On Route',
  });

  final double lat;
  final double lng;
  final double bearingDegrees;
  final double distanceRemainingKm;
  final double distanceCoveredKm;
  final double speedKmh;
  final String currentStreet;
}

/// A complete driving delivery route with geometry, distance, and duration.
class DeliveryRoute {
  const DeliveryRoute({
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    required this.points,
    required this.totalDistanceKm,
    required this.estimatedMinutes,
    required this.isLiveOsrm,
  });

  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;
  final List<RoutePoint> points;
  final double totalDistanceKm;
  final int estimatedMinutes;
  final bool isLiveOsrm;

  /// Interpolates the exact vehicle position, heading, and telemetry at progress `t` [0.0 to 1.0].
  RoutePosition getPositionAtProgress(double t) {
    if (points.isEmpty) {
      return RoutePosition(
        lat: originLat,
        lng: originLng,
        bearingDegrees: 0,
        distanceRemainingKm: totalDistanceKm,
        distanceCoveredKm: 0,
        speedKmh: 0,
      );
    }

    final clampedT = t.clamp(0.0, 1.0);
    if (clampedT >= 1.0 || points.length == 1) {
      final last = points.last;
      return RoutePosition(
        lat: last.lat,
        lng: last.lng,
        bearingDegrees: 0,
        distanceRemainingKm: 0,
        distanceCoveredKm: totalDistanceKm,
        speedKmh: 0,
        currentStreet: last.streetName ?? 'Destination Reached',
      );
    }

    // Total route distance and segment distance indexing
    final indexProgress = clampedT * (points.length - 1);
    final idx = indexProgress.floor();
    final remainder = indexProgress - idx;

    final p1 = points[idx];
    final p2 = points[math.min(idx + 1, points.length - 1)];

    // Linear interpolation between the two adjacent waypoints
    final curLat = p1.lat + (p2.lat - p1.lat) * remainder;
    final curLng = p1.lng + (p2.lng - p1.lng) * remainder;

    // Calculate heading angle in degrees (bearing)
    final dLng = (p2.lng - p1.lng) * (math.pi / 180.0);
    final lat1Rad = p1.lat * (math.pi / 180.0);
    final lat2Rad = p2.lat * (math.pi / 180.0);

    final y = math.sin(dLng) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLng);
    final initialBearingRad = math.atan2(y, x);
    final bearingDeg = (initialBearingRad * (180.0 / math.pi) + 360.0) % 360.0;

    final covered = totalDistanceKm * clampedT;
    final remaining = math.max(0.0, totalDistanceKm - covered);

    // Realistic delivery scooter speed (22-38 km/h depending on traffic)
    final speed = (clampedT >= 0.98 || clampedT <= 0.02)
        ? 0.0
        : 26.0 + (math.sin(clampedT * math.pi * 6) * 6.0);

    return RoutePosition(
      lat: curLat,
      lng: curLng,
      bearingDegrees: bearingDeg,
      distanceRemainingKm: remaining,
      distanceCoveredKm: covered,
      speedKmh: speed,
      currentStreet: p1.streetName ?? 'Mavoor Road Corridor',
    );
  }
}

/// Service providing OSRM online road routing and intelligent local Calicut fallback.
class MapRouteService {
  MapRouteService._();
  static final MapRouteService instance = MapRouteService._();

  static const double restaurantLat = LocationService.restaurantLat;
  static const double restaurantLng = LocationService.restaurantLng;

  // In-memory route cache to eliminate redundant network hits
  final Map<String, DeliveryRoute> _cache = {};

  /// Fetches or computes a route from Paragon Restaurant to the given destination.
  Future<DeliveryRoute> getDeliveryRoute({
    required Address destination,
    double? customOriginLat,
    double? customOriginLng,
  }) async {
    final startLat = customOriginLat ?? restaurantLat;
    final startLng = customOriginLng ?? restaurantLng;
    final destLat = destination.lat;
    final destLng = destination.lng;

    final cacheKey =
        '${startLat.toStringAsFixed(4)},${startLng.toStringAsFixed(4)}->${destLat.toStringAsFixed(4)},${destLng.toStringAsFixed(4)}';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final route = await _fetchOsrmRoute(
        startLat: startLat,
        startLng: startLng,
        destLat: destLat,
        destLng: destLng,
      ).timeout(const Duration(milliseconds: 3500));

      _cache[cacheKey] = route;
      return route;
    } catch (_) {
      // Offline fallback: Generate smooth Calicut road geometry locally
      final fallbackRoute = _generateLocalCalicutRoute(
        startLat: startLat,
        startLng: startLng,
        destLat: destLat,
        destLng: destLng,
        destLabel: destination.label,
      );
      _cache[cacheKey] = fallbackRoute;
      return fallbackRoute;
    }
  }

  /// Queries the open-source OSRM driving routing service.
  Future<DeliveryRoute> _fetchOsrmRoute({
    required double startLat,
    required double startLng,
    required double destLat,
    required double destLng,
  }) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '$startLng,$startLat;$destLng,$destLat'
      '?overview=full&geometries=geojson&steps=false',
    );

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 3);

    try {
      final request = await client.getUrl(url);
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body) as Map<String, dynamic>;

        if (data['code'] == 'Ok' && (data['routes'] as List).isNotEmpty) {
          final firstRoute = (data['routes'] as List).first as Map<String, dynamic>;
          final double distanceMeters = (firstRoute['distance'] as num).toDouble();
          final double durationSeconds = (firstRoute['duration'] as num).toDouble();

          final geometry = firstRoute['geometry'] as Map<String, dynamic>;
          final coordsList = geometry['coordinates'] as List;

          final points = <RoutePoint>[];
          for (final coord in coordsList) {
            final c = coord as List;
            points.add(
              RoutePoint(
                lng: (c[0] as num).toDouble(),
                lat: (c[1] as num).toDouble(),
              ),
            );
          }

          if (points.isNotEmpty) {
            final distKm = (distanceMeters / 1000.0);
            final mins = math.max(6, (durationSeconds / 60.0).round());

            return DeliveryRoute(
              originLat: startLat,
              originLng: startLng,
              destLat: destLat,
              destLng: destLng,
              points: points,
              totalDistanceKm: double.parse(distKm.toStringAsFixed(1)),
              estimatedMinutes: mins,
              isLiveOsrm: true,
            );
          }
        }
      }
      throw Exception('OSRM non-200 or invalid payload');
    } finally {
      client.close();
    }
  }

  /// High-fidelity offline Calicut road network synthesizer.
  DeliveryRoute _generateLocalCalicutRoute({
    required double startLat,
    required double startLng,
    required double destLat,
    required double destLng,
    String? destLabel,
  }) {
    final straightDist = LocationService.instance.calculateDistanceKm(
      startLat: startLat,
      startLng: startLng,
      endLat: destLat,
      endLng: destLng,
    );

    // Driving distance on roads is roughly 1.25x straight-line distance
    final roadDistKm = double.parse((straightDist * 1.25).toStringAsFixed(1));
    final estimatedMins = math.max(8, (roadDistKm * 2.6).round());

    // Generate 32 realistic road curve waypoints between start and end
    final points = <RoutePoint>[];
    const steps = 32;

    // Road curve offsets simulating Calicut's Mavoor Rd -> Mini Bypass -> Cyberpark bends
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      // Perpendicular sinusoidal bend for natural road geometry
      final bend = math.sin(t * math.pi) * 0.008;
      final lat = startLat + (destLat - startLat) * t + (bend * 0.6);
      final lng = startLng + (destLng - startLng) * t + bend;

      String street = 'Mavoor Road';
      if (t > 0.65) {
        street = destLabel != null && destLabel.isNotEmpty
            ? '$destLabel Road'
            : 'Hilite Mall Way';
      } else if (t > 0.3) {
        street = 'Arayidathupalam Bypass';
      }

      points.add(RoutePoint(lat: lat, lng: lng, streetName: street));
    }

    return DeliveryRoute(
      originLat: startLat,
      originLng: startLng,
      destLat: destLat,
      destLng: destLng,
      points: points,
      totalDistanceKm: roadDistKm,
      estimatedMinutes: estimatedMins,
      isLiveOsrm: false,
    );
  }
}
