import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/routes/app_routes.dart';
import 'package:restaurant_app/screens/order_food/order_success_screen.dart';

void main() {
  testWidgets('OrderSuccessScreen shows details, countdown and auto-redirects to track order',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    bool redirectedToTrackOrder = false;
    String? capturedOrderId;

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoutes.orderSuccess,
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.orderSuccess) {
            return MaterialPageRoute(
              settings: const RouteSettings(
                name: AppRoutes.orderSuccess,
                arguments: 'PO_TEST_9988',
              ),
              builder: (_) => const OrderSuccessScreen(),
            );
          }
          if (settings.name == AppRoutes.trackOrder) {
            redirectedToTrackOrder = true;
            capturedOrderId = settings.arguments as String?;
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const Scaffold(body: Text('Track Order Screen')),
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

    // Initial pump
    await tester.pump();

    // Verify initial UI elements
    expect(find.text('Success'), findsOneWidget);
    expect(find.text('Your order is placed'), findsOneWidget);
    expect(find.text('ORDER ID: #PO_TEST_9988'), findsOneWidget);
    expect(
      find.text('Redirecting to delivery tracking in 3s...'),
      findsOneWidget,
    );
    expect(find.text('TRACK ORDER (3s)'), findsOneWidget);

    // Advance by 1 second
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.text('Redirecting to delivery tracking in 2s...'),
      findsOneWidget,
    );
    expect(find.text('TRACK ORDER (2s)'), findsOneWidget);

    // Advance by 1 second
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.text('Redirecting to delivery tracking in 1s...'),
      findsOneWidget,
    );
    expect(find.text('TRACK ORDER (1s)'), findsOneWidget);

    // Advance by 1 second to trigger auto redirect
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Verify auto redirection occurred
    expect(redirectedToTrackOrder, isTrue);
    expect(capturedOrderId, equals('PO_TEST_9988'));
    expect(find.text('Track Order Screen'), findsOneWidget);
  });

  testWidgets('OrderSuccessScreen manual Track Order button navigates immediately',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    bool navigatedToTrack = false;

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoutes.orderSuccess,
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.orderSuccess) {
            return MaterialPageRoute(
              settings: const RouteSettings(
                name: AppRoutes.orderSuccess,
                arguments: 'PO_MANUAL_1234',
              ),
              builder: (_) => const OrderSuccessScreen(),
            );
          }
          if (settings.name == AppRoutes.trackOrder) {
            navigatedToTrack = true;
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const Scaffold(body: Text('Track Order Screen')),
            );
          }
          return null;
        },
      ),
    );

    await tester.pump();
    expect(find.text('TRACK ORDER (3s)'), findsOneWidget);

    // Tap TRACK ORDER button manually without waiting for countdown
    await tester.tap(find.text('TRACK ORDER (3s)'));
    await tester.pumpAndSettle();

    expect(navigatedToTrack, isTrue);
    expect(find.text('Track Order Screen'), findsOneWidget);
  });

  testWidgets('OrderSuccessScreen manual Dashboard button cancels timer and navigates to home',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    bool navigatedToHome = false;

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoutes.orderSuccess,
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.orderSuccess) {
            return MaterialPageRoute(
              settings: const RouteSettings(
                name: AppRoutes.orderSuccess,
                arguments: 'PO_DASH_4567',
              ),
              builder: (_) => const OrderSuccessScreen(),
            );
          }
          if (settings.name == AppRoutes.home) {
            navigatedToHome = true;
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const Scaffold(body: Text('Home Screen')),
            );
          }
          if (settings.name == AppRoutes.trackOrder) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const Scaffold(body: Text('Track Order Screen')),
            );
          }
          return null;
        },
      ),
    );

    await tester.pump();

    // Tap REDIRECT TO DASHBOARD
    await tester.tap(find.text('REDIRECT TO DASHBOARD'));
    await tester.pumpAndSettle();

    expect(navigatedToHome, isTrue);
    expect(find.text('Home Screen'), findsOneWidget);

    // Wait past the original 3-second timer to ensure it was cancelled and doesn't push trackOrder
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Home Screen'), findsOneWidget);
  });
}
