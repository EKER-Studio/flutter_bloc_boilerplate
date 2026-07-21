import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_boilerplate/features/settings/presentation/screens/settings_screen.dart';

void main() {
  testWidgets('Settings screen renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SettingsScreen()),
    );

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Settings view — BLoC integration pending'), findsOneWidget);
  });
}
