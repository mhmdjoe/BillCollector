import 'package:flutter_test/flutter_test.dart';
import 'package:zalzoly/main.dart';

void main() {
  testWidgets('Bill collector app loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BillCollectorApp());
    expect(find.text('Bill Collector'), findsOneWidget);
  });
}
