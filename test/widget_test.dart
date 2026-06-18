import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:girocall/core/design/theme.dart';
import 'package:girocall/core/constants.dart';

void main() {
  testWidgets('App theme renders brand title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const Scaffold(
            body: Center(child: Text(Constants.appName)),
          ),
        ),
      ),
    );

    expect(find.text('GiroCall'), findsOneWidget);
  });
}
