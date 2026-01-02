import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:core/core/di/app_providers.dart';
import 'package:core/main.dart';

void main() {
  testWidgets('Login and tab navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(providers: AppProviders.build(), child: const MyApp()),
    );

    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('login_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsWidgets);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);
  });
}
