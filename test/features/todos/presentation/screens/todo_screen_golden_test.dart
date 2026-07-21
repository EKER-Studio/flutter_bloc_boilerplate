@Tags(['golden'])
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod_boilerplate/app.dart';
import 'package:flutter_riverpod_boilerplate/features/settings/presentation/providers/user_preferences_repository_provider.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/presentation/providers/todo_repository_provider.dart';

import '../../../../helpers/fake_todo_repository.dart';
import '../../../../helpers/fake_user_preferences_repository.dart';

// Deterministic clock used to produce stable golden screenshots.
DateTime _frozenClock() => DateTime(2025, 1, 1, 10, 0);

void main() {
  late FakeTodoRepository repository;
  late FakeUserPreferencesRepository userPreferencesRepository;

  setUp(() {
    repository = FakeTodoRepository(clock: _frozenClock);
    userPreferencesRepository = FakeUserPreferencesRepository();
  });

  tearDown(() {
    repository.dispose();
    userPreferencesRepository.dispose();
  });

  group('Todo Screen Golden Tests', () {
    testWidgets('Initial empty state', (tester) async {
      // 1. Freeze device dimensions (e.g., standard phone profile, 1080x2400)
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;

      // 2. Build widget with injected fake repository
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoRepositoryProvider.overrideWithValue(repository),
            userPreferencesRepositoryProvider.overrideWithValue(
              userPreferencesRepository,
            ),
          ],
          child: const App(),
        ),
      );

      // 3. Wait for all frames to settle (all loading finished)
      await tester.pumpAndSettle();

      // 4. Compare rendered pixels against the reference file
      await expectLater(
        find.byType(App),
        matchesGoldenFile('goldens/todo_screen_empty.png'),
      );

      // Cleanup after test
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }, skip: !Platform.isMacOS);

    testWidgets('Populated list state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;

      // Add deterministic tasks using the frozen clock
      await repository.add(title: 'Write documentation');
      await repository.add(title: 'Test the application');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoRepositoryProvider.overrideWithValue(repository),
            userPreferencesRepositoryProvider.overrideWithValue(
              userPreferencesRepository,
            ),
          ],
          child: const App(),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(App),
        matchesGoldenFile('goldens/todo_screen_populated.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }, skip: !Platform.isMacOS);
}
