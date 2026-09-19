import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/routes/app_routes.dart';
import 'package:restaurant_app/screens/takeaway/takeaway_success_screen.dart';

void main() {
  testWidgets(
      'TakeawaySuccessScreen shows countdown and auto-redirects to takeawayDashboard',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    bool redirectedToDashboard = false;
    bool redirectedToTrackOrder = false;

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoutes.takeawaySuccess,
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.takeawaySuccess) {
            return MaterialPageRoute(
              settings: const RouteSettings(name: AppRoutes.takeawaySuccess),
              builder: (_) => const TakeawaySuccessScreen(),
            );
          }
          if (settings.name == AppRoutes.takeawayDashboard) {
            redirectedToDashboard = true;
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const Scaffold(body: Text('Takeaway Dashboard')),
            );
          }
          if (settings.name == AppRoutes.trackOrder) {
            redirectedToTrackOrder = true;
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const Scaffold(body: Text('Track Order')),
            );
          }
          if (settings.name == AppRoutes.home) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const Scaffold(body: Text('Home Screen')),
            );
          }
          return null;
        },
      ),
    );

    // Initial render
    await tester.pump();

    // Verify initial UI elements
    expect(find.text('Success'), findsOneWidget);
    expect(find.text('Your take-away is placed'), findsOneWidget);
    expect(
      find.text('Redirecting to Takeaway Dashboard in 3s...'),
      findsOneWidget,
    );

    // Advance 1 second -> 2s
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.text('Redirecting to Takeaway Dashboard in 2s...'),
      findsOneWidget,
    );

    // Advance 1 second -> 1s
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.text('Redirecting to Takeaway Dashboard in 1s...'),
      findsOneWidget,
    );

    // Advance final second to trigger redirect
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Must be redirected to takeawayDashboard, NEVER to trackOrder
    expect(redirectedToDashboard, isTrue);
    expect(redirectedToTrackOrder, isFalse);
    expect(find.text('Takeaway Dashboard'), findsOneWidget);
  });
}
