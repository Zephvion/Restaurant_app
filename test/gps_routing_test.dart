import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/models/address.dart';
import 'package:restaurant_app/services/map_route_service.dart';
import 'package:restaurant_app/widgets/gps_location_picker_sheet.dart';
import 'package:restaurant_app/widgets/interactive_map_view.dart';

void main() {
  const testDest = Address(
    id: 'test_palazhi',
    label: 'Palazhi (Hilite Mall)',
    details: 'Hilite City, Palazhi, Calicut - 673014',
    lat: 11.2562,
    lng: 75.8335,
  );

  group('MapRouteService Route Calculations', () {
    test('Calculates delivery route with valid geometry and telemetry', () async {
      final route = await MapRouteService.instance.getDeliveryRoute(
        destination: testDest,
      );

      expect(route.points.isNotEmpty, isTrue);
      expect(route.totalDistanceKm, greaterThan(0.0));
      expect(route.estimatedMinutes, greaterThan(0));

      // Test route progress interpolation
      final startPos = route.getPositionAtProgress(0.0);
      expect(startPos.lat, isNotNull);
      expect(startPos.lng, isNotNull);
      expect(startPos.distanceRemainingKm, closeTo(route.totalDistanceKm, 0.5));

      final midPos = route.getPositionAtProgress(0.5);
      expect(midPos.distanceRemainingKm, lessThan(route.totalDistanceKm));
      expect(midPos.bearingDegrees, inInclusiveRange(0.0, 360.0));
      expect(midPos.speedKmh, greaterThan(0.0));

      final endPos = route.getPositionAtProgress(1.0);
      expect(endPos.distanceRemainingKm, closeTo(0.0, 0.01));
    });
  });

  group('InteractiveMapView Widget', () {
    testWidgets('Renders interactive map canvas and markers', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InteractiveMapView(
              destination: testDest,
              progress: 0.4,
              showControls: true,
              showTelemetry: true,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify origin and destination pin labels exist
      expect(find.text('PARAGON'), findsOneWidget);
      expect(find.text('Palazhi (Hilite Mall)'), findsOneWidget);

      // Verify zoom controls exist
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.crop_free), findsOneWidget);
    });
  });

  group('GpsLocationPickerSheet Widget', () {
    testWidgets('Opens GPS location picker and confirms selected location',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      Address? pickedAddress;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  GpsLocationPickerSheet.show(
                    context: context,
                    initialAddress: testDest,
                    onAddressSelected: (addr) {
                      pickedAddress = addr;
                    },
                  );
                },
                child: const Text('Open Picker'),
              ),
            ),
          ),
        ),
      );

      // Open the sheet
      await tester.tap(find.text('Open Picker'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Verify sheet title and action buttons
      expect(find.text('Select Live Delivery Location'), findsOneWidget);
      expect(find.text('Detect Live Location'), findsOneWidget);
      expect(find.text('POPULAR DELIVERY HUBS'), findsOneWidget);

      // Tap Cyberpark preset
      await tester.tap(find.text('Cyberpark'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Drag up to reveal bottom confirm button
      await tester.drag(find.text('POPULAR DELIVERY HUBS'), const Offset(0, -500));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final confirmBtn = find.byKey(const Key('confirm_location_btn'));
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify address was selected
      expect(pickedAddress, isNotNull);
      expect(pickedAddress!.lat, closeTo(11.2825, 0.01));
    });
  });
}
