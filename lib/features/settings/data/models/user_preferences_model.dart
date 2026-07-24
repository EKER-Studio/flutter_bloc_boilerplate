import 'package:isar_community/isar.dart';

part 'user_preferences_model.g.dart';

/// The default ID used for the user preferences singleton.
const userPreferencesSingletonId = 0;

/// Persistent representation of [UserPreferences].
@collection
class UserPreferencesModel {
  /// The singleton ID for user preferences.
  Id id = userPreferencesSingletonId;

  /// The selected theme mode as a string. Defaults to `'system'` so that
  /// newly created / migrated rows always have a valid value.
  String themeMode = 'system';

  /// Whether notifications are enabled.
  bool isNotificationsEnabled = true;
}
