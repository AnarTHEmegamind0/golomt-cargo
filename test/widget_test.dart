import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:core/features/auth/providers/auth_provider.dart';

import 'package:core/core/di/app_providers.dart';
import 'package:core/main.dart';

void main() {
  testWidgets('Login and tab navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(providers: AppProviders.build(), child: const MyApp()),
    );

    final loginButton = find.byKey(const ValueKey('login_submit'));
    await tester.scrollUntilVisible(loginButton, 240);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Нүүр'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('nav_profile')));
    await tester.pumpAndSettle();
    expect(find.text('Профайл'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('nav_settings')));
    await tester.pumpAndSettle();
    expect(find.text('Тохиргоо'), findsWidgets);

    final authProvider = tester
        .element(find.byType(MyApp))
        .read<AuthProvider>();
    await authProvider.logout();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(loginButton, 240);
    expect(loginButton, findsOneWidget);
  });
}
