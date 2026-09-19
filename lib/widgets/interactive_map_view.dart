import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/address.dart';
import '../services/map_route_service.dart';
import '../theme/app_colors.dart';

/// Display styles for the real map tile layer.
enum MapStyle {
  streets,
  darkLuxury,
}

/// Spherical Web Mercator projection (EPSG:3857) utility.
/// Converts real GPS coordinates to pixel coordinates matching standard slippy tiles.
class MercatorProjection {
  static const double tileSize = 256.0;

  /// World pixel X at given zoom level [0..20].
  static double lngToPixelX(double lng, double zoom) {
    return ((lng + 180.0) / 360.0) * tileSize * math.pow(2.0, zoom);
  }

  /// World pixel Y at given zoom level [0..20].
  static double latToPixelY(double lat, double zoom) {
    final sinLat = math.sin(lat * math.pi / 180.0).clamp(-0.9999, 0.9999);
    final y = 0.5 - math.log((1.0 + sinLat) / (1.0 - sinLat)) / (4.0 * math.pi);
    return y * tileSize * math.pow(2.0, zoom);
  }

  /// Converts world pixel X back to longitude.
  static double pixelXToLng(double x, double zoom) {
    return (x / (tileSize * math.pow(2.0, zoom))) * 360.0 - 180.0;
  }

  /// Converts world pixel Y back to latitude.
  static double pixelYToLat(double y, double zoom) {
    final yNorm = 0.5 - (y / (tileSize * math.pow(2.0, zoom)));
    return 90.0 - 360.0 * math.atan(math.exp(-yNorm * 2.0 * math.pi)) / math.pi;
  }

  /// Converts a GPS coordinate to screen offset given the map center, screen dimensions, and zoom.
  static Offset latLngToScreenOffset({
    required double lat,
    required double lng,
    required double centerLat,
    required double centerLng,
    required double zoom,
    required double screenWidth,
    required double screenHeight,
    double verticalCenterBias = 0.0,
  }) {
    final worldX = lngToPixelX(lng, zoom);
    final worldY = latToPixelY(lat, zoom);
    final centerWorldX = lngToPixelX(centerLng, zoom);
    final centerWorldY = latToPixelY(centerLat, zoom);

    final screenX = (screenWidth / 2.0) + (worldX - centerWorldX);
    final screenY = (screenHeight / 2.0) + (worldY - centerWorldY) + verticalCenterBias;

    return Offset(screenX, screenY);
  }

  /// Converts a screen touch offset back to real GPS coordinate.
  static ({double lat, double lng}) screenOffsetToLatLng({
    required Offset screenOffset,
    required double centerLat,
    required double centerLng,
    required double zoom,
    required double screenWidth,
    required double screenHeight,
    double verticalCenterBias = 0.0,
  }) {
    final centerWorldX = lngToPixelX(centerLng, zoom);
    final centerWorldY = latToPixelY(centerLat, zoom);

    final worldX = centerWorldX + (screenOffset.dx - (screenWidth / 2.0));
    final worldY = centerWorldY + (screenOffset.dy - (screenHeight / 2.0) - verticalCenterBias);

    final lng = pixelXToLng(worldX, zoom);
    final lat = pixelYToLat(worldY, zoom);

    return (lat: lat, lng: lng);
  }
}

/// An authentic, high-performance real map canvas for live delivery tracking
/// and interactive GPS location selection, powered by CartoDB Voyager / Dark Matter
/// real street map tiles, Zomato/Swiggy-style route polylines, and live vehicle telemetry.
class InteractiveMapView extends StatefulWidget {
  const InteractiveMapView({
    super.key,
    required this.destination,
    this.customOriginLat,
    this.customOriginLng,
    this.originTitle,
    this.originSubtitle,
    this.progress = 0.45,
    this.isSelectingLocation = false,
    this.onLocationPicked,
    this.showControls = true,
    this.showTelemetry = true,
  });

  /// The target customer delivery address.
  final Address destination;

  /// Optional custom origin latitude (e.g. from selected/nearest restaurant).
  final double? customOriginLat;

  /// Optional custom origin longitude.
  final double? customOriginLng;

  /// Custom origin display title (e.g. 'PARAGON').
  final String? originTitle;

  /// Custom origin display subtitle (e.g. 'Brigade Road').
  final String? originSubtitle;

  /// Delivery progress from 0.0 (restaurant origin) to 1.0 (destination doorstep).
  final double progress;

  /// When true, enables tap-to-pin live location picking mode.
  final bool isSelectingLocation;

  /// Callback when a location is tapped or dragged in selection mode.
  final ValueChanged<Address>? onLocationPicked;

  /// Whether to render floating map controls (zoom in/out, re-center).
  final bool showControls;

  /// Whether to render live vehicle telemetry pill (speed, distance remaining).
  final bool showTelemetry;

  @override
  State<InteractiveMapView> createState() => _InteractiveMapViewState();
}

class _InteractiveMapViewState extends State<InteractiveMapView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  DeliveryRoute? _route;
  bool _isLoadingRoute = true;
  Address? _currentDestination;
  MapStyle _mapStyle = MapStyle.streets;

  // Manual pan and zoom state
  Offset _panOffset = Offset.zero;
  double? _userZoom;
  bool _focusOnRider = false;

  @override
  void initState() {
    super.initState();
    _currentDestination = widget.destination;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _route = MapRouteService.instance.getImmediateRoute(
      destination: widget.destination,
      customOriginLat: widget.customOriginLat,
      customOriginLng: widget.customOriginLng,
      customOriginTitle: widget.originTitle,
      customOriginSubtitle: widget.originSubtitle,
    );
    _loadRoute();
  }

  @override
  void didUpdateWidget(covariant InteractiveMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destination.lat != widget.destination.lat ||
        oldWidget.destination.lng != widget.destination.lng ||
        oldWidget.customOriginLat != widget.customOriginLat ||
        oldWidget.customOriginLng != widget.customOriginLng ||
        oldWidget.originTitle != widget.originTitle) {
      _currentDestination = widget.destination;
      _panOffset = Offset.zero;
      _loadRoute();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadRoute() async {
    setState(() => _isLoadingRoute = true);
    final route = await MapRouteService.instance.getDeliveryRoute(
      destination: _currentDestination ?? widget.destination,
      customOriginLat: widget.customOriginLat,
      customOriginLng: widget.customOriginLng,
      customOriginTitle: widget.originTitle,
      customOriginSubtitle: widget.originSubtitle,
    );
    if (mounted) {
      setState(() {
        _route = route;
        _isLoadingRoute = false;
      });
    }
  }

  void _zoomIn() {
    setState(() {
      final current = _userZoom ?? 14.0;
      _userZoom = (current + 1.0).clamp(10.0, 18.0);
    });
  }

  void _zoomOut() {
    setState(() {
      final current = _userZoom ?? 14.0;
      _userZoom = (current - 1.0).clamp(10.0, 18.0);
    });
  }

  void _resetView() {
    setState(() {
      _panOffset = Offset.zero;
      _userZoom = null;
      _focusOnRider = false;
    });
  }

  void _toggleRiderFocus() {
    setState(() {
      _focusOnRider = !_focusOnRider;
      _panOffset = Offset.zero;
    });
  }

  void _toggleMapStyle() {
    setState(() {
      _mapStyle = _mapStyle == MapStyle.streets
          ? MapStyle.darkLuxury
          : MapStyle.streets;
    });
  }

  /// Calculates the optimal center and zoom level to perfectly frame the route and leave room for the bottom sheet.
  ({double centerLat, double centerLng, double zoom, double verticalBias})
      _computeMapViewport(double width, double height) {
    final dest = _currentDestination ?? widget.destination;

    // In location selection mode, zoom in close to the target doorstep
    if (widget.isSelectingLocation || _route == null) {
      final z = _userZoom ?? 15.5;
      return (
        centerLat: dest.lat,
        centerLng: dest.lng,
        zoom: z,
        verticalBias: 0.0,
      );
    }

    final route = _route!;
    final position = route.getPositionAtProgress(widget.progress);

    if (_focusOnRider) {
      final z = _userZoom ?? 15.0;
      return (
        centerLat: position.lat,
        centerLng: position.lng,
        zoom: z,
        verticalBias: -30.0,
      );
    }

    // Compute bounding box covering origin, destination, and all road waypoints
    double minLat = math.min(route.originLat, route.destLat);
    double maxLat = math.max(route.originLat, route.destLat);
    double minLng = math.min(route.originLng, route.destLng);
    double maxLng = math.max(route.originLng, route.destLng);

    for (final p in route.points) {
      if (p.lat < minLat) minLat = p.lat;
      if (p.lat > maxLat) maxLat = p.lat;
      if (p.lng < minLng) minLng = p.lng;
      if (p.lng > maxLng) maxLng = p.lng;
    }

    final centerLat = (minLat + maxLat) / 2.0;
    final centerLng = (minLng + maxLng) / 2.0;

    // Leave ample breathing space for bottom sheet (approx 200px) and top nav
    const verticalBias = -40.0;
    final availW = math.max(120.0, width - 80.0);
    final availH = math.max(120.0, height - 240.0);

    final spanLng = (maxLng - minLng).abs().clamp(0.001, 180.0);
    final worldSpanXAtZoom0 = (spanLng / 360.0) * MercatorProjection.tileSize;
    final zoomX = (math.log(availW / worldSpanXAtZoom0) / math.ln2);

    final y1 = MercatorProjection.latToPixelY(minLat, 0.0);
    final y2 = MercatorProjection.latToPixelY(maxLat, 0.0);
    final worldSpanYAtZoom0 = (y1 - y2).abs().clamp(0.001, 256.0);
    final zoomY = (math.log(availH / worldSpanYAtZoom0) / math.ln2);

    final idealZoom = math.min(zoomX, zoomY).clamp(12.0, 16.5);
    final z = _userZoom ?? idealZoom;

    return (
      centerLat: centerLat,
      centerLng: centerLng,
      zoom: z,
      verticalBias: verticalBias,
    );
  }

  void _handleTapToPick(
    Offset tapPos,
    double width,
    double height,
    double centerLat,
    double centerLng,
    double zoom,
    double verticalBias,
  ) {
    if (!widget.isSelectingLocation) return;

    // Apply pan offset inversely to locate tap in map coordinates
    final effectiveTap = tapPos - _panOffset;
    final result = MercatorProjection.screenOffsetToLatLng(
      screenOffset: effectiveTap,
      centerLat: centerLat,
      centerLng: centerLng,
      zoom: zoom,
      screenWidth: width,
      screenHeight: height,
      verticalCenterBias: verticalBias,
    );

    final newAddr = Address(
      id: 'addr_picked_${DateTime.now().millisecondsSinceEpoch}',
      label: _currentDestination?.label ?? 'Doorstep Pin',
      details:
          'Doorstep Location (${result.lat.toStringAsFixed(4)}° N, ${result.lng.toStringAsFixed(4)}° E)',
      lat: result.lat,
      lng: result.lng,
    );

    setState(() => _currentDestination = newAddr);
    _loadRoute();
    widget.onLocationPicked?.call(newAddr);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final viewport = _computeMapViewport(width, height);
        final effectiveCenterLat = viewport.centerLat;
        final effectiveCenterLng = viewport.centerLng;
        final currentZoom = viewport.zoom;
        final verticalBias = viewport.verticalBias;
        final isDark = _mapStyle == MapStyle.darkLuxury;

        final route = _route;
        final position = route?.getPositionAtProgress(widget.progress);

        // Screen offsets for pins
        Offset? originOffset;
        Offset? destOffset;
        Offset? riderOffset;

        if (route != null) {
          originOffset = MercatorProjection.latLngToScreenOffset(
                lat: route.originLat,
                lng: route.originLng,
                centerLat: effectiveCenterLat,
                centerLng: effectiveCenterLng,
                zoom: currentZoom,
                screenWidth: width,
                screenHeight: height,
                verticalCenterBias: verticalBias,
              ) +
              _panOffset;

          destOffset = MercatorProjection.latLngToScreenOffset(
                lat: route.destLat,
                lng: route.destLng,
                centerLat: effectiveCenterLat,
                centerLng: effectiveCenterLng,
                zoom: currentZoom,
                screenWidth: width,
                screenHeight: height,
                verticalCenterBias: verticalBias,
              ) +
              _panOffset;
        } else {
          final dest = _currentDestination ?? widget.destination;
          destOffset = MercatorProjection.latLngToScreenOffset(
                lat: dest.lat,
                lng: dest.lng,
                centerLat: effectiveCenterLat,
                centerLng: effectiveCenterLng,
                zoom: currentZoom,
                screenWidth: width,
                screenHeight: height,
                verticalCenterBias: verticalBias,
              ) +
              _panOffset;
        }

        if (position != null && route != null) {
          riderOffset = MercatorProjection.latLngToScreenOffset(
                lat: position.lat,
                lng: position.lng,
                centerLat: effectiveCenterLat,
                centerLng: effectiveCenterLng,
                zoom: currentZoom,
                screenWidth: width,
                screenHeight: height,
                verticalCenterBias: verticalBias,
              ) +
              _panOffset;
        }

        return Container(
          width: width,
          height: height,
          color: isDark ? const Color(0xFF14141C) : const Color(0xFFF2EFE9),
          child: Stack(
            children: [
              // ── 1. Pan & Tap Gesture Detector Layer ────────────────────────
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  setState(() {
                    _panOffset += details.delta;
                  });
                },
                onTapUp: (details) {
                  _handleTapToPick(
                    details.localPosition,
                    width,
                    height,
                    effectiveCenterLat,
                    effectiveCenterLng,
                    currentZoom,
                    verticalBias,
                  );
                },
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // ── 2. Real Slippy Raster Map Tile Layer ─────────────────
                    _buildSlippyTileGrid(
                      width: width,
                      height: height,
                      centerLat: effectiveCenterLat,
                      centerLng: effectiveCenterLng,
                      zoom: currentZoom,
                      verticalBias: verticalBias,
                      panOffset: _panOffset,
                      isDark: isDark,
                    ),

                    // ── 3. Zomato/Swiggy Delivery Route Overlay ───────────────
                    if (route != null)
                      CustomPaint(
                        size: Size(width, height),
                        painter: _RouteOverlayPainter(
                          route: route,
                          progress: widget.progress,
                          isSelecting: widget.isSelectingLocation,
                          isDark: isDark,
                          pulseValue: _pulseController.value,
                          centerLat: effectiveCenterLat,
                          centerLng: effectiveCenterLng,
                          zoom: currentZoom,
                          verticalBias: verticalBias,
                          panOffset: _panOffset,
                        ),
                      ),

                    // ── 4. Origin Pin: Paragon Restaurant ────────────────────
                    if (originOffset != null && !widget.isSelectingLocation)
                      _buildRestaurantPin(
                        offset: originOffset,
                        title: 'PARAGON',
                        subtitle: route?.originSubtitle ?? 'Restaurant Outlet',
                      ),

                    // ── 5. Destination Pin: Customer Doorstep ────────────────
                    _buildDoorstepPin(
                      offset: destOffset,
                      title: (_currentDestination ?? widget.destination).label,
                      isSelecting: widget.isSelectingLocation,
                      pulseValue: _pulseController.value,
                    ),

                    // ── 6. Animated Moving Delivery Partner Scooter ──────────
                    if (riderOffset != null &&
                        position != null &&
                        !widget.isSelectingLocation)
                      _buildAnimatedRider(
                        offset: riderOffset,
                        bearingDegrees: position.bearingDegrees,
                        speedKmh: position.speedKmh,
                        pulseValue: _pulseController.value,
                      ),
                  ],
                ),
              ),

              // ── 8. Floating Navigation & Map Controls ──────────────────────
              if (widget.showControls)
                Positioned(
                  right: 16,
                  top: 76,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _controlButton(
                        icon: Icons.add,
                        onTap: _zoomIn,
                        tooltip: 'Zoom In',
                      ),
                      const SizedBox(height: 8),
                      _controlButton(
                        icon: Icons.remove,
                        onTap: _zoomOut,
                        tooltip: 'Zoom Out',
                      ),
                      const SizedBox(height: 8),
                      _controlButton(
                        icon: Icons.crop_free,
                        onTap: _resetView,
                        tooltip: 'Fit Delivery Route',
                      ),
                      if (!widget.isSelectingLocation && route != null) ...[
                        const SizedBox(height: 8),
                        _controlButton(
                          icon: Icons.near_me_outlined,
                          color: _focusOnRider ? AppColors.copper : null,
                          onTap: _toggleRiderFocus,
                          tooltip: 'Focus on Delivery Rider',
                        ),
                      ],
                      const SizedBox(height: 8),
                      _controlButton(
                        icon: isDark
                            ? Icons.wb_sunny_outlined
                            : Icons.dark_mode_outlined,
                        onTap: _toggleMapStyle,
                        tooltip: isDark
                            ? 'Switch to Day Street Map'
                            : 'Switch to Night Mode',
                      ),
                    ],
                  ),
                ),

              // ── 9. Live City & Real Map Attribution Pill ───────────────────
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.copper.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.map_rounded,
                        color: AppColors.copper,
                        size: 13,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_getCityLabel()} • LIVE GOOGLE MAPS • REAL-TIME',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 10. Route Fetching Indicator ───────────────────────────────
              if (_isLoadingRoute)
                Positioned(
                  top: 14,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.copper.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.copper,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Loading Live Road Route...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a responsive grid of real Slippy Map tiles behind the route polyline.
  Widget _buildSlippyTileGrid({
    required double width,
    required double height,
    required double centerLat,
    required double centerLng,
    required double zoom,
    required double verticalBias,
    required Offset panOffset,
    required bool isDark,
  }) {
    final int z = zoom.round().clamp(10, 18);
    final centerWorldX =
        MercatorProjection.lngToPixelX(centerLng, z.toDouble()) - panOffset.dx;
    final centerWorldY =
        MercatorProjection.latToPixelY(centerLat, z.toDouble()) - panOffset.dy;

    // Determine visible tile range covering screen viewport + 1 tile buffer
    final minTileX =
        ((centerWorldX - (width / 2.0)) / MercatorProjection.tileSize).floor() -
            1;
    final maxTileX =
        ((centerWorldX + (width / 2.0)) / MercatorProjection.tileSize).floor() +
            1;
    final minTileY = (((centerWorldY - (height / 2.0) - verticalBias)) /
                MercatorProjection.tileSize)
            .floor() -
        1;
    final maxTileY = (((centerWorldY + (height / 2.0) - verticalBias)) /
                MercatorProjection.tileSize)
            .floor() +
        1;

    final tiles = <Widget>[];

    for (int tx = minTileX; tx <= maxTileX; tx++) {
      for (int ty = minTileY; ty <= maxTileY; ty++) {
        final tileLeft = (width / 2.0) +
            (tx * MercatorProjection.tileSize - centerWorldX);
        final tileTop = (height / 2.0) +
            (ty * MercatorProjection.tileSize - centerWorldY) +
            verticalBias;

        final gSub = (tx.abs() + ty.abs()) % 4;
        final primaryUrl = isDark
            ? 'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/$z/$ty/$tx'
            : 'https://mt$gSub.google.com/vt/lyrs=m&x=$tx&y=$ty&z=$z';
        final fallbackUrl = isDark
            ? 'https://mt$gSub.google.com/vt/lyrs=m&x=$tx&y=$ty&z=$z'
            : 'https://a.tile.openstreetmap.fr/hot/$z/$tx/$ty.png';

        tiles.add(
          Positioned(
            left: tileLeft,
            top: tileTop,
            width: MercatorProjection.tileSize,
            height: MercatorProjection.tileSize,
            child: _MapTileWidget(
              key: ValueKey('tile_${z}_${tx}_${ty}_$isDark'),
              url: primaryUrl,
              fallbackUrl: fallbackUrl,
              isDark: isDark,
            ),
          ),
        );
      }
    }

    return Stack(children: tiles);
  }

  Widget _buildRestaurantPin({
    required Offset offset,
    required String title,
    String? subtitle,
  }) {
    return Positioned(
      left: offset.dx - 45,
      top: offset.dy - 56,
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.copper,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.copper,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accentRed,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentRed.withValues(alpha: 0.6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoorstepPin({
    required Offset offset,
    required String title,
    required bool isSelecting,
    required double pulseValue,
  }) {
    return Positioned(
      left: offset.dx - 45,
      top: offset.dy - 56,
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white70,
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing target radar circle
                Container(
                  width: 30 + (pulseValue * 22),
                  height: 30 + (pulseValue * 22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.copper
                          .withValues(alpha: (1.0 - pulseValue).clamp(0.0, 1.0)),
                      width: 1.8,
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.copper,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.copper.withValues(alpha: 0.6),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.home_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedRider({
    required Offset offset,
    required double bearingDegrees,
    required double speedKmh,
    required double pulseValue,
  }) {
    return Positioned(
      left: offset.dx - 28,
      top: offset.dy - 28,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dynamic expanding pulse ring
            Container(
              width: 26 + (pulseValue * 26),
              height: 26 + (pulseValue * 26),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.copper
                      .withValues(alpha: (1.0 - pulseValue).clamp(0.0, 1.0)),
                  width: 2,
                ),
              ),
            ),
            // Rotated Delivery Partner Scooter Icon
            Transform.rotate(
              angle: bearingDegrees * (math.pi / 180.0),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.copper,
                  border: Border.all(color: Colors.white, width: 2.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.copper.withValues(alpha: 0.7),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.two_wheeler_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    Color? color,
  }) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.94),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: color ?? AppColors.copper.withValues(alpha: 0.4),
        ),
      ),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, color: color ?? AppColors.copper, size: 20),
          ),
        ),
      ),
    );
  }

  String _getCityLabel() {
    final dest = _currentDestination ?? widget.destination;
    final text = '${dest.label} ${dest.details}'.toLowerCase();
    if (text.contains('bengaluru') ||
        text.contains('bangalore') ||
        (dest.lat >= 12.5 &&
            dest.lat <= 13.5 &&
            dest.lng >= 77.0 &&
            dest.lng <= 78.0)) {
      return 'BENGALURU';
    }
    if (text.contains('calicut') ||
        text.contains('kozhikode') ||
        (dest.lat >= 11.0 &&
            dest.lat <= 11.5 &&
            dest.lng >= 75.5 &&
            dest.lng <= 76.2)) {
      return 'CALICUT';
    }
    return 'DOORSTEP';
  }
}

/// A robust tile widget with multi-CDN fallback and background placeholder
/// to ensure seamless, zero-white-space street map rendering.
class _MapTileWidget extends StatefulWidget {
  const _MapTileWidget({
    super.key,
    required this.url,
    required this.fallbackUrl,
    required this.isDark,
  });

  final String url;
  final String fallbackUrl;
  final bool isDark;

  @override
  State<_MapTileWidget> createState() => _MapTileWidgetState();
}

class _MapTileWidgetState extends State<_MapTileWidget> {
  bool _useFallback = false;

  @override
  void didUpdateWidget(covariant _MapTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _useFallback = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.isDark ? const Color(0xFF14141C) : const Color(0xFFF2EFE9),
      child: Image.network(
        _useFallback ? widget.fallbackUrl : widget.url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (!_useFallback) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _useFallback = true);
            });
          }
          return _buildTilePlaceholder(widget.isDark);
        },
      ),
    );
  }

  Widget _buildTilePlaceholder(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181824) : const Color(0xFFEBE6DC),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.04),
          width: 0.5,
        ),
      ),
    );
  }
}

/// Custom painter for Zomato/Swiggy/Uber-style delivery routes.
/// Paints a transparent overlay directly on top of the real street map tiles.
class _RouteOverlayPainter extends CustomPainter {
  const _RouteOverlayPainter({
    required this.route,
    required this.progress,
    required this.isSelecting,
    required this.isDark,
    required this.pulseValue,
    required this.centerLat,
    required this.centerLng,
    required this.zoom,
    required this.verticalBias,
    required this.panOffset,
  });

  final DeliveryRoute route;
  final double progress;
  final bool isSelecting;
  final bool isDark;
  final double pulseValue;
  final double centerLat;
  final double centerLng;
  final double zoom;
  final double verticalBias;
  final Offset panOffset;

  @override
  void paint(Canvas canvas, Size size) {
    if (route.points.length < 2) return;

    // Project all route GPS points to screen coordinates
    final offsets = <Offset>[];
    for (final p in route.points) {
      final off = MercatorProjection.latLngToScreenOffset(
            lat: p.lat,
            lng: p.lng,
            centerLat: centerLat,
            centerLng: centerLng,
            zoom: zoom,
            screenWidth: size.width,
            screenHeight: size.height,
            verticalCenterBias: verticalBias,
          ) +
          panOffset;
      offsets.add(off);
    }

    if (offsets.length < 2) return;

    // Full Route Polyline Path
    final fullRoutePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      fullRoutePath.lineTo(offsets[i].dx, offsets[i].dy);
    }

    // A. Ambient outer route glow (gives depth and makes route pop over real streets)
    final glowPaint = Paint()
      ..color = const Color(0xFFFF5722).withValues(alpha: 0.35)
      ..strokeWidth = 11.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(fullRoutePath, glowPaint);

    // B. Inner route casing (crisp white/dark contrast border against street tiles)
    final casingPaint = Paint()
      ..color = isDark
          ? Colors.black.withValues(alpha: 0.8)
          : Colors.white.withValues(alpha: 0.95)
      ..strokeWidth = 6.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(fullRoutePath, casingPaint);

    // C. Remaining Delivery Path (Swiggy / Zomato energetic crimson-orange)
    final remainingPaint = Paint()
      ..color = const Color(0xFFFF5232)
      ..strokeWidth = 4.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(fullRoutePath, remainingPaint);

    // D. Traveled Delivery Path (Warm Amber / Copper Gold)
    if (!isSelecting && progress > 0.0) {
      final visitedCount =
          (progress * offsets.length).ceil().clamp(1, offsets.length);
      final visitedPath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
      for (int i = 1; i < visitedCount; i++) {
        visitedPath.lineTo(offsets[i].dx, offsets[i].dy);
      }

      final visitedPaint = Paint()
        ..color = AppColors.copper
        ..strokeWidth = 4.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(visitedPath, visitedPaint);
    }

    // E. Directional Driving Chevrons along unvisited path
    final chevronPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startIndex = isSelecting ? 0 : (progress * offsets.length).floor();
    final stepInterval = math.max(3, offsets.length ~/ 7);

    for (int i = startIndex + 1; i < offsets.length - 1; i += stepInterval) {
      final p1 = offsets[i];
      final p2 = offsets[i + 1];
      final angle = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx);

      canvas.save();
      canvas.translate(p1.dx, p1.dy);
      canvas.rotate(angle);

      final arrowPath = Path()
        ..moveTo(-3.5, -3.5)
        ..lineTo(2.5, 0)
        ..lineTo(-3.5, 3.5);
      canvas.drawPath(arrowPath, chevronPaint);
      canvas.restore();
    }

    // F. Key Turn Waypoint Nodes
    final nodePaint = Paint()..color = Colors.white;
    final nodeBorderPaint = Paint()
      ..color = const Color(0xFFFF5232)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final nodeInterval = math.max(4, offsets.length ~/ 5);
    for (int i = nodeInterval; i < offsets.length - 1; i += nodeInterval) {
      final pt = offsets[i];
      canvas.drawCircle(pt, 2.8, nodePaint);
      canvas.drawCircle(pt, 2.8, nodeBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RouteOverlayPainter oldDelegate) =>
      oldDelegate.route != route ||
      oldDelegate.progress != progress ||
      oldDelegate.isSelecting != isSelecting ||
      oldDelegate.isDark != isDark ||
      oldDelegate.pulseValue != pulseValue ||
      oldDelegate.centerLat != centerLat ||
      oldDelegate.centerLng != centerLng ||
      oldDelegate.zoom != zoom ||
      oldDelegate.verticalBias != verticalBias ||
      oldDelegate.panOffset != panOffset;
}
