import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'features/settings/data/models/user_preferences_model.dart';
import 'features/todos/data/models/todo_model.dart';

/// Initializes Isar, configures dependency injection, and launches the app.
///
/// Wrapped in [runZonedGuarded] together with [FlutterError.onError] so that
/// uncaught errors — both inside and outside the Flutter widget tree — are
/// captured in one place instead of crashing silently in release mode. This
/// is intentionally left as a single `debugPrint` hook: wire in your crash
/// reporter of choice (e.g. Sentry, Firebase Crashlytics) here.
Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('Uncaught Flutter error: ${details.exceptionAsString()}');
      };

      configureDependencies(Environment.prod);

      final directory = await getApplicationDocumentsDirectory();
      final isar =
          Isar.getInstance() ??
          await Isar.open([
            TodoModelSchema,
            UserPreferencesModelSchema,
          ], directory: directory.path);

      GetIt.instance.registerSingletonAsync<Isar>(() async => isar);

      runApp(const App());
    },
    (Object error, StackTrace stack) {
      debugPrint('Uncaught async error: $error\n$stack');
    },
  );
}
