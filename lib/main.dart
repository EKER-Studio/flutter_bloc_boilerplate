import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import 'app.dart';
import 'core/di/injection.dart';

/// Initializes dependency injection (including the pre-resolved Isar
/// database) and launches the app.
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

      await configureDependencies(Environment.prod);

      runApp(const App());
    },
    (Object error, StackTrace stack) {
      debugPrint('Uncaught async error: $error\n$stack');
    },
  );
}
