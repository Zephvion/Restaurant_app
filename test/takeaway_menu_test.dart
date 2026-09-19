import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/data/mock_data.dart';
import 'package:restaurant_app/screens/takeaway/takeaway_menu_screen.dart';
import 'package:restaurant_app/state/takeaway_controller.dart';

void main() {
  setUp(() {
    TakeawayController.instance.clearCart();
  });

  testWidgets('TakeawayMenuScreen category selection and search and cart modal', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: TakeawayMenuScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial header and Frequent order rail
    expect(find.text('Takeaway orders'), findsOneWidget);
    expect(find.text('Frequent order'), findsOneWidget);
    expect(find.text('Veg'), findsOneWidget);
    expect(find.text('Fish'), findsOneWidget);
    expect(find.text('Chicken'), findsOneWidget);

    // 1. Test Category Tab Switching: Tap 'Veg'
    await tester.tap(find.text('Veg'));
    await tester.pumpAndSettle();

    // Verify Veg Dishes section header appears
    expect(find.textContaining('Veg Dishes'), findsOneWidget);

    // Tap 'Chicken' tab
    await tester.tap(find.text('Chicken'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Chicken Dishes'), findsOneWidget);

    // Tap back to 'Frequent order'
    await tester.tap(find.text('Frequent order'));
    await tester.pumpAndSettle();
    expect(find.text('Combination Breakfast'), findsOneWidget);

    // 2. Test Takeaway Search
    final searchIcon = find.byIcon(Icons.search);
    expect(searchIcon, findsOneWidget);
    await tester.tap(searchIcon);
    await tester.pumpAndSettle();

    // Enter search text 'biriyani'
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'biriyani');
    await tester.pumpAndSettle();

    expect(find.textContaining('Search Results ("biriyani")'), findsOneWidget);

    // 3. Add an item to Takeaway Cart
    TakeawayController.instance.add(MockData.plainDosa);
    await tester.pumpAndSettle();

    // 4. Test Cart Icon at Top Right Corner
    final cartIcon = find.byIcon(Icons.shopping_cart_outlined);
    expect(cartIcon, findsWidgets);
    await tester.tap(cartIcon.first);
    await tester.pumpAndSettle();

    // Verify Takeaway Basket & Orders modal sheet opened and displays the food item
    expect(find.text('Takeaway Basket & Orders'), findsOneWidget);
    expect(find.textContaining('ITEMS IN BASKET'), findsOneWidget);
    expect(find.text('Plain Dosa'), findsWidgets);

    // Close the cart modal
    final closeButton = find.byIcon(Icons.close);
    await tester.tap(closeButton.last);
    await tester.pumpAndSettle();

    // If search mode is active, dismiss it to reveal the main menu sort row
    final backIcon = find.byIcon(Icons.arrow_back_ios_new);
    if (backIcon.evaluate().isNotEmpty) {
      await tester.tap(backIcon);
      await tester.pumpAndSettle();
    }

    // 5. Test SORT BY / ORDER BY Button
    final sortByButton = find.text('SORT BY');
    expect(sortByButton, findsOneWidget);
    await tester.tap(sortByButton);
    await tester.pumpAndSettle();

    // Verify Sort modal opens
    expect(find.text('Sort Dishes By'), findsOneWidget);
    expect(find.text('Price: Low to High'), findsOneWidget);
    expect(find.text('Price: High to Low'), findsOneWidget);
    expect(find.text('Customer Rating (4.5+)'), findsOneWidget);

    // Select 'Price: Low to High'
    await tester.tap(find.text('Price: Low to High'));
    await tester.pumpAndSettle();

    // Verify button updates to 'SORTED'
    expect(find.text('SORTED'), findsOneWidget);
  });
}

