import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:girocall/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('GiroCall app flow', () {
    testWidgets('shows login screen when not authenticated', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('GiroCall'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });
  });
}
