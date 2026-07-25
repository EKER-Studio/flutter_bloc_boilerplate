import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/entities/todo.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/repositories/todo_repository.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/bloc/todo_bloc.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/bloc/todo_event.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/bloc/todo_state.dart';

import '../../../../helpers/fake_todo_repository.dart';

/// A repository that fails the first call to a given operation.
class _FailingOnceTodoRepository implements TodoRepository {
  _FailingOnceTodoRepository(this._inner, this._failOnOp);

  final FakeTodoRepository _inner;
  final String _failOnOp;
  var _callCount = 0;

  @override
  Stream<List<Todo>> watchAll() => _inner.watchAll();

  @override
  Stream<Todo?> watchById(int id) => _inner.watchById(id);

  @override
  Future<List<Todo>> getAll() => _inner.getAll();

  @override
  Future<(bool success, Failure? failure)> add({required String title}) async {
    if (_failOnOp == 'add') {
      _callCount++;
      if (_callCount == 1) return (false, const DatabaseFailure('add failed'));
    }
    return _inner.add(title: title);
  }

  @override
  Future<(bool success, Failure? failure)> toggleCompleted({
    required int id,
  }) async {
    if (_failOnOp == 'toggle') {
      _callCount++;
      if (_callCount == 1) {
        return (false, const DatabaseFailure('toggle failed'));
      }
    }
    return _inner.toggleCompleted(id: id);
  }

  @override
  Future<(bool success, Failure? failure)> delete({required int id}) async {
    if (_failOnOp == 'delete') {
      _callCount++;
      if (_callCount == 1) {
        return (false, const DatabaseFailure('delete failed'));
      }
    }
    return _inner.delete(id: id);
  }

  @override
  Future<(bool success, Failure? failure)> restore(Todo todo) async {
    if (_failOnOp == 'restore') {
      _callCount++;
      if (_callCount == 1) {
        return (false, const DatabaseFailure('restore failed'));
      }
    }
    return _inner.restore(todo);
  }
}

final _created = Todo(
  id: 1,
  title: 'Test',
  isCompleted: false,
  createdAt: DateTime(2026),
);

final _todoFirst = Todo(
  id: 1,
  title: 'First',
  isCompleted: false,
  createdAt: DateTime(2026),
);

final _todoSecond = Todo(
  id: 2,
  title: 'Second',
  isCompleted: false,
  createdAt: DateTime(2026),
);

final _second = Todo(
  id: 2,
  title: 'Second',
  isCompleted: false,
  createdAt: DateTime(2026),
);

void main() {
  group('TodoBloc', () {
    late FakeTodoRepository repository;
    final repos = <FakeTodoRepository>[];

    setUp(() {
      repository = FakeTodoRepository();
      repos.clear();
    });

    tearDown(() {
      for (final r in repos) {
        r.dispose();
      }
      repository.dispose();
    });

    test('initial state is TodoInitial', () {
      expect(TodoBloc(repository).state, const TodoInitial());
    });

    blocTest<TodoBloc, TodoState>(
      'WatchTodos emits LoadInProgress then LoadSuccess',
      build: () => TodoBloc(repository),
      act: (bloc) => bloc.add(const WatchTodos()),
      expect: () => [const TodoLoadInProgress(), isA<TodoLoadSuccess>()],
    );

    group('TodoAdded', () {
      blocTest<TodoBloc, TodoState>(
        'adds a new todo to the list',
        build: () => TodoBloc(repository),
        act: (bloc) async {
          bloc.add(const WatchTodos());
          // Let the initial stream yield settle before mutating.
          await Future<void>.delayed(Duration.zero);
          bloc.add(const TodoAdded('Buy milk'));
        },
        expect: () => [
          const TodoLoadInProgress(),
          isA<TodoLoadSuccess>().having(
            (s) => s.todos.length,
            'initial count',
            0,
          ),
          isA<TodoLoadSuccess>().having(
            (s) => s.todos.length,
            'after add count',
            1,
          ),
        ],
      );
    });

    group('TodoToggled', () {
      blocTest<TodoBloc, TodoState>(
        'toggles the completed state of a todo',
        build: () {
          final repo = FakeTodoRepository(initialTodos: [_created]);
          repos.add(repo);
          return TodoBloc(repo);
        },
        act: (bloc) async {
          bloc.add(const WatchTodos());
          await Future<void>.delayed(Duration.zero);
          bloc.add(const TodoToggled(1));
        },
        expect: () => [
          const TodoLoadInProgress(),
          isA<TodoLoadSuccess>().having(
            (s) => s.todos.first.isCompleted,
            'initial isCompleted',
            false,
          ),
          isA<TodoLoadSuccess>().having(
            (s) => s.todos.first.isCompleted,
            'after toggle isCompleted',
            true,
          ),
        ],
      );
    });

    group('TodoDeleted', () {
      blocTest<TodoBloc, TodoState>(
        'deletes a todo and tracks it for undo',
        build: () {
          final repo = FakeTodoRepository(initialTodos: [_created]);
          repos.add(repo);
          return TodoBloc(repo);
        },
        act: (bloc) async {
          bloc.add(const WatchTodos());
          await Future<void>.delayed(Duration.zero);
          bloc.add(TodoDeleted(_created));
        },
        expect: () => [
          const TodoLoadInProgress(),
          isA<TodoLoadSuccess>()
              .having((s) => s.todos.length, 'initial count', 1)
              .having((s) => s.lastDeletedTodo, 'initial undo', isNull),
          isA<TodoLoadSuccess>()
              .having((s) => s.todos.length, 'after delete count', 0)
              .having((s) => s.lastDeletedTodo, 'after delete undo', isNotNull),
        ],
      );

      blocTest<TodoBloc, TodoState>(
        'rapid consecutive deletes: queue preserves each deleted todo',
        build: () {
          final repo = FakeTodoRepository(initialTodos: [_created, _second]);
          repos.add(repo);
          return TodoBloc(repo);
        },
        act: (bloc) async {
          bloc.add(const WatchTodos());
          await Future<void>.delayed(Duration.zero);
          bloc.add(TodoDeleted(_second));
          await Future<void>.delayed(Duration.zero);
          bloc.add(TodoDeleted(_created));
        },
        expect: () => [
          const TodoLoadInProgress(),
          isA<TodoLoadSuccess>().having(
            (s) => s.todos.length,
            'initial count',
            2,
          ),
          isA<TodoLoadSuccess>()
              .having((s) => s.todos.length, 'after delete 2 count', 1)
              .having((s) => s.lastDeletedTodo!.id, 'last deleted', 2),
          isA<TodoLoadSuccess>()
              .having((s) => s.todos.length, 'after delete 1 count', 0)
              .having((s) => s.lastDeletedTodo!.id, 'last deleted', 1),
        ],
      );

      blocTest<TodoBloc, TodoState>(
        'delete failure emits TodoLoadFailure and handles empty queue',
        build: () {
          final fakeRepo = FakeTodoRepository(initialTodos: [_created]);
          repos.add(fakeRepo);
          return TodoBloc(_FailingOnceTodoRepository(fakeRepo, 'delete'));
        },
        act: (bloc) async {
          bloc.add(const WatchTodos());
          await Future<void>.delayed(Duration.zero);
          bloc.add(TodoDeleted(_created));
        },
        expect: () => [
          const TodoLoadInProgress(),
          isA<TodoLoadSuccess>(),
          isA<TodoLoadFailure>().having(
            (s) => s.failure.message,
            'message',
            contains('delete'),
          ),
        ],
      );
    });

    group('TodoRestored', () {
      blocTest<TodoBloc, TodoState>(
        'restores the most recently deleted todo',
        build: () {
          final repo = FakeTodoRepository(initialTodos: [_created]);
          repos.add(repo);
          return TodoBloc(repo);
        },
        act: (bloc) async {
          bloc.add(const WatchTodos());
          await Future<void>.delayed(Duration.zero);
          bloc.add(TodoDeleted(_created));
          await Future<void>.delayed(Duration.zero);
          bloc.add(TodoRestored(_created.id));
        },
        expect: () => [
          const TodoLoadInProgress(),
          isA<TodoLoadSuccess>().having(
            (s) => s.todos.length,
            'initial count',
            1,
          ),
          isA<TodoLoadSuccess>().having(
            (s) => s.todos.length,
            'after delete count',
            0,
          ),
          isA<TodoLoadSuccess>()
              .having((s) => s.todos.length, 'after restore count', 1)
              .having((s) => s.lastDeletedTodo, 'undo cleared', isNull),
        ],
      );

      blocTest<TodoBloc, TodoState>(
        'TodoRestored with empty queue does nothing',
        build: () => TodoBloc(repository),
        act: (bloc) async {
          bloc.add(const WatchTodos());
          await Future<void>.delayed(Duration.zero);
          bloc.add(TodoRestored(42));
        },
        expect: () => [const TodoLoadInProgress(), isA<TodoLoadSuccess>()],
      );

      blocTest<TodoBloc, TodoState>(
        'TodoRestored restores the correct item by id, not just the last',
        build: () {
          final repo = FakeTodoRepository(
            initialTodos: [_todoFirst, _todoSecond],
          );
          repos.add(repo);
          return TodoBloc(repo);
        },
        act: (bloc) async {
          bloc.add(const WatchTodos());
          await Future<void>.delayed(Duration.zero);
          bloc.add(TodoDeleted(_todoFirst));
          await Future<void>.delayed(Duration.zero);
          bloc.add(TodoDeleted(_todoSecond));
          await Future<void>.delayed(Duration.zero);
          // Restore the first deleted todo (_todoFirst) even though it's no
          // longer at the tail of the queue.
          bloc.add(TodoRestored(_todoFirst.id));
        },
        expect: () => [
          const TodoLoadInProgress(),
          isA<TodoLoadSuccess>().having(
            (s) => s.todos.length,
            'initial count',
            2,
          ),
          isA<TodoLoadSuccess>().having(
            (s) => s.todos.length,
            'after first delete count',
            1,
          ),
          isA<TodoLoadSuccess>().having(
            (s) => s.todos.length,
            'after second delete count',
            0,
          ),
          isA<TodoLoadSuccess>()
              .having((s) => s.todos.length, 'after restore count', 1)
              .having((s) => s.todos.first.id, 'restored id', _todoFirst.id),
        ],
      );

      blocTest<TodoBloc, TodoState>(
        'TodoRestored with non-existent id does nothing',
        build: () {
          final repo = FakeTodoRepository(initialTodos: [_created]);
          repos.add(repo);
          return TodoBloc(repo);
        },
        act: (bloc) async {
          bloc.add(const WatchTodos());
          await Future<void>.delayed(Duration.zero);
          bloc.add(TodoDeleted(_created));
          await Future<void>.delayed(Duration.zero);
          bloc.add(TodoRestored(999));
        },
        expect: () => [
          const TodoLoadInProgress(),
          isA<TodoLoadSuccess>().having(
            (s) => s.todos.length,
            'initial count',
            1,
          ),
          isA<TodoLoadSuccess>().having(
            (s) => s.todos.length,
            'after delete count',
            0,
          ),
          // TodoRestored with non-existent id does nothing — no extra emit.
        ],
      );
    });

    group('Error handling', () {
      blocTest<TodoBloc, TodoState>(
        'add failure emits TodoLoadFailure',
        build: () {
          final fakeRepo = FakeTodoRepository();
          repos.add(fakeRepo);
          return TodoBloc(_FailingOnceTodoRepository(fakeRepo, 'add'));
        },
        act: (bloc) async {
          bloc.add(const WatchTodos());
          await Future<void>.delayed(Duration.zero);
          bloc.add(const TodoAdded('fail'));
        },
        expect: () => [
          const TodoLoadInProgress(),
          isA<TodoLoadSuccess>(),
          isA<TodoLoadFailure>().having(
            (s) => s.failure.message,
            'message',
            contains('add'),
          ),
        ],
      );

      blocTest<TodoBloc, TodoState>(
        'toggle failure emits TodoLoadFailure',
        build: () {
          final fakeRepo = FakeTodoRepository(initialTodos: [_created]);
          repos.add(fakeRepo);
          return TodoBloc(_FailingOnceTodoRepository(fakeRepo, 'toggle'));
        },
        act: (bloc) async {
          bloc.add(const WatchTodos());
          await Future<void>.delayed(Duration.zero);
          bloc.add(const TodoToggled(1));
        },
        expect: () => [
          const TodoLoadInProgress(),
          isA<TodoLoadSuccess>(),
          isA<TodoLoadFailure>().having(
            (s) => s.failure.message,
            'message',
            contains('toggle'),
          ),
        ],
      );
    });

    blocTest<TodoBloc, TodoState>(
      'close() cancels subscription and does not emit after',
      build: () => TodoBloc(repository),
      act: (bloc) async {
        bloc.add(const WatchTodos());
        await Future<void>.delayed(Duration.zero);
        await bloc.close();
      },
      expect: () => [const TodoLoadInProgress(), isA<TodoLoadSuccess>()],
    );
  });
}
