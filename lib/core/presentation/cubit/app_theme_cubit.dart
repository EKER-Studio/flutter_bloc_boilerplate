import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';

import 'app_theme_state.dart';

/// Singleton cubit that persists the user's theme mode choice to disk via
/// [HydratedCubit]. Acts as the single source of truth for the current
/// appearance mode throughout the app.
@lazySingleton
class AppThemeCubit extends HydratedCubit<AppThemeState> {
  AppThemeCubit() : super(const AppThemeState.system());

  void setThemeMode(UserThemeMode mode) => emit(AppThemeState(mode));

  @override
  AppThemeState? fromJson(Map<String, dynamic> json) =>
      AppThemeState.fromJson(json);

  @override
  Map<String, dynamic> toJson(AppThemeState state) => state.toJson();
}
