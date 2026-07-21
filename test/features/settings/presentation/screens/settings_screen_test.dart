import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod_boilerplate/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_riverpod_boilerplate/features/settings/presentation/providers/user_preferences_repository_provider.dart';
import 'package:flutter_riverpod_boilerplate/features/settings/presentation/screens/settings_screen.dart';

import '../../../../helpers/fake_user_preferences_repository.dart';

void main() {
  late FakeUserPreferencesRepository repository;

  setUp(() {
    repository = FakeUserPreferencesRepository();
  });

  tearDown(() {
    repository.dispose();
  });

  testWidgets('Settings screen updates theme mode and notifications', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userPreferencesRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect((await repository.get()).themeMode, UserThemeMode.dark);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect((await repository.get()).isNotificationsEnabled, isFalse);
  });
}
