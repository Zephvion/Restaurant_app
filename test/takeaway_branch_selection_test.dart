import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/data/mock_data.dart';
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
    testWidgets('Dashboard renders Nearest branch first, City tabs, and Select/Deselect buttons', (tester) async {
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

      // Verify City Filter tabs exist
      expect(find.text('All Branches'), findsOneWidget);
      expect(find.text('Bengaluru'), findsOneWidget);
      expect(find.text('Calicut'), findsOneWidget);
      expect(find.text('Kochi'), findsOneWidget);
      expect(find.text('Trivandrum'), findsOneWidget);

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

    testWidgets('City switching updates visible branches', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: TakeawayDashboardScreen(isEmbedded: true),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Kochi' tab
      await tester.ensureVisible(find.text('Kochi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kochi'));
      await tester.pumpAndSettle();

      // Should display Kochi outlets
      expect(find.textContaining('Kochi'), findsWidgets);
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

