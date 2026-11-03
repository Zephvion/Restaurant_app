import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/models/address.dart';
import 'package:restaurant_app/screens/catering/catering_select_restaurant_screen.dart';
import 'package:restaurant_app/screens/reserve_table/select_restaurant_screen.dart';
import 'package:restaurant_app/services/gps_detection_service.dart';
import 'package:restaurant_app/services/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.instance.init();
    await SessionManager.instance.clearSelectedAddress();
    GpsDetectionService.resetForTesting();
  });

  group('SelectRestaurantScreen (Reserve Table) Auto-Detection & Nearest Sorting', () {
    testWidgets('Detects Bengaluru by default and displays only Bengaluru branches sorted nearest-to-farthest', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: SelectRestaurantScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify detected location badge
      expect(find.textContaining('Bengaluru'), findsWidgets);
      expect(find.textContaining('Karnataka'), findsWidgets);

      // Verify nearest branch badge
      expect(find.text('NEAREST'), findsOneWidget);

      // Verify Bengaluru branches are present
      expect(find.text('Paragon Restaurant'), findsOneWidget);
      expect(find.textContaining('Brigade Road'), findsOneWidget);

      // Verify Calicut branches are NOT present
      expect(find.textContaining('Kannur road'), findsNothing);
      expect(find.textContaining('Focus Mall'), findsNothing);
    });

    testWidgets('Detects Calicut when address is Kerala and orders nearest-to-farthest', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await SessionManager.instance.saveSelectedAddress(const Address(
        id: 'calicut_home',
        label: 'Calicut Home',
        details: 'Kannur Road, Calicut, Kerala - 673011',
        lat: 11.2588,
        lng: 75.7804,
      ));

      await tester.pumpWidget(
        const MaterialApp(
          home: SelectRestaurantScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify detected location badge
      expect(find.textContaining('Calicut'), findsWidgets);
      expect(find.textContaining('Kerala'), findsWidgets);

      // Verify NEAREST badge exists
      expect(find.text('NEAREST'), findsOneWidget);

      // Verify Calicut branches are present
      expect(find.text('Paragon Restaurant'), findsOneWidget);
      expect(find.textContaining('Kannur road'), findsOneWidget);

      // Verify Bengaluru branches are NOT present
      expect(find.textContaining('Brigade Road'), findsNothing);
    });
  });

  group('CateringSelectRestaurantScreen Auto-Detection & Nearest Sorting', () {
    testWidgets('Detects Bengaluru and displays only Bengaluru hubs sorted nearest-to-farthest', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: CateringSelectRestaurantScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify detected location badge
      expect(find.textContaining('Bengaluru'), findsWidgets);
      expect(find.textContaining('Karnataka'), findsWidgets);

      // Verify NEAREST badge
      expect(find.text('NEAREST'), findsOneWidget);

      // Verify Brigade Road is present
      expect(find.textContaining('Brigade Road'), findsOneWidget);
    });
  });
}
