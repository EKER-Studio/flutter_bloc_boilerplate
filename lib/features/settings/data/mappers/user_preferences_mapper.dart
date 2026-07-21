import '../../domain/entities/user_preferences.dart';
import '../models/user_preferences_model.dart';

/// Mapper extensions for [UserPreferencesModel].
extension UserPreferencesModelMapper on UserPreferencesModel {
  /// Converts a [UserPreferencesModel] to a [UserPreferences] entity.
  UserPreferences toEntity() {
    return UserPreferences(
      themeMode: _themeModeFromStorage(themeMode),
      isNotificationsEnabled: isNotificationsEnabled,
    );
  }
}

/// Mapper extensions for [UserPreferences] entity.
extension UserPreferencesMapper on UserPreferences {
  /// Converts a [UserPreferences] entity to a [UserPreferencesModel].
  UserPreferencesModel toModel() {
    return UserPreferencesModel()
      ..id = userPreferencesSingletonId
      ..themeMode = themeMode.name
      ..isNotificationsEnabled = isNotificationsEnabled;
  }
}

UserThemeMode _themeModeFromStorage(String value) {
  return UserThemeMode.values.firstWhere(
    (mode) => mode.name == value,
    orElse: () => UserThemeMode.system,
  );
}
