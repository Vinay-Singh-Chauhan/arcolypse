import 'package:flutter_test/flutter_test.dart';
import 'package:arcolypse/main.dart';

void main() {
  testWidgets('Arcolypse App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ArcolypseApp());

    // Verify main menu appears
    expect(find.text('ARCOLYPSE'), findsOneWidget);
  });
}
