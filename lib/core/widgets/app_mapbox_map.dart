
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../config/mapbox_config.dart';

class AppMapboxMap extends StatelessWidget {
  const AppMapboxMap({
    super.key,
    this.latitude = 12.9716,
    this.longitude = 77.5946,
    this.zoom = 12,
    this.height = 300,
  });

  final double latitude;
  final double longitude;
  final double zoom;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (!MapboxConfig.isConfigured) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'Map unavailable. Configure the Mapbox environment token.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MapWidget(
          key: const ValueKey('app-mapbox-map'),
          viewport: CameraViewportState(
            center: Point(
              coordinates: Position(longitude, latitude),
            ),
            zoom: zoom,
          ),
        ),
      ),
    );
  }
}
