import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/isar_provider.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../domain/repositories/todo_repository.dart';

part 'todo_repository_provider.g.dart';

/// Provider for the [TodoRepository].
@Riverpod(keepAlive: true)
TodoRepository todoRepository(Ref ref) {
  return TodoRepositoryImpl(ref.watch(isarProvider));
}
