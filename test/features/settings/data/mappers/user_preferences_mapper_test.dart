import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod_boilerplate/features/settings/data/mappers/user_preferences_mapper.dart';
import 'package:flutter_riverpod_boilerplate/features/settings/data/models/user_preferences_model.dart';
import 'package:flutter_riverpod_boilerplate/features/settings/domain/entities/user_preferences.dart';

void main() {
  group('UserPreferencesMapper', () {
    test(
      'toEntity() converts UserPreferencesModel to UserPreferences entity correctly',
      () {
        // Arrange
        final model = UserPreferencesModel()
          ..themeMode = 'dark'
          ..isNotificationsEnabled = false;

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.themeMode, UserThemeMode.dark);
        expect(entity.isNotificationsEnabled, false);
      },
    );

    test(
      'toEntity() defaults to system theme mode if storage value is invalid',
      () {
        // Arrange
        final model = UserPreferencesModel()
          ..themeMode = 'invalid_mode'
          ..isNotificationsEnabled = true;

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.themeMode, UserThemeMode.system);
      },
    );

    test(
      'toModel() converts UserPreferences entity to UserPreferencesModel correctly',
      () {
        // Arrange
        const entity = UserPreferences(
          themeMode: UserThemeMode.light,
          isNotificationsEnabled: true,
        );

        // Act
        final model = entity.toModel();

        // Assert
        expect(model.id, userPreferencesSingletonId);
        expect(model.themeMode, 'light');
        expect(model.isNotificationsEnabled, true);
      },
    );
  });
}
