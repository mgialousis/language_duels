import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:language_duels/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('navigate to solo hub from home', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final soloButton = find.text('Solo Practice');
    expect(soloButton, findsOneWidget);

    await tester.tap(soloButton);
    await tester.pumpAndSettle();

    expect(find.text('Solo Practice'), findsWidgets);
  });
}
