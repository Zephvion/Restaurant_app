import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/address.dart';
import '../services/map_route_service.dart';
import '../theme/app_colors.dart';

/// Display styles for the map canvas.
enum MapStyle {
  streets,
  darkLuxury,
}

/// An interactive, high-performance vector and raster map canvas for live delivery tracking
/// and interactive GPS location selection, showcasing authentic Calicut cartography.
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
  final TransformationController _transformController =
      TransformationController();

  DeliveryRoute? _route;
  bool _isLoadingRoute = true;
  Address? _currentDestination;
  MapStyle _mapStyle = MapStyle.streets;

  @override
  void initState() {
    super.initState();
    _currentDestination = widget.destination;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
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
      _loadRoute();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transformController.dispose();
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
    final matrix = _transformController.value.clone();
    matrix.scaleByDouble(1.25, 1.25, 1.0, 1.0);
    _transformController.value = matrix;
  }

  void _zoomOut() {
    final matrix = _transformController.value.clone();
    matrix.scaleByDouble(0.8, 0.8, 1.0, 1.0);
    _transformController.value = matrix;
  }

  void _resetView() {
    _transformController.value = Matrix4.identity();
  }

  void _toggleMapStyle() {
    setState(() {
      _mapStyle = _mapStyle == MapStyle.streets
          ? MapStyle.darkLuxury
          : MapStyle.streets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final route = _route;
        final position = route?.getPositionAtProgress(widget.progress);

        return Stack(
          children: [
            // ── Interactive Map Canvas ─────────────────────────────────────
            InteractiveViewer(
              transformationController: _transformController,
              boundaryMargin: const EdgeInsets.all(160),
              minScale: 0.5,
              maxScale: 4.0,
              child: GestureDetector(
                onTapUp: widget.isSelectingLocation
                    ? (details) => _handleCanvasTap(details, width, height)
                    : null,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    children: [
                      // 1. Real Slippy Raster Map Tile Layer (CartoDB / OpenStreetMap)
                      if (route != null)
                        _buildTileGrid(route, width, height),

                      // 2. Rich Calicut Vector Cartography & Street Grid Overlay
                      CustomPaint(
                        size: Size(width, height),
                        painter: _MapCanvasPainter(
                          route: route,
                          progress: widget.progress,
                          isSelecting: widget.isSelectingLocation,
                          mapStyle: _mapStyle,
                          pulseValue: _pulseController.value,
                        ),
                      ),

                      // 3. Calicut Landmark Badges (Rendered only when viewing Calicut region)
                      if (route != null && _isCalicutRegion(route, widget.isSelectingLocation)) ...[
                        _buildLandmark(
                          lat: 11.2530,
                          lng: 75.7800,
                          title: 'Mananchira Square',
                          icon: Icons.park_outlined,
                          route: route,
                          width: width,
                          height: height,
                        ),
                        _buildLandmark(
                          lat: 11.2590,
                          lng: 75.7680,
                          title: 'Calicut Beach',
                          icon: Icons.beach_access_rounded,
                          route: route,
                          width: width,
                          height: height,
                        ),
                        _buildLandmark(
                          lat: 11.2384,
                          lng: 75.8342,
                          title: 'Hilite Mall / Palazhi',
                          icon: Icons.shopping_bag_outlined,
                          route: route,
                          width: width,
                          height: height,
                        ),
                        _buildLandmark(
                          lat: 11.2310,
                          lng: 75.8380,
                          title: 'Cyberpark',
                          icon: Icons.computer_rounded,
                          route: route,
                          width: width,
                          height: height,
                        ),
                      ],

                      // 4. Origin: Paragon Restaurant Pin (Rendered when tracking or in Calicut)
                      if (route != null && !widget.isSelectingLocation)
                        _buildPin(
                          offset: _projectCoordinate(
                            route.originLat,
                            route.originLng,
                            route,
                            width,
                            height,
                            isSelecting: widget.isSelectingLocation,
                          ),
                          title: 'PARAGON',
                          subtitle: route.originSubtitle.isNotEmpty
                              ? route.originSubtitle
                              : (widget.originSubtitle ?? 'Restaurant Outlet'),
                          color: AppColors.accentRed,
                          icon: Icons.restaurant,
                        ),

                      // 5. Destination: Customer Doorstep Pin
                      if (route != null)
                        _buildPin(
                          offset: _projectCoordinate(
                            route.destLat,
                            route.destLng,
                            route,
                            width,
                            height,
                            isSelecting: widget.isSelectingLocation,
                          ),
                          title: (_currentDestination ?? widget.destination).label,
                          subtitle: widget.isSelectingLocation ? 'Your Doorstep (GPS)' : 'Delivery Location',
                          color: AppColors.copper,
                          icon: Icons.home_rounded,
                          iconColor: Colors.white,
                        ),

                      // 6. Moving Delivery Vehicle Pin (Scooter with Heading Rotation)
                      if (!widget.isSelectingLocation &&
                          route != null &&
                          position != null)
                        _buildMovingRider(
                          position: position,
                          route: route,
                          width: width,
                          height: height,
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── City Identification Pill ──────────────────────────────────
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.copper.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_city_rounded,
                        color: AppColors.copper, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '${_getCityLabel()} • LIVE GPS MAP (${_mapStyle == MapStyle.streets ? "STREETS" : "NIGHT"})',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Loading Route Overlay ─────────────────────────────────────
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
                        'Updating Calicut GPS Route...',
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

            // ── Live Telemetry HUD ─────────────────────────────────────────
            if (widget.showTelemetry &&
                !widget.isSelectingLocation &&
                position != null &&
                route != null)
              Positioned(
                top: 14,
                left: 16,
                right: 16,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1B22).withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.copper.withValues(alpha: 0.4),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${position.distanceRemainingKm.toStringAsFixed(1)} km left',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${position.speedKmh.round()} km/h',
                          style: const TextStyle(
                            color: AppColors.copper,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${route.estimatedMinutes}m ETA',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Floating Zoom / Recenter / Layer Controls ─────────────────
            if (widget.showControls)
              Positioned(
                right: 16,
                top: 80,
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
                      tooltip: 'Reset View',
                    ),
                    const SizedBox(height: 8),
                    _controlButton(
                      icon: _mapStyle == MapStyle.streets
                          ? Icons.dark_mode_outlined
                          : Icons.map_outlined,
                      onTap: _toggleMapStyle,
                      tooltip: _mapStyle == MapStyle.streets
                          ? 'Switch to Dark Mode'
                          : 'Switch to Street Map',
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _controlButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: AppColors.copper.withValues(alpha: 0.35),
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
            child: Icon(icon, color: AppColors.copper, size: 20),
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
        (dest.lat >= 12.5 && dest.lat <= 13.5 && dest.lng >= 77.0 && dest.lng <= 78.0)) {
      return 'BENGALURU';
    }
    if (text.contains('calicut') ||
        text.contains('kozhikode') ||
        (dest.lat >= 11.0 && dest.lat <= 11.5 && dest.lng >= 75.5 && dest.lng <= 76.2)) {
      return 'CALICUT';
    }
    return 'DOORSTEP';
  }

  static Rect _computeViewportBounds(DeliveryRoute route, bool isSelecting) {
    if (isSelecting) {
      const span = 0.0075;
      return Rect.fromLTRB(
        route.destLng - span,
        route.destLat - span,
        route.destLng + span,
        route.destLat + span,
      );
    }
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

    const padFactor = 0.008;
    return Rect.fromLTRB(
      minLng - padFactor,
      minLat - padFactor,
      maxLng + padFactor,
      maxLat + padFactor,
    );
  }

  static bool _isCalicutRegion(DeliveryRoute route, bool isSelecting) {
    final bounds = _computeViewportBounds(route, isSelecting);
    return bounds.top <= 11.35 &&
        bounds.bottom >= 11.18 &&
        bounds.left <= 75.92 &&
        bounds.right >= 75.68;
  }

  /// Builds a responsive grid of real Slippy Map tiles behind the canvas
  Widget _buildTileGrid(DeliveryRoute route, double width, double height) {
    final bounds = _computeViewportBounds(route, widget.isSelectingLocation);
    final minLng = bounds.left;
    final minLat = bounds.top;
    final maxLng = bounds.right;
    final maxLat = bounds.bottom;

    final double span = math.max(maxLat - minLat, maxLng - minLng);
    int zoom;
    if (widget.isSelectingLocation) {
      zoom = 15;
    } else if (span < 0.06) {
      zoom = 14;
    } else if (span < 0.15) {
      zoom = 13;
    } else if (span < 0.4) {
      zoom = 11;
    } else if (span < 1.5) {
      zoom = 9;
    } else {
      zoom = 7;
    }

    final minTileX = _lngToTileX(minLng, zoom);
    final maxTileX = _lngToTileX(maxLng, zoom);
    final minTileY = _latToTileY(maxLat, zoom);
    final maxTileY = _latToTileY(minLat, zoom);

    final tiles = <Widget>[];

    // Cap to at most 4x4 tiles to guarantee smooth rendering performance
    final startX = minTileX;
    final endX = math.min(maxTileX, minTileX + 3);
    final startY = minTileY;
    final endY = math.min(maxTileY, minTileY + 3);

    for (int tx = startX; tx <= endX; tx++) {
      for (int ty = startY; ty <= endY; ty++) {
        final tileWest = _tileXToLng(tx, zoom);
        final tileEast = _tileXToLng(tx + 1, zoom);
        final tileNorth = _tileYToLat(ty, zoom);
        final tileSouth = _tileYToLat(ty + 1, zoom);

        final tl = _projectCoordinate(tileNorth, tileWest, route, width, height, isSelecting: widget.isSelectingLocation);
        final br = _projectCoordinate(tileSouth, tileEast, route, width, height, isSelecting: widget.isSelectingLocation);

        final tileW = (br.dx - tl.dx).abs();
        final tileH = (br.dy - tl.dy).abs();
        if (tileW <= 1 || tileH <= 1) continue;

        final url = _mapStyle == MapStyle.streets
            ? 'https://a.basemaps.cartocdn.com/rastertiles/voyager/$zoom/$tx/$ty.png'
            : 'https://a.basemaps.cartocdn.com/dark_all/$zoom/$tx/$ty.png';

        tiles.add(
          Positioned(
            left: math.min(tl.dx, br.dx),
            top: math.min(tl.dy, br.dy),
            width: tileW,
            height: tileH,
            child: Opacity(
              opacity: _mapStyle == MapStyle.darkLuxury ? 0.7 : 0.88,
              child: Image.network(
                url,
                fit: BoxFit.fill,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        );
      }
    }

    return Stack(children: tiles);
  }

  static int _lngToTileX(double lng, int zoom) {
    return ((lng + 180.0) / 360.0 * (1 << zoom)).floor();
  }

  static int _latToTileY(double lat, int zoom) {
    final latRad = lat * math.pi / 180.0;
    return ((1.0 -
                math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) /
            2.0 *
            (1 << zoom))
        .floor();
  }

  static double _tileXToLng(int x, int zoom) {
    return x / (1 << zoom) * 360.0 - 180.0;
  }

  static double _tileYToLat(int y, int zoom) {
    final n = math.pi - 2.0 * math.pi * y / (1 << zoom);
    return 180.0 / math.pi * math.atan(0.5 * (math.exp(n) - math.exp(-n)));
  }

  Widget _buildLandmark({
    required double lat,
    required double lng,
    required String title,
    required IconData icon,
    required DeliveryRoute route,
    required double width,
    required double height,
  }) {
    final offset = _projectCoordinate(lat, lng, route, width, height);

    if (offset.dx < -20 ||
        offset.dx > width + 20 ||
        offset.dy < -20 ||
        offset.dy > height + 20) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: offset.dx - 35,
      top: offset.dy - 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white24,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 10),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPin({
    required Offset offset,
    required String title,
    String? subtitle,
    required Color color,
    required IconData icon,
    Color iconColor = Colors.white,
  }) {
    return Positioned(
      left: offset.dx - 45,
      top: offset.dy - 52,
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withValues(alpha: 0.8),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
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
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovingRider({
    required RoutePosition position,
    required DeliveryRoute route,
    required double width,
    required double height,
  }) {
    final offset = _projectCoordinate(
      position.lat,
      position.lng,
      route,
      width,
      height,
    );

    return Positioned(
      left: offset.dx - 28,
      top: offset.dy - 28,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulse = _pulseController.value;
          return SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 28 + (pulse * 26),
                  height: 28 + (pulse * 26),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.copper.withValues(alpha: 1.0 - pulse),
                      width: 2,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: position.bearingDegrees * (math.pi / 180.0),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.copper,
                      border: Border.all(color: Colors.white, width: 2.2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.copper.withValues(alpha: 0.6),
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
          );
        },
      ),
    );
  }

  void _handleCanvasTap(TapUpDetails details, double width, double height) {
    if (_route == null) return;
    final tapOffset = details.localPosition;

    final bounds = _computeViewportBounds(_route!, widget.isSelectingLocation);
    final minLng = bounds.left;
    final minLat = bounds.top;
    final maxLng = bounds.right;
    final maxLat = bounds.bottom;

    final padX = width * 0.10;
    final padY = height * 0.10;
    final drawW = width - (padX * 2);
    final drawH = height - (padY * 2);

    final normX = ((tapOffset.dx - padX) / drawW).clamp(0.0, 1.0);
    final normY = (1.0 - ((tapOffset.dy - padY) / drawH)).clamp(0.0, 1.0);

    final newLng = minLng + normX * (maxLng - minLng);
    final newLat = minLat + normY * (maxLat - minLat);

    final newAddress = Address(
      id: 'addr_picked_${DateTime.now().millisecondsSinceEpoch}',
      label: _currentDestination?.label ?? 'Doorstep Pin',
      details:
          'Doorstep Location (${newLat.toStringAsFixed(4)}° N, ${newLng.toStringAsFixed(4)}° E)',
      lat: newLat,
      lng: newLng,
    );

    setState(() => _currentDestination = newAddress);
    _loadRoute();
    widget.onLocationPicked?.call(newAddress);
  }

  static Offset _projectCoordinate(
    double lat,
    double lng,
    DeliveryRoute route,
    double width,
    double height, {
    bool isSelecting = false,
  }) {
    final bounds = _computeViewportBounds(route, isSelecting);
    final minLng = bounds.left;
    final minLat = bounds.top;
    final maxLng = bounds.right;
    final maxLat = bounds.bottom;

    final padX = width * 0.10;
    final padY = height * 0.10;
    final drawW = width - (padX * 2);
    final drawH = height - (padY * 2);

    final normX = (lng - minLng) / (maxLng - minLng);
    final normY = 1.0 - ((lat - minLat) / (maxLat - minLat));

    return Offset(
      padX + (normX * drawW),
      padY + (normY * drawH),
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  const _MapCanvasPainter({
    required this.route,
    required this.progress,
    required this.isSelecting,
    required this.mapStyle,
    required this.pulseValue,
  });

  final DeliveryRoute? route;
  final double progress;
  final bool isSelecting;
  final MapStyle mapStyle;
  final double pulseValue;

  @override
  void paint(Canvas canvas, Size size) {
    final isDark = mapStyle == MapStyle.darkLuxury;

    // ── 1. Base Land Palette ────────────────────────────────────────────────
    final baseBgColor = isDark ? const Color(0xFF14141C) : const Color(0xFFEBE6DC);
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = baseBgColor,
    );

    if (route == null) return;

    final isCalicut = _InteractiveMapViewState._isCalicutRegion(route!, isSelecting);

    // ── 2. Arabian Sea Coastline & Calicut Cartography (Only in Calicut region) ──
    if (isCalicut) {
      const coastLng = 75.7720;
      final coastPt = _InteractiveMapViewState._projectCoordinate(
        11.2588,
        coastLng,
        route!,
        size.width,
        size.height,
        isSelecting: isSelecting,
      );

      final seaRight = coastPt.dx.clamp(0.0, size.width * 0.45);
      if (seaRight > 0) {
        final seaPaint = Paint()
          ..color = isDark ? const Color(0xFF0F2236) : const Color(0xFFB5D4EB);
        canvas.drawRect(Rect.fromLTWH(0, 0, seaRight, size.height), seaPaint);

        // Coastline beach promenade strip
        final sandPaint = Paint()
          ..color = isDark ? const Color(0xFF4A4434) : const Color(0xFFE4D5B4)
          ..strokeWidth = 4;
        canvas.drawLine(
          Offset(seaRight, 0),
          Offset(seaRight, size.height),
          sandPaint,
        );

        // Sea waves and text
        _drawLabel(
          canvas,
          '🌊 ARABIAN SEA',
          Offset(math.max(10, seaRight * 0.3), size.height * 0.4),
          isDark ? const Color(0xFF4D7298) : const Color(0xFF6F99BF),
          fontSize: 10,
          letterSpacing: 1.5,
        );
      }

      // ── 3. Calicut Parks & Green Wetlands ──────────────────────────────────
      // Mananchira Square
      final mananchiraPt = _InteractiveMapViewState._projectCoordinate(
        11.2530,
        75.7800,
        route!,
        size.width,
        size.height,
        isSelecting: isSelecting,
      );
      final parkPaint = Paint()
        ..color = isDark ? const Color(0xFF1B2E24) : const Color(0xFFCCE8D0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: mananchiraPt, width: 34, height: 34),
          const Radius.circular(4),
        ),
        parkPaint,
      );
      final waterTankPaint = Paint()
        ..color = isDark ? const Color(0xFF0F2236) : const Color(0xFF98C5E8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: mananchiraPt, width: 16, height: 16),
          const Radius.circular(2),
        ),
        waterTankPaint,
      );

      // ── 4. Major Calicut Arterial Highway Network ───────────────────────────
      final highwayCasingPaint = Paint()
        ..color = isDark ? const Color(0xFF282836) : const Color(0xFFC8C2B6)
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round;

      final highwayPaint = Paint()
        ..color = isDark ? const Color(0xFF38384A) : Colors.white
        ..strokeWidth = 6.5
        ..strokeCap = StrokeCap.round;

      final localRoadPaint = Paint()
        ..color = isDark ? const Color(0xFF22222E) : const Color(0xFFF7F5F0)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      // Mavoor Road (Kannur Rd -> Arayidathupalam -> Medical College)
      final mavoorStart = _InteractiveMapViewState._projectCoordinate(
        11.2570,
        75.7860,
        route!,
        size.width,
        size.height,
        isSelecting: isSelecting,
      );
      final mavoorMid = _InteractiveMapViewState._projectCoordinate(
        11.2610,
        75.7980,
        route!,
        size.width,
        size.height,
        isSelecting: isSelecting,
      );
      final mavoorEnd = _InteractiveMapViewState._projectCoordinate(
        11.2720,
        75.8360,
        route!,
        size.width,
        size.height,
        isSelecting: isSelecting,
      );

      canvas.drawLine(mavoorStart, mavoorMid, highwayCasingPaint);
      canvas.drawLine(mavoorMid, mavoorEnd, highwayCasingPaint);
      canvas.drawLine(mavoorStart, mavoorMid, highwayPaint);
      canvas.drawLine(mavoorMid, mavoorEnd, highwayPaint);

      // NH 66 / Mini Bypass (North to Palazhi / Cyberpark)
      final bypassNorth = _InteractiveMapViewState._projectCoordinate(
        11.2750,
        75.8150,
        route!,
        size.width,
        size.height,
        isSelecting: isSelecting,
      );
      final bypassSouth = _InteractiveMapViewState._projectCoordinate(
        11.2384,
        75.8342,
        route!,
        size.width,
        size.height,
        isSelecting: isSelecting,
      );
      canvas.drawLine(bypassNorth, bypassSouth, highwayCasingPaint);
      canvas.drawLine(bypassNorth, bypassSouth, highwayPaint);

      // Beach Road (Running along coastline)
      if (seaRight > 0) {
        canvas.drawLine(
          Offset(seaRight + 6, 0),
          Offset(seaRight + 6, size.height),
          localRoadPaint,
        );
      }

      // Street labels
      _drawLabel(
        canvas,
        'MAVOOR ROAD',
        Offset((mavoorStart.dx + mavoorMid.dx) / 2, (mavoorStart.dy + mavoorMid.dy) / 2 - 8),
        isDark ? Colors.white38 : const Color(0xFF706B62),
        fontSize: 8.5,
      );
      _drawLabel(
        canvas,
        'NH 66 BYPASS',
        Offset((bypassNorth.dx + bypassSouth.dx) / 2 + 6, (bypassNorth.dy + bypassSouth.dy) / 2),
        isDark ? Colors.white38 : const Color(0xFF706B62),
        fontSize: 8.5,
      );
    }

    // Radar pulse ring on the target doorstep pin
    if (isSelecting) {
      final destPt = _InteractiveMapViewState._projectCoordinate(
        route!.destLat,
        route!.destLng,
        route!,
        size.width,
        size.height,
        isSelecting: true,
      );
      final ringPaint = Paint()
        ..color = AppColors.copper.withValues(alpha: (0.45 - (pulseValue * 0.35)).clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(destPt, 22 + (pulseValue * 26), ringPaint);
    }

    // ── 5. Delivery Route Polyline ──────────────────────────────────────────
    if (route!.points.length < 2) return;

    final offsets = <Offset>[];
    for (final p in route!.points) {
      offsets.add(
        _InteractiveMapViewState._projectCoordinate(
          p.lat,
          p.lng,
          route!,
          size.width,
          size.height,
          isSelecting: isSelecting,
        ),
      );
    }

    // Full Route Polyline Path
    final fullRoutePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      fullRoutePath.lineTo(offsets[i].dx, offsets[i].dy);
    }

    // A. Ambient route glow
    final glowPaint = Paint()
      ..color = AppColors.accentRed.withValues(alpha: 0.3)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(fullRoutePath, glowPaint);

    // B. Remaining Path (Vibrant Crimson)
    final remainingPaint = Paint()
      ..color = AppColors.accentRed
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(fullRoutePath, remainingPaint);

    // C. Visited Path (Warm Copper Gold)
    if (!isSelecting && progress > 0.0) {
      final visitedCount =
          (progress * offsets.length).ceil().clamp(1, offsets.length);
      final visitedPath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
      for (int i = 1; i < visitedCount; i++) {
        visitedPath.lineTo(offsets[i].dx, offsets[i].dy);
      }

      final visitedPaint = Paint()
        ..color = AppColors.copper
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(visitedPath, visitedPaint);
    }

    // D. Route Directional Flow Indicators
    final chevronPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final stepInterval = math.max(3, offsets.length ~/ 6);
    for (int i = stepInterval; i < offsets.length - 1; i += stepInterval) {
      final p1 = offsets[i];
      final p2 = offsets[i + 1];
      final angle = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx);

      canvas.save();
      canvas.translate(p1.dx, p1.dy);
      canvas.rotate(angle);

      final arrowPath = Path()
        ..moveTo(-3, -3)
        ..lineTo(2, 0)
        ..lineTo(-3, 3);
      canvas.drawPath(arrowPath, chevronPaint);
      canvas.restore();
    }
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset offset,
    Color color, {
    double fontSize = 9,
    double letterSpacing = 0.8,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: letterSpacing,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) =>
      oldDelegate.route != route ||
      oldDelegate.progress != progress ||
      oldDelegate.isSelecting != isSelecting ||
      oldDelegate.mapStyle != mapStyle ||
      oldDelegate.pulseValue != pulseValue;
}
