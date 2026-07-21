import 'package:injectable/injectable.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/settings/data/models/user_preferences_model.dart';
import '../../features/todos/data/models/todo_model.dart';

/// Registers the pre-resolved [Isar] database singleton.
@module
abstract class DatabaseModule {
  /// Opens (or retrieves) the Isar instance with all registered model schemas.
  @preResolve
  @singleton
  Future<Isar> get isar async {
    final directory = await getApplicationDocumentsDirectory();
    return Isar.getInstance() ??
        await Isar.open([
          TodoModelSchema,
          UserPreferencesModelSchema,
        ], directory: directory.path);
  }
}
