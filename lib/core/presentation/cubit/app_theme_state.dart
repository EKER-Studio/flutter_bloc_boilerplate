/// Application-wide theme mode persisted via hydrated_bloc.
enum AppThemeMode { light, dark, system }

/// Serializable state for [AppThemeCubit].
class AppThemeState {
  const AppThemeState(this.mode);

  const AppThemeState.system() : mode = AppThemeMode.system;

  final AppThemeMode mode;

  factory AppThemeState.fromJson(Map<String, dynamic> json) {
    return AppThemeState(AppThemeMode.values[json['mode'] as int]);
  }

  Map<String, dynamic> toJson() => {'mode': mode.index};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppThemeState && other.mode == mode;

  @override
  int get hashCode => mode.hashCode;
}
