import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import 'settings_state.dart';

/// Cubit managing user preferences state.
@injectable
class SettingsCubit extends Cubit<SettingsState> {
  /// Creates a cubit backed by the given repository.
  SettingsCubit(this._repository) : super(const SettingsInitial());

  final UserPreferencesRepository _repository;
  StreamSubscription<UserPreferences>? _prefsSubscription;
  UserPreferences? _lastKnownPreferences;

  /// Initialises the cubit: starts watching the preferences stream and emits
  /// the current value. Must be called once immediately after creation.
  void init() {
    emit(const SettingsLoadInProgress());
    _prefsSubscription?.cancel();
    _prefsSubscription = _repository.watch().listen(
      (prefs) {
        _lastKnownPreferences = prefs;
        emit(SettingsLoadSuccess(prefs));
      },
      onError: (Object error) {
        if (_lastKnownPreferences != null) {
          emit(SettingsLoadSuccess(_lastKnownPreferences!));
        } else {
          emit(SettingsLoadFailure(DatabaseFailure(error.toString())));
        }
      },
    );
  }

  /// Persists the selected theme mode. Reverts to the last known preferences
  /// on failure so the UI does not get stuck in an error state.
  Future<void> updateThemeMode(UserThemeMode mode) async {
    final snapshot = _lastKnownPreferences;
    final result = await _repository.updateThemeMode(mode);
    if (result.$2 != null) {
      if (snapshot != null) {
        emit(SettingsLoadSuccess(snapshot));
      } else {
        emit(SettingsLoadFailure(result.$2!));
      }
    }
  }

  /// Persists the notifications toggle. Reverts to the last known preferences
  /// on failure so the UI does not get stuck in an error state.
  Future<void> updateNotificationsEnabled(bool enabled) async {
    final snapshot = _lastKnownPreferences;
    final result = await _repository.updateNotificationsEnabled(enabled);
    if (result.$2 != null) {
      if (snapshot != null) {
        emit(SettingsLoadSuccess(snapshot));
      } else {
        emit(SettingsLoadFailure(result.$2!));
      }
    }
  }

  @override
  Future<void> close() {
    _prefsSubscription?.cancel();
    return super.close();
  }
}
