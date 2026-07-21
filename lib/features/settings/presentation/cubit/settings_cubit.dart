import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import 'settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsInitial()) {
    _startWatching();
  }

  final UserPreferencesRepository _repository;
  StreamSubscription<UserPreferences>? _prefsSubscription;

  void _startWatching() {
    emit(const SettingsLoadInProgress());
    _prefsSubscription?.cancel();
    _prefsSubscription = _repository.watch().listen(
      (prefs) => emit(SettingsLoadSuccess(prefs)),
      onError: (Object error) =>
          emit(SettingsLoadFailure(DatabaseFailure(error.toString()))),
    );
  }

  Future<void> updateThemeMode(UserThemeMode mode) async {
    final result = await _repository.updateThemeMode(mode);
    if (result.$2 != null) {
      emit(SettingsLoadFailure(result.$2!));
    }
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    final result = await _repository.updateNotificationsEnabled(enabled);
    if (result.$2 != null) {
      emit(SettingsLoadFailure(result.$2!));
    }
  }

  @override
  Future<void> close() {
    _prefsSubscription?.cancel();
    return super.close();
  }
}
