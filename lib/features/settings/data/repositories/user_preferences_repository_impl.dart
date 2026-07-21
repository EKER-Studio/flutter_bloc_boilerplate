import 'dart:async';
import 'dart:developer';

import 'package:injectable/injectable.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../mappers/user_preferences_mapper.dart';
import '../models/user_preferences_model.dart';

/// Implementation of [UserPreferencesRepository] using Isar.
@LazySingleton(as: UserPreferencesRepository)
class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  /// Creates a new [UserPreferencesRepositoryImpl] with the given Isar instance.
  UserPreferencesRepositoryImpl(this._isar);

  final Isar _isar;

  UserPreferences _mapOrDefault(UserPreferencesModel? model) {
    return model?.toEntity() ?? UserPreferences.defaults();
  }

  Future<UserPreferencesModel> _getOrCreateModel() async {
    final existing = await _isar.userPreferencesModels.get(
      userPreferencesSingletonId,
    );

    if (existing != null) {
      return existing;
    }

    final model = UserPreferences.defaults().toModel();
    await _isar.userPreferencesModels.put(model);
    return model;
  }

  @override
  Stream<UserPreferences> watch() {
    return _watchWithReconnect(
      () => _isar.userPreferencesModels
          .watchObject(userPreferencesSingletonId, fireImmediately: true)
          .map(_mapOrDefault),
      'watch',
    );
  }

  /// Wraps an Isar watch stream in an auto-reconnecting loop so transient
  /// database errors don't permanently terminate the subscription.
  Stream<T> _watchWithReconnect<T>(
    Stream<T> Function() createStream,
    String label,
  ) async* {
    while (true) {
      try {
        yield* createStream();
        return;
      } catch (e, s) {
        log(
          'Isar watch stream "$label" error, reconnecting in 1s',
          error: e,
          stackTrace: s,
        );
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
  }

  @override
  Future<UserPreferences> get() async {
    try {
      final model = await _isar.userPreferencesModels.get(
        userPreferencesSingletonId,
      );
      return _mapOrDefault(model);
    } catch (e) {
      throw DatabaseFailure('Failed to load preferences: ${e.toString()}');
    }
  }

  @override
  Future<(bool success, Failure? failure)> updateThemeMode(
    UserThemeMode themeMode,
  ) async {
    try {
      await _isar.writeTxn(() async {
        final model = await _getOrCreateModel();
        model.themeMode = themeMode.name;
        await _isar.userPreferencesModels.put(model);
      });
      return (true, null);
    } on IsarError catch (e) {
      return (false, DatabaseFailure(e.message));
    } catch (e) {
      return (false, DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<(bool success, Failure? failure)> updateNotificationsEnabled(
    bool isEnabled,
  ) async {
    try {
      await _isar.writeTxn(() async {
        final model = await _getOrCreateModel();
        model.isNotificationsEnabled = isEnabled;
        await _isar.userPreferencesModels.put(model);
      });
      return (true, null);
    } on IsarError catch (e) {
      return (false, DatabaseFailure(e.message));
    } catch (e) {
      return (false, DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
