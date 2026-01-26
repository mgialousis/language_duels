import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:language_duels/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches to home', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('Start New Duel'), findsOneWidget);
  });
}
