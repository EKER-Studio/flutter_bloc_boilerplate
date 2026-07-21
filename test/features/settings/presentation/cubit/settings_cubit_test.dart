import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/repositories/user_preferences_repository.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/cubit/settings_state.dart';

import '../../../../helpers/fake_user_preferences_repository.dart';

/// A repository that fails on the first attempt of [updateThemeMode] with the
/// given [failure], then succeeds on subsequent calls.
class _FailingOnceThemeRepository implements UserPreferencesRepository {
  _FailingOnceThemeRepository(this._inner, this._failure);

  final FakeUserPreferencesRepository _inner;
  final Failure _failure;
  var _callCount = 0;

  @override
  Stream<UserPreferences> watch() => _inner.watch();

  @override
  Future<UserPreferences> get() => _inner.get();

  @override
  Future<(bool success, Failure? failure)> updateThemeMode(
    UserThemeMode mode,
  ) async {
    _callCount++;
    if (_callCount == 1) return (false, _failure);
    return _inner.updateThemeMode(mode);
  }

  @override
  Future<(bool success, Failure? failure)> updateNotificationsEnabled(
    bool isEnabled,
  ) async {
    return _inner.updateNotificationsEnabled(isEnabled);
  }
}

/// A repository whose watch stream emits an error on the first data event.
class _ErrorStreamRepository implements UserPreferencesRepository {
  @override
  Stream<UserPreferences> watch() async* {
    throw const DatabaseFailure('stream error');
  }

  @override
  Future<UserPreferences> get() async => UserPreferences.defaults();

  @override
  Future<(bool success, Failure? failure)> updateThemeMode(
    UserThemeMode mode,
  ) async {
    return (true, null);
  }

  @override
  Future<(bool success, Failure? failure)> updateNotificationsEnabled(
    bool isEnabled,
  ) async {
    return (true, null);
  }
}

void main() {
  late FakeUserPreferencesRepository repository;

  setUp(() {
    repository = FakeUserPreferencesRepository();
  });

  tearDown(() {
    repository.dispose();
  });

  group('SettingsCubit', () {
    test('initial state is SettingsInitial', () {
      expect(SettingsCubit(repository).state, const SettingsInitial());
    });

    blocTest<SettingsCubit, SettingsState>(
      'init() emits LoadInProgress then LoadSuccess with defaults',
      build: () => SettingsCubit(repository),
      act: (cubit) => cubit.init(),
      expect: () => [
        const SettingsLoadInProgress(),
        isA<SettingsLoadSuccess>(),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'updateThemeMode: watch stream emits updated theme',
      build: () {
        final cubit = SettingsCubit(repository);
        cubit.init();
        return cubit;
      },
      act: (cubit) async {
        // Give the init() stream callback time to fire so _lastKnownPrefs is set.
        await Future<void>.delayed(Duration.zero);
        await cubit.updateThemeMode(UserThemeMode.dark);
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<SettingsLoadSuccess>().having(
          (s) => s.preferences.themeMode,
          'themeMode',
          UserThemeMode.system,
        ),
        isA<SettingsLoadSuccess>().having(
          (s) => s.preferences.themeMode,
          'themeMode',
          UserThemeMode.dark,
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'updateNotificationsEnabled: watch stream emits updated preference',
      build: () {
        final cubit = SettingsCubit(repository);
        cubit.init();
        return cubit;
      },
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.updateNotificationsEnabled(false);
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<SettingsLoadSuccess>().having(
          (s) => s.preferences.isNotificationsEnabled,
          'isNotificationsEnabled',
          true,
        ),
        isA<SettingsLoadSuccess>().having(
          (s) => s.preferences.isNotificationsEnabled,
          'isNotificationsEnabled',
          false,
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'updateThemeMode rolls back to last known preferences on failure',
      build: () {
        final failingRepo = _FailingOnceThemeRepository(
          repository,
          const DatabaseFailure('write error'),
        );
        final cubit = SettingsCubit(failingRepo);
        cubit.init();
        return cubit;
      },
      act: (cubit) async {
        // Wait for init() stream callback to populate _lastKnownPreferences.
        await Future<void>.delayed(Duration.zero);
        await cubit.updateThemeMode(UserThemeMode.dark);
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<SettingsLoadSuccess>().having(
          (s) => s.preferences.themeMode,
          'themeMode',
          UserThemeMode.system,
        ),
        isA<SettingsLoadSuccess>().having(
          (s) => s.preferences.themeMode,
          'themeMode',
          UserThemeMode.system,
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'watch stream error without snapshot emits SettingsLoadFailure',
      build: () => SettingsCubit(_ErrorStreamRepository()),
      act: (cubit) => cubit.init(),
      expect: () => [
        const SettingsLoadInProgress(),
        isA<SettingsLoadFailure>(),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'close() cancels subscription and does not emit after',
      build: () => SettingsCubit(repository),
      act: (cubit) async {
        cubit.init();
        await Future<void>.delayed(Duration.zero);
        await cubit.close();
      },
      expect: () => [
        const SettingsLoadInProgress(),
        isA<SettingsLoadSuccess>(),
      ],
    );
  });
}
