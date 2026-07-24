import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:flutter_bloc_boilerplate/core/presentation/cubit/app_theme_cubit.dart';
import 'package:flutter_bloc_boilerplate/core/presentation/cubit/app_theme_state.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';

/// In-memory [Storage] for use in tests so [AppThemeCubit] (a [HydratedCubit])
/// can be instantiated without real file-system or web storage.
class _TestStorage implements Storage {
  final _store = <String, dynamic>{};

  @override
  dynamic read(String key) => _store[key];

  @override
  Future<void> write(String key, dynamic value) async {
    _store[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }

  @override
  Future<void> close() async {}
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
    setUp(() {
      HydratedBloc.storage = _TestStorage();
    });

    test('initial state is system', () {
      final cubit = AppThemeCubit();
      expect(cubit.state.mode, UserThemeMode.system);
      cubit.close();
    });

    test('setThemeMode emits new state', () {
      final cubit = AppThemeCubit();
      expect(cubit.state.mode, UserThemeMode.system);

      cubit.setThemeMode(UserThemeMode.dark);
      expect(cubit.state.mode, UserThemeMode.dark);

      cubit.setThemeMode(UserThemeMode.light);
      expect(cubit.state.mode, UserThemeMode.light);

      cubit.close();
    });

    test('setThemeMode with same value emits immediately', () {
      final cubit = AppThemeCubit();
      cubit.setThemeMode(UserThemeMode.dark);
      expect(cubit.state.mode, UserThemeMode.dark);
      cubit.close();
    });

    test('fromJson in cubit falls back when storage is corrupt', () {
      final cubit = AppThemeCubit();
      final recovered = cubit.fromJson({'mode': 'not_an_int'});
      expect(recovered, isNotNull);
      expect(recovered!.mode, UserThemeMode.system);
      cubit.close();
    });

    test('toJson serializes correctly', () {
      final cubit = AppThemeCubit();
      cubit.setThemeMode(UserThemeMode.light);
      final json = cubit.toJson(cubit.state);
      expect(json, {'mode': 0});
      cubit.close();
    });
  });
}
