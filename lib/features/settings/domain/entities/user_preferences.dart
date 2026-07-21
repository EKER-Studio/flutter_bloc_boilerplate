/// Supported application theme modes.
enum UserThemeMode {
  /// Light theme.
  light,

  /// Dark theme.
  dark,

  /// System default theme.
  system,
}

/// Domain entity representing user preferences.
class UserPreferences {
  /// Creates a [UserPreferences] instance.
  const UserPreferences({
    required this.themeMode,
    required this.isNotificationsEnabled,
  });

  /// Creates default user preferences.
  factory UserPreferences.defaults() {
    return const UserPreferences(
      themeMode: UserThemeMode.system,
      isNotificationsEnabled: true,
    );
  }

  /// The selected theme mode.
  final UserThemeMode themeMode;

  /// Whether notifications are enabled.
  final bool isNotificationsEnabled;

  /// Creates a copy of this object with the given fields replaced with the new values.
  UserPreferences copyWith({
    UserThemeMode? themeMode,
    bool? isNotificationsEnabled,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UserPreferences &&
            other.themeMode == themeMode &&
            other.isNotificationsEnabled == isNotificationsEnabled;
  }

  @override
  int get hashCode => Object.hash(themeMode, isNotificationsEnabled);
}
