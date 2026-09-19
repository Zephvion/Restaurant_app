import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/address.dart';
import '../services/map_route_service.dart';
import '../theme/app_colors.dart';

/// An interactive, high-performance vector map canvas for live delivery tracking
/// and interactive GPS location selection.
class InteractiveMapView extends StatefulWidget {
  const InteractiveMapView({
    super.key,
    required this.destination,
    this.progress = 0.45,
    this.isSelectingLocation = false,
    this.onLocationPicked,
    this.showControls = true,
    this.showTelemetry = true,
  });

  /// The target customer delivery address.
  final Address destination;

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
        oldWidget.destination.lng != widget.destination.lng) {
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
            // ── Interactive Vector Canvas ─────────────────────────────────
            InteractiveViewer(
              transformationController: _transformController,
              boundaryMargin: const EdgeInsets.all(120),
              minScale: 0.6,
              maxScale: 3.5,
              child: GestureDetector(
                onTapUp: widget.isSelectingLocation
                    ? (details) => _handleCanvasTap(details, width, height)
                    : null,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    children: [
                      // Base roads and route painter
                      CustomPaint(
                        size: Size(width, height),
                        painter: _MapCanvasPainter(
                          route: route,
                          progress: widget.progress,
                          isSelecting: widget.isSelectingLocation,
                        ),
                      ),

                      // Origin: Paragon Restaurant Pin
                      if (route != null)
                        _buildPin(
                          offset: _projectCoordinate(
                            route.originLat,
                            route.originLng,
                            route,
                            width,
                            height,
                          ),
                          title: 'PARAGON',
                          color: AppColors.accentRed,
                          icon: Icons.restaurant,
                        ),

                      // Destination: Customer Pin
                      if (route != null)
                        _buildPin(
                          offset: _projectCoordinate(
                            route.destLat,
                            route.destLng,
                            route,
                            width,
                            height,
                          ),
                          title: (_currentDestination ?? widget.destination).label,
                          color: Colors.white,
                          icon: Icons.home_rounded,
                          iconColor: const Color(0xFF141419),
                        ),

                      // Moving Delivery Vehicle Pin (Scooter with Heading Rotation)
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

            // ── Loading Route Overlay ─────────────────────────────────────
            if (_isLoadingRoute)
              Positioned(
                top: 14,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
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
                        'Fetching OSRM GPS Route...',
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
                      color: const Color(0xFF1B1B22).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.copper.withValues(alpha: 0.35),
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

            // ── Floating Zoom / Recenter Controls ─────────────────────────
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
      color: AppColors.surface.withValues(alpha: 0.88),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: AppColors.copper.withValues(alpha: 0.3),
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

  Widget _buildPin({
    required Offset offset,
    required String title,
    required Color color,
    required IconData icon,
    Color iconColor = Colors.white,
  }) {
    return Positioned(
      left: offset.dx - 40,
      top: offset.dy - 48,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
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
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
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

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final t = _pulseController.value;
        return Positioned(
          left: offset.dx - 32,
          top: offset.dy - 32,
          child: SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Concentric radar pulse
                Container(
                  width: 28 + (t * 26),
                  height: 28 + (t * 26),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.copper.withValues(alpha: (1.0 - t) * 0.4),
                  ),
                ),
                // Heading rotation wrapper for vehicle
                Transform.rotate(
                  angle: position.bearingDegrees * (math.pi / 180.0),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.copper,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
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
          ),
        );
      },
    );
  }

  void _handleCanvasTap(TapUpDetails details, double width, double height) {
    if (_route == null) return;
    final tapOffset = details.localPosition;

    // Invert projection to get approximate lat/lng
    final minLat = math.min(_route!.originLat, _route!.destLat) - 0.008;
    final maxLat = math.max(_route!.originLat, _route!.destLat) + 0.008;
    final minLng = math.min(_route!.originLng, _route!.destLng) - 0.008;
    final maxLng = math.max(_route!.originLng, _route!.destLng) + 0.008;

    final padX = width * 0.14;
    final padY = height * 0.14;
    final drawW = width - (padX * 2);
    final drawH = height - (padY * 2);

    final normX = ((tapOffset.dx - padX) / drawW).clamp(0.0, 1.0);
    final normY = (1.0 - ((tapOffset.dy - padY) / drawH)).clamp(0.0, 1.0);

    final newLng = minLng + normX * (maxLng - minLng);
    final newLat = minLat + normY * (maxLat - minLat);

    final newAddress = Address(
      id: 'addr_picked_${DateTime.now().millisecondsSinceEpoch}',
      label: 'Selected Location',
      details: 'Calicut City (${newLat.toStringAsFixed(4)}, ${newLng.toStringAsFixed(4)})',
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
    double height,
  ) {
    // Find bounding box across all route points
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

    // Generous padding around the route
    const padFactor = 0.006;
    minLat -= padFactor;
    maxLat += padFactor;
    minLng -= padFactor;
    maxLng += padFactor;

    final padX = width * 0.14;
    final padY = height * 0.14;
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
  });

  final DeliveryRoute? route;
  final double progress;
  final bool isSelecting;

  @override
  void paint(Canvas canvas, Size size) {
    // Dark theme luxury background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF141419),
    );

    // City street grid
    final gridStreetPaint = Paint()
      ..color = const Color(0xFF202029)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final secondaryStreetPaint = Paint()
      ..color = const Color(0xFF1A1A22)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Background road network lines
    canvas.drawLine(
      Offset(0, size.height * 0.25),
      Offset(size.width, size.height * 0.22),
      gridStreetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.22, 0),
      Offset(size.width * 0.35, size.height),
      gridStreetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.78, 0),
      Offset(size.width * 0.62, size.height),
      gridStreetPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.62),
      Offset(size.width, size.height * 0.68),
      gridStreetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.82),
      Offset(size.width * 0.9, size.height * 0.78),
      secondaryStreetPaint,
    );

    if (route == null || route!.points.isEmpty) return;

    // Convert route points to screen offsets
    final offsets = <Offset>[];
    for (final p in route!.points) {
      offsets.add(
        _InteractiveMapViewState._projectCoordinate(
          p.lat,
          p.lng,
          route!,
          size.width,
          size.height,
        ),
      );
    }

    if (offsets.length < 2) return;

    // Build overall smooth route path
    final fullRoutePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      fullRoutePath.lineTo(offsets[i].dx, offsets[i].dy);
    }

    // 1. Ambient route glow
    final glowPaint = Paint()
      ..color = AppColors.accentRed.withValues(alpha: 0.25)
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(fullRoutePath, glowPaint);

    // 2. Remaining path (Red accent)
    final remainingPaint = Paint()
      ..color = AppColors.accentRed
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(fullRoutePath, remainingPaint);

    // 3. Visited path (Copper/Green trail behind rider)
    if (!isSelecting && progress > 0.0) {
      final visitedCount = (progress * offsets.length).ceil().clamp(1, offsets.length);
      final visitedPath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
      for (int i = 1; i < visitedCount; i++) {
        visitedPath.lineTo(offsets[i].dx, offsets[i].dy);
      }

      final visitedPaint = Paint()
        ..color = AppColors.copper
        ..strokeWidth = 4.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(visitedPath, visitedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) =>
      oldDelegate.route != route ||
      oldDelegate.progress != progress ||
      oldDelegate.isSelecting != isSelecting;
}
