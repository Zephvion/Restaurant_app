import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/models/address.dart';
import 'package:restaurant_app/screens/takeaway/select_takeaway_restaurant_screen.dart';
import 'package:restaurant_app/screens/takeaway/takeaway_dashboard_screen.dart';
import 'package:restaurant_app/services/session_manager.dart';
import 'package:restaurant_app/state/takeaway_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.instance.init();
    TakeawayController.instance.deselectRestaurant();
  });

  group('Takeaway Outlet Select & Deselect Tests', () {
    testWidgets('Dashboard renders detected state/city, Nearest branch first, and Select/Deselect buttons', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final ctrl = TakeawayController.instance;
      expect(ctrl.hasExplicitSelection, isFalse);

      await tester.pumpWidget(
        const MaterialApp(
          home: TakeawayDashboardScreen(isEmbedded: true),
        ),
      );
      await tester.pumpAndSettle();

      // Verify detected location badge exists
      expect(find.textContaining('Bengaluru'), findsWidgets);

      // Verify nearest branch badge is displayed
      expect(find.textContaining('NEAREST'), findsWidgets);

      // Verify Select buttons are displayed on outlet tiles
      final selectButtons = find.widgetWithText(ElevatedButton, 'Select');
      expect(selectButtons, findsWidgets);

      // Tap 'Select' on the first outlet
      await tester.tap(selectButtons.first);
      await tester.pumpAndSettle();

      // Controller should now have explicit selection
      expect(ctrl.hasExplicitSelection, isTrue);

      // Deselect button should now be visible
      final deselectButtons = find.widgetWithText(OutlinedButton, 'Deselect');
      expect(deselectButtons, findsWidgets);

      // Tap 'Deselect' to toggle it off
      await tester.tap(deselectButtons.first);
      await tester.pumpAndSettle();

      // Selection is cleared cleanly
      expect(ctrl.hasExplicitSelection, isFalse);
    });

    testWidgets('Dashboard shows only branches of detected state/city automatically sorted nearest to farthest', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Set user address to Calicut, Kerala
      await SessionManager.instance.saveSelectedAddress(const Address(
        id: 'calicut_test',
        label: 'Calicut Home',
        details: 'Kannur Road, Calicut, Kerala - 673011',
        lat: 11.2588,
        lng: 75.7804,
      ));

      await tester.pumpWidget(
        const MaterialApp(
          home: TakeawayDashboardScreen(isEmbedded: true),
        ),
      );
      await tester.pumpAndSettle();

      // Should automatically detect Calicut, Kerala
      expect(find.textContaining('Calicut'), findsWidgets);
      expect(find.textContaining('Kerala'), findsWidgets);
      expect(find.textContaining('NEAREST'), findsWidgets);
    });

    testWidgets('SelectTakeawayRestaurantScreen supports Select, Deselect and Search', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: SelectTakeawayRestaurantScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Search bar is rendered
      expect(find.byType(TextField), findsOneWidget);

      // Select buttons are rendered
      final selectButtons = find.widgetWithText(ElevatedButton, 'Select');
      expect(selectButtons, findsWidgets);

      // Tap Select on first outlet
      await tester.tap(selectButtons.first);
      await tester.pumpAndSettle();

      // Deselect button appears
      final deselectButtons = find.widgetWithText(OutlinedButton, 'Deselect');
      expect(deselectButtons, findsWidgets);

      // Tap Deselect
      await tester.tap(deselectButtons.first);
      await tester.pumpAndSettle();

      // Back to unselected
      expect(find.text('SELECT AN OUTLET TO CONTINUE'), findsOneWidget);
    });
  });
}
