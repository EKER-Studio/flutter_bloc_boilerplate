import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';
import 'package:flutter_bloc_boilerplate/core/presentation/cubit/app_theme_cubit.dart';
import 'package:flutter_bloc_boilerplate/core/presentation/cubit/app_theme_state.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/repositories/user_preferences_repository.dart';

class _TestThemeRepository implements UserPreferencesRepository {
  _TestThemeRepository(this._themeModeStream);

  final Stream<UserThemeMode> _themeModeStream;

  @override
  Stream<UserPreferences> watch() => const Stream.empty();

  @override
  Stream<UserThemeMode> watchThemeMode() => _themeModeStream;

  @override
  Future<UserPreferences> get() async => UserPreferences.defaults();

  @override
  Future<(bool success, Failure? failure)> updateThemeMode(
    UserThemeMode themeMode,
  ) async => (true, null);

  @override
  Future<(bool success, Failure? failure)> updateNotificationsEnabled(
    bool isEnabled,
  ) async => (true, null);
}

void main() {
  group('AppThemeState', () {
    group('toJson / fromJson round-trip', () {
      test('light mode round-trips correctly', () {
        const original = AppThemeState(UserThemeMode.light);
        final json = original.toJson();
        final restored = AppThemeState.fromJson(json);
        expect(restored.mode, UserThemeMode.light);
      });

      test('dark mode round-trips correctly', () {
        const original = AppThemeState(UserThemeMode.dark);
        final json = original.toJson();
        final restored = AppThemeState.fromJson(json);
        expect(restored.mode, UserThemeMode.dark);
      });

      test('system mode round-trips correctly', () {
        const original = AppThemeState(UserThemeMode.system);
        final json = original.toJson();
        final restored = AppThemeState.fromJson(json);
        expect(restored.mode, UserThemeMode.system);
      });
    });

    group('fromJson malformed data gracefully falls back to system', () {
      test('missing key returns system', () {
        final state = AppThemeState.fromJson({});
        expect(state.mode, UserThemeMode.system);
      });

      test('null value returns system', () {
        final state = AppThemeState.fromJson({'mode': null});
        expect(state.mode, UserThemeMode.system);
      });

      test('string value returns system', () {
        final state = AppThemeState.fromJson({'mode': 'light'});
        expect(state.mode, UserThemeMode.system);
      });

      test('double value returns system', () {
        final state = AppThemeState.fromJson({'mode': 1.5});
        expect(state.mode, UserThemeMode.system);
      });

      test('negative index returns system', () {
        final state = AppThemeState.fromJson({'mode': -1});
        expect(state.mode, UserThemeMode.system);
      });

      test('index equal to enum length returns system', () {
        final state = AppThemeState.fromJson({
          'mode': UserThemeMode.values.length,
        });
        expect(state.mode, UserThemeMode.system);
      });

      test('index far above enum length returns system', () {
        final state = AppThemeState.fromJson({'mode': 999});
        expect(state.mode, UserThemeMode.system);
      });
    });
  });

  group('AppThemeCubit', () {
    test(
      'initial state is system when no theme stream value is emitted yet',
      () {
        final controller = StreamController<UserThemeMode>();
        final cubit = AppThemeCubit(_TestThemeRepository(controller.stream));
        expect(cubit.state.mode, UserThemeMode.system);
        controller.close();
        cubit.close();
      },
    );

    test('reacts to theme mode updates from the repository stream', () async {
      final controller = StreamController<UserThemeMode>();
      final cubit = AppThemeCubit(_TestThemeRepository(controller.stream));

      controller.add(UserThemeMode.dark);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.mode, UserThemeMode.dark);

      controller.add(UserThemeMode.light);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.mode, UserThemeMode.light);

      controller.close();
      cubit.close();
    });
  });
}
