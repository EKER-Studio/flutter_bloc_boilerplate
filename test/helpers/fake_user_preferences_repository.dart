import 'dart:async';

import 'package:flutter_riverpod_boilerplate/core/errors/failure.dart';
import 'package:flutter_riverpod_boilerplate/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_riverpod_boilerplate/features/settings/domain/repositories/user_preferences_repository.dart';

/// In-memory implementation of [UserPreferencesRepository] for use in tests.
///
/// Emits reactive updates through an internal [StreamController]. An optional
/// initial [UserPreferences] can be provided to pre-seed the repository state.
class FakeUserPreferencesRepository implements UserPreferencesRepository {
  /// Creates a [FakeUserPreferencesRepository].
  ///
  /// [initialPreferences] seeds the initial state. Defaults to
  /// [UserPreferences.defaults] when omitted.
  FakeUserPreferencesRepository({UserPreferences? initialPreferences})
    : _preferences = initialPreferences ?? UserPreferences.defaults();

  UserPreferences _preferences;
  final _streamController = StreamController<UserPreferences>.broadcast();

  void _emit() {
    _streamController.add(_preferences);
  }

  /// Releases the internal stream resources. Call in [tearDown].
  void dispose() {
    _streamController.close();
  }

  @override
  Stream<UserPreferences> watch() async* {
    yield _preferences;
    yield* _streamController.stream;
  }

  @override
  Future<UserPreferences> get() async {
    return _preferences;
  }

  @override
  Future<(bool success, Failure? failure)> updateThemeMode(
    UserThemeMode themeMode,
  ) async {
    _preferences = _preferences.copyWith(themeMode: themeMode);
    _emit();
    return (true, null);
  }

  @override
  Future<(bool success, Failure? failure)> updateNotificationsEnabled(
    bool isEnabled,
  ) async {
    _preferences = _preferences.copyWith(isNotificationsEnabled: isEnabled);
    _emit();
    return (true, null);
  }
}
