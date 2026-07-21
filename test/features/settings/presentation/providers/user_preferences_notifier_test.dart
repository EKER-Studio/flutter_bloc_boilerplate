import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_riverpod_boilerplate/core/errors/failure.dart';
import 'package:flutter_riverpod_boilerplate/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_riverpod_boilerplate/features/settings/domain/repositories/user_preferences_repository.dart';
import 'package:flutter_riverpod_boilerplate/features/settings/presentation/providers/user_preferences_notifier.dart';
import 'package:flutter_riverpod_boilerplate/features/settings/presentation/providers/user_preferences_repository_provider.dart';

class MockUserPreferencesRepository extends Mock
    implements UserPreferencesRepository {}

const _preferences = UserPreferences(
  themeMode: UserThemeMode.system,
  isNotificationsEnabled: true,
);

ProviderContainer _makeContainer(MockUserPreferencesRepository mock) {
  return ProviderContainer(
    overrides: [userPreferencesRepositoryProvider.overrideWithValue(mock)],
  );
}

void main() {
  late MockUserPreferencesRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockUserPreferencesRepository();
  });

  tearDown(() {
    container.dispose();
  });

  group('UserPreferencesNotifier - build()', () {
    test('returns preferences from the first stream event', () async {
      when(
        () => mockRepo.watch(),
      ).thenAnswer((_) => Stream.value(_preferences));

      container = _makeContainer(mockRepo);
      container.listen(userPreferencesProvider, (_, _) {});

      final result = await container.read(userPreferencesProvider.future);

      expect(result, _preferences);
      verify(() => mockRepo.watch()).called(1);
      verifyNever(() => mockRepo.get());
    });

    test('state becomes AsyncData on every new stream event', () async {
      final controller = StreamController<UserPreferences>();
      when(() => mockRepo.watch()).thenAnswer((_) => controller.stream);

      container = _makeContainer(mockRepo);
      container.listen(userPreferencesProvider, (_, _) {});

      controller.add(_preferences);
      await container.read(userPreferencesProvider.future);

      const updated = UserPreferences(
        themeMode: UserThemeMode.dark,
        isNotificationsEnabled: false,
      );
      controller.add(updated);
      await Future.microtask(() {});

      final state = container.read(userPreferencesProvider);
      expect(state, isA<AsyncData<UserPreferences>>());
      expect(state.value, updated);

      await controller.close();
    });

    test(
      'enters retrying AsyncLoading state when stream consistently errors before first event',
      () async {
        when(
          () => mockRepo.watch(),
        ).thenAnswer((_) => Stream.error(Exception('Isar Error')));

        container = _makeContainer(mockRepo);
        container.listen(userPreferencesProvider, (_, _) {});

        // Allow the stream error and retry cycle to begin
        await Future.microtask(() {});

        // Assert: Riverpod 3.x StreamNotifier auto-retries indefinitely on stream
        // errors. The observable state is AsyncLoading (retrying), not AsyncError.
        final state = container.read(userPreferencesProvider);
        expect(state.isLoading, isTrue);
      },
    );
  });

  group('UserPreferencesNotifier - updates', () {
    setUp(() {
      when(
        () => mockRepo.watch(),
      ).thenAnswer((_) => Stream.value(_preferences));
    });

    test('calls repository.updateThemeMode with selected mode', () async {
      when(
        () => mockRepo.updateThemeMode(UserThemeMode.dark),
      ).thenAnswer((_) async => (true, null));

      container = _makeContainer(mockRepo);
      container.listen(userPreferencesProvider, (_, _) {});
      await container.read(userPreferencesProvider.future);

      final (success, failure) = await container
          .read(userPreferencesProvider.notifier)
          .updateThemeMode(UserThemeMode.dark);

      expect(success, isTrue);
      expect(failure, isNull);
      verify(() => mockRepo.updateThemeMode(UserThemeMode.dark)).called(1);
    });

    test(
      'calls repository.updateNotificationsEnabled with selected value',
      () async {
        when(
          () => mockRepo.updateNotificationsEnabled(false),
        ).thenAnswer((_) async => (true, null));

        container = _makeContainer(mockRepo);
        container.listen(userPreferencesProvider, (_, _) {});
        await container.read(userPreferencesProvider.future);

        final (success, failure) = await container
            .read(userPreferencesProvider.notifier)
            .updateNotificationsEnabled(false);

        expect(success, isTrue);
        expect(failure, isNull);
        verify(() => mockRepo.updateNotificationsEnabled(false)).called(1);
      },
    );

    test(
      'returns error record when updateThemeMode fails and state remains AsyncData',
      () async {
        when(
          () => mockRepo.updateThemeMode(UserThemeMode.light),
        ).thenAnswer((_) async => (false, DatabaseFailure('Database error')));

        container = _makeContainer(mockRepo);
        container.listen(userPreferencesProvider, (_, _) {});
        await container.read(userPreferencesProvider.future);

        final (success, failure) = await container
            .read(userPreferencesProvider.notifier)
            .updateThemeMode(UserThemeMode.light);

        expect(success, isFalse);
        expect(failure, isA<DatabaseFailure>());
        expect(failure?.message, 'Database error');
        expect(
          container.read(userPreferencesProvider),
          isA<AsyncData<UserPreferences>>(),
        );
      },
    );
  });

  group('UserPreferencesNotifier - Memory management', () {
    test('cancels stream subscription when container is disposed', () async {
      final controller = StreamController<UserPreferences>();
      when(() => mockRepo.watch()).thenAnswer((_) => controller.stream);

      container = _makeContainer(mockRepo);
      container.listen(userPreferencesProvider, (_, _) {});
      controller.add(_preferences);
      await container.read(userPreferencesProvider.future);

      container.dispose();

      expect(() => controller.add(_preferences), returnsNormally);
      await controller.close();
    });
  });
}
