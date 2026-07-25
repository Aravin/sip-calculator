import 'package:flutter_test/flutter_test.dart';

import 'package:sip_calculator/main.dart';

void main() {
  testWidgets('App displays home screen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pump();

    expect(find.text('Home'), findsOneWidget);
  });
}
