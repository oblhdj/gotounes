import 'package:flutter_test/flutter_test.dart';

import 'package:gotounes/main.dart';

void main() {
  testWidgets('GoTounes shows home and bottom navigation', (tester) async {
    await tester.pumpWidget(const GoTounesApp());
    expect(find.text('GoTounes'), findsOneWidget);

    // Splash screen navigates after ~2 seconds.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Discover Tunisia'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
