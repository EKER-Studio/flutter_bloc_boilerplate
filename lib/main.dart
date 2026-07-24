import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/di/injection.dart';

/// Initializes dependency injection (including the pre-resolved Isar
/// database) and launches the app.
///
/// Wrapped in [runZonedGuarded] together with [FlutterError.onError] so that
/// uncaught errors — both inside and outside the Flutter widget tree — are
/// captured in one place. Errors are persisted via [log] so they survive
/// release-mode compilation; wire in a production crash reporter
/// (e.g. Sentry, Firebase Crashlytics) at the marked hooks below.
Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        // TODO: Send to production crash reporter (Sentry, Crashlytics, etc.)
        log(
          'Uncaught Flutter error',
          error: details.exception,
          stackTrace: details.stack,
        );
      };

      await _initHydratedStorage();
      await configureDependencies(Environment.prod);

      runApp(const App());
    },
    (Object error, StackTrace stack) {
      // TODO: Send to production crash reporter (Sentry, Crashlytics, etc.)
      log('Uncaught async error', error: error, stackTrace: stack);
    },
  );
}

Future<void> _initHydratedStorage() async {
  try {
    final storageDirectory = kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationDocumentsDirectory()).path,
          );
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: storageDirectory,
    );
  } catch (error) {
    log('HydratedStorage init failed: $error');
    try {
      final storageDirectory = kIsWeb
          ? HydratedStorageDirectory.web
          : HydratedStorageDirectory(
              (await getApplicationDocumentsDirectory()).path,
            );
      final storage = await HydratedStorage.build(
        storageDirectory: storageDirectory,
      );
      await storage.clear();
      HydratedBloc.storage = storage;
    } catch (_) {
      log('HydratedStorage recovery failed — running without persistence');
    }
  }
}
