import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

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
    this.originTitle = 'PARAGON',
    this.originSubtitle = 'Restaurant',
  });

  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;
  final List<RoutePoint> points;
  final double totalDistanceKm;
  final int estimatedMinutes;
  final bool isLiveOsrm;
  final String originTitle;
  final String originSubtitle;

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

  /// Fetches or computes a route from the closest Paragon Restaurant to the given destination.
  Future<DeliveryRoute> getDeliveryRoute({
    required Address destination,
    double? customOriginLat,
    double? customOriginLng,
    String? customOriginTitle,
    String? customOriginSubtitle,
  }) async {
    final destLat = destination.lat;
    final destLng = destination.lng;

    final nearest = LocationService.instance.getNearestRestaurant(
      lat: destLat,
      lng: destLng,
    );

    final startLat = customOriginLat ?? nearest.lat;
    final startLng = customOriginLng ?? nearest.lng;
    final originTitle = customOriginTitle ?? nearest.name;
    final originSubtitle = customOriginSubtitle ?? nearest.branch;

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
        originTitle: originTitle,
        originSubtitle: originSubtitle,
      ).timeout(const Duration(milliseconds: 3500));

      _cache[cacheKey] = route;
      return route;
    } catch (_) {
      // Offline fallback: Generate smooth road geometry locally
      final fallbackRoute = _generateLocalRoute(
        startLat: startLat,
        startLng: startLng,
        destLat: destLat,
        destLng: destLng,
        destLabel: destination.label,
        originTitle: originTitle,
        originSubtitle: originSubtitle,
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
    required String originTitle,
    required String originSubtitle,
  }) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '$startLng,$startLat;$destLng,$destLat'
      '?overview=full&geometries=geojson&steps=false',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 4));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

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
            originTitle: originTitle,
            originSubtitle: originSubtitle,
          );
        }
      }
    }
    throw Exception('OSRM non-200 or invalid payload');
  }

  /// High-fidelity offline road network synthesizer for Calicut or any city.
  DeliveryRoute _generateLocalRoute({
    required double startLat,
    required double startLng,
    required double destLat,
    required double destLng,
    String? destLabel,
    required String originTitle,
    required String originSubtitle,
  }) {
    final straightDist = LocationService.instance.calculateDistanceKm(
      startLat: startLat,
      startLng: startLng,
      endLat: destLat,
      endLng: destLng,
    );

    final roadDistKm = double.parse((straightDist * 1.3).toStringAsFixed(1));
    final estimatedMins = math.max(8, (roadDistKm * 2.8).round());

    final isCalicut = (startLat >= 11.15 && startLat <= 11.35) &&
        (destLat >= 11.15 && destLat <= 11.35);

    final keyWaypoints = <RoutePoint>[];

    if (isCalicut) {
      keyWaypoints.addAll([
        RoutePoint(lat: startLat, lng: startLng, streetName: '$originTitle, $originSubtitle'),
        RoutePoint(
          lat: startLat - 0.0018,
          lng: startLng + 0.0055,
          streetName: 'CH Flyover / Mavoor Rd Junction',
        ),
        RoutePoint(
          lat: startLat + 0.0022,
          lng: startLng + 0.0175,
          streetName: 'Mavoor Road (Arayidathupalam)',
        ),
        RoutePoint(
          lat: startLat - 0.0058,
          lng: startLng + 0.0315,
          streetName: 'Mini Bypass Road',
        ),
        RoutePoint(
          lat: startLat - 0.0128,
          lng: startLng + 0.0425,
          streetName: 'NH 66 Bypass / Thondayad',
        ),
        RoutePoint(
          lat: destLat + 0.0016,
          lng: destLng - 0.0032,
          streetName: destLabel != null && destLabel.isNotEmpty
              ? '$destLabel Approach'
              : 'Hilite Mall Way',
        ),
        RoutePoint(lat: destLat, lng: destLng, streetName: destLabel ?? 'Customer Doorstep'),
      ]);
    } else {
      // Universal city urban corridor synthesizer (e.g. Bengaluru, Kochi, etc.)
      keyWaypoints.addAll([
        RoutePoint(lat: startLat, lng: startLng, streetName: '$originTitle ($originSubtitle)'),
        RoutePoint(
          lat: startLat + (destLat - startLat) * 0.22,
          lng: startLng + (destLng - startLng) * 0.18 + 0.0012,
          streetName: 'Commercial Arterial Corridor',
        ),
        RoutePoint(
          lat: startLat + (destLat - startLat) * 0.50,
          lng: startLng + (destLng - startLng) * 0.48 - 0.0015,
          streetName: 'Transit Ring Road',
        ),
        RoutePoint(
          lat: startLat + (destLat - startLat) * 0.78,
          lng: startLng + (destLng - startLng) * 0.82 + 0.0009,
          streetName: '${destLabel ?? 'Neighborhood'} Link Boulevard',
        ),
        RoutePoint(lat: destLat, lng: destLng, streetName: destLabel ?? 'Customer Doorstep'),
      ]);
    }

    // Smoothly interpolate sub-steps along the key junctions
    final points = <RoutePoint>[];
    for (int i = 0; i < keyWaypoints.length - 1; i++) {
      final pA = keyWaypoints[i];
      final pB = keyWaypoints[i + 1];
      const segmentSteps = 8;

      for (int s = 0; s < segmentSteps; s++) {
        final t = s / segmentSteps;
        final microBend = math.sin(t * math.pi) * 0.0006;
        final lat = pA.lat + (pB.lat - pA.lat) * t + microBend;
        final lng = pA.lng + (pB.lng - pA.lng) * t + (microBend * 0.5);

        points.add(
          RoutePoint(
            lat: lat,
            lng: lng,
            streetName: t > 0.5 ? pB.streetName : pA.streetName,
          ),
        );
      }
    }
    points.add(keyWaypoints.last);

    return DeliveryRoute(
      originLat: startLat,
      originLng: startLng,
      destLat: destLat,
      destLng: destLng,
      points: points,
      totalDistanceKm: roadDistKm,
      estimatedMinutes: estimatedMins,
      isLiveOsrm: false,
      originTitle: originTitle,
      originSubtitle: originSubtitle,
    );
  }
}
