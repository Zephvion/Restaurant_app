import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/main.dart';

void main() {
  testWidgets('PARAGON app smoke test — boots without error',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ParagonApp());
    expect(find.byType(ParagonApp), findsOneWidget);
  });
}
