import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';

/// Serializable state for [AppThemeCubit].
class AppThemeState {
  const AppThemeState(this.mode);

  const AppThemeState.system() : mode = UserThemeMode.system;

  final UserThemeMode mode;

  factory AppThemeState.fromJson(Map<String, dynamic> json) {
    final index = json['mode'];
    if (index is int && index >= 0 && index < UserThemeMode.values.length) {
      return AppThemeState(UserThemeMode.values[index]);
    }
    return const AppThemeState.system();
  }

  Map<String, dynamic> toJson() => {'mode': mode.index};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppThemeState && other.mode == mode;

  @override
  int get hashCode => mode.hashCode;
}
