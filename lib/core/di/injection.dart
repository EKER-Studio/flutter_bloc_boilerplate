import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// Convenience alias for the global [GetIt] service locator.
final getIt = GetIt.instance;

@InjectableInit(preferRelativeImports: true, asExtension: true)
/// Initialises all GetIt dependencies for the given [env]ironment, including
/// pre-resolved async singletons such as the Isar database instance.
Future<void> configureDependencies(String env) async {
  await getIt.init(environment: env);
}
