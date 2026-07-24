import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/presentation/cubit/app_theme_cubit.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import 'settings_state.dart';

/// Cubit managing user preferences state.
@injectable
class SettingsCubit extends Cubit<SettingsState> {
  /// Creates a cubit backed by the given repository and immediately starts
  /// watching the preferences stream so the widget tree never sees a stale
  /// [SettingsInitial] state.
  SettingsCubit(this._repository, this._appThemeCubit)
    : super(const SettingsInitial()) {
    _startListening();
  }

  void _startListening() {
    _prefsSubscription = _repository.watch().listen(
      (prefs) {
        final shouldEmit =
            _lastKnownPreferences == null || _lastKnownPreferences != prefs;
        _lastKnownPreferences = prefs;
        if (shouldEmit) {
          emit(SettingsLoadSuccess(prefs));
        }
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

  final UserPreferencesRepository _repository;
  final AppThemeCubit _appThemeCubit;
  StreamSubscription<UserPreferences>? _prefsSubscription;
  UserPreferences? _lastKnownPreferences;

  /// Persists the selected theme mode and immediately applies it via
  /// [AppThemeCubit]. Reverts to the last known preferences on failure so
  /// the UI does not get stuck in an error state.
  Future<void> updateThemeMode(UserThemeMode mode) async {
    final snapshot = _lastKnownPreferences;
    final result = await _repository.updateThemeMode(mode);
    if (result.$1) {
      _appThemeCubit.setThemeMode(mode);
    } else if (snapshot != null) {
      emit(SettingsLoadSuccess(snapshot));
    } else {
      emit(SettingsLoadFailure(result.$2!));
    }
  }

  /// Persists the notifications toggle and immediately emits the updated
  /// preference, avoiding reliance on the Isar watch stream alone. Reverts to
  /// the last known preferences on failure.
  Future<void> updateNotificationsEnabled(bool enabled) async {
    final snapshot = _lastKnownPreferences;
    final result = await _repository.updateNotificationsEnabled(enabled);
    if (result.$1) {
      final updatedPreferences = (snapshot ?? UserPreferences.defaults())
          .copyWith(isNotificationsEnabled: enabled);
      _lastKnownPreferences = updatedPreferences;
      emit(SettingsLoadSuccess(updatedPreferences));
    } else if (result.$2 != null) {
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
