import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/repositories/user_preferences_repository.dart';

import 'app_theme_state.dart';

/// Cubit that follows the repository-backed theme mode stream and exposes the
/// runtime theme state used by the material app.
@lazySingleton
class AppThemeCubit extends Cubit<AppThemeState> {
  AppThemeCubit(this._repository) : super(const AppThemeState.system()) {
    _themeSubscription = _repository.watchThemeMode().listen((mode) {
      emit(AppThemeState(mode));
    });
  }

  final UserPreferencesRepository _repository;
  StreamSubscription<UserThemeMode>? _themeSubscription;

  @override
  Future<void> close() {
    _themeSubscription?.cancel();
    return super.close();
  }
}
