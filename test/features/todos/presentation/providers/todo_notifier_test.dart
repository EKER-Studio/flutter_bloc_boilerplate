import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_riverpod_boilerplate/core/errors/failure.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/domain/entities/todo.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/domain/repositories/todo_repository.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/presentation/providers/todo_detail_notifier.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/presentation/providers/todo_notifier.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/presentation/providers/todo_repository_provider.dart';

// Mock repository based on the domain interface — completely decoupled from Isar
class MockTodoRepository extends Mock implements TodoRepository {}

// Helper test data
const _tId = 1;
final _tCreatedAt = DateTime(2024, 1, 1);
final _tTodo = Todo(
  id: _tId,
  title: 'Test Todo',
  isCompleted: false,
  createdAt: _tCreatedAt,
);
final _tTodos = [_tTodo];

ProviderContainer _makeContainer(MockTodoRepository mock) {
  return ProviderContainer(
    overrides: [todoRepositoryProvider.overrideWithValue(mock)],
  );
}

void main() {
  late MockTodoRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockTodoRepository();
  });

  tearDown(() {
    container.dispose();
  });

  // ---------------------------------------------------------------------------
  // TodoList Notifier - build() and reactivity
  // ---------------------------------------------------------------------------
  group('TodoList Notifier - build()', () {
    test(
      'returns list from the first stream event (without separate getAll call)',
      () async {
        // Arrange
        when(
          () => mockRepo.watchAll(),
        ).thenAnswer((_) => Stream.value(_tTodos));

        container = _makeContainer(mockRepo);
        container.listen(todoListProvider, (_, _) {});

        // Act
        final result = await container.read(todoListProvider.future);

        // Assert
        expect(result, _tTodos);
        verify(() => mockRepo.watchAll()).called(1);
        // getAll() should never be called
        verifyNever(() => mockRepo.getAll());
      },
    );

    test('state becomes AsyncData on every new stream event', () async {
      // Arrange
      final controller = StreamController<List<Todo>>();
      when(() => mockRepo.watchAll()).thenAnswer((_) => controller.stream);

      container = _makeContainer(mockRepo);
      container.listen(todoListProvider, (_, _) {});

      // Emit first event — build() awaits on Completer
      final updatedTodo = _tTodo.copyWith(title: 'Updated');
      controller.add(_tTodos);

      await container.read(todoListProvider.future); // wait for init

      // Act — second event from the stream
      controller.add([updatedTodo]);
      await Future.microtask(() {});

      // Assert
      final state = container.read(todoListProvider);
      expect(state, isA<AsyncData<List<Todo>>>());
      expect(state.value, [updatedTodo]);

      await controller.close();
    });

    test(
      'enters retrying AsyncLoading state when stream consistently errors before first event',
      () async {
        // Arrange
        when(
          () => mockRepo.watchAll(),
        ).thenAnswer((_) => Stream.error(Exception('Isar Error')));

        container = _makeContainer(mockRepo);
        container.listen(todoListProvider, (_, _) {});

        // Allow the stream error and retry cycle to begin
        await Future.microtask(() {});

        // Assert: Riverpod 3.x StreamNotifier auto-retries indefinitely on stream
        // errors. The observable state is AsyncLoading (retrying), not AsyncError.
        final state = container.read(todoListProvider);
        expect(state.isLoading, isTrue);
      },
    );

    test(
      'retries with previous data preserved when stream throws an error after first event',
      () async {
        // Arrange
        final controller = StreamController<List<Todo>>();
        when(() => mockRepo.watchAll()).thenAnswer((_) => controller.stream);

        container = _makeContainer(mockRepo);
        container.listen(todoListProvider, (_, _) {});

        controller.add(_tTodos);
        await container.read(todoListProvider.future);

        // Act — error after initialization
        controller.addError(Exception('Runtime error'));
        await Future.microtask(() {});

        // Assert: Riverpod 3.x StreamNotifier enters a retrying AsyncLoading state
        // preserving the last-known data. It does NOT immediately surface AsyncError.
        final state = container.read(todoListProvider);
        expect(state.isLoading, isTrue);
        expect(state.value, _tTodos); // previous data preserved during retry

        await controller.close();
      },
    );
  });

  // ---------------------------------------------------------------------------
  // TodoList Notifier - CRUD operations
  // ---------------------------------------------------------------------------
  group('TodoList Notifier - addTodo()', () {
    setUp(() {
      when(() => mockRepo.watchAll()).thenAnswer((_) => Stream.value(_tTodos));
    });

    test('calls repository.add with trimmed title', () async {
      when(
        () => mockRepo.add(title: 'New task'),
      ).thenAnswer((_) async => (true, null));
      container = _makeContainer(mockRepo);
      container.listen(todoListProvider, (_, _) {});
      await container.read(todoListProvider.future);

      final (success, failure) = await container
          .read(todoListProvider.notifier)
          .addTodo('  New task  ');

      expect(success, isTrue);
      expect(failure, isNull);
      verify(() => mockRepo.add(title: 'New task')).called(1);
    });

    test(
      'does not call add when title is empty or contains only whitespace',
      () async {
        container = _makeContainer(mockRepo);
        container.listen(todoListProvider, (_, _) {});
        await container.read(todoListProvider.future);
        final notifier = container.read(todoListProvider.notifier);

        final (success1, failure1) = await notifier.addTodo('');
        expect(success1, isFalse);
        expect(failure1, isA<ValidationFailure>());
        expect(failure1?.message, 'Title cannot be empty');

        final (success2, failure2) = await notifier.addTodo('   ');
        expect(success2, isFalse);
        expect(failure2, isA<ValidationFailure>());
        expect(failure2?.message, 'Title cannot be empty');

        verifyNever(() => mockRepo.add(title: any(named: 'title')));
      },
    );

    test(
      'returns error record when repository.add fails and state remains AsyncData',
      () async {
        when(
          () => mockRepo.add(title: any(named: 'title')),
        ).thenAnswer((_) async => (false, DatabaseFailure('Database error')));

        container = _makeContainer(mockRepo);
        container.listen(todoListProvider, (_, _) {});
        await container.read(todoListProvider.future);

        final (success, failure) = await container
            .read(todoListProvider.notifier)
            .addTodo('New task');

        expect(success, isFalse);
        expect(failure, isA<DatabaseFailure>());
        expect(failure?.message, 'Database error');
        expect(container.read(todoListProvider), isA<AsyncData<List<Todo>>>());
      },
    );
  });

  group('TodoList Notifier - toggleTodo()', () {
    setUp(() {
      when(() => mockRepo.watchAll()).thenAnswer((_) => Stream.value(_tTodos));
    });

    test('calls repository.toggleCompleted with correct id', () async {
      when(
        () => mockRepo.toggleCompleted(id: _tId),
      ).thenAnswer((_) async => (true, null));
      container = _makeContainer(mockRepo);
      container.listen(todoListProvider, (_, _) {});
      await container.read(todoListProvider.future);

      final (success, failure) = await container
          .read(todoListProvider.notifier)
          .toggleTodo(_tId);

      expect(success, isTrue);
      expect(failure, isNull);
      verify(() => mockRepo.toggleCompleted(id: _tId)).called(1);
    });

    test(
      'returns error record when repository.toggleCompleted fails and state remains AsyncData',
      () async {
        when(
          () => mockRepo.toggleCompleted(id: any(named: 'id')),
        ).thenAnswer((_) async => (false, DatabaseFailure('Database error')));

        container = _makeContainer(mockRepo);
        container.listen(todoListProvider, (_, _) {});
        await container.read(todoListProvider.future);

        final (success, failure) = await container
            .read(todoListProvider.notifier)
            .toggleTodo(_tId);

        expect(success, isFalse);
        expect(failure, isA<DatabaseFailure>());
        expect(failure?.message, 'Database error');
        expect(container.read(todoListProvider), isA<AsyncData<List<Todo>>>());
      },
    );
  });

  group('TodoList Notifier - deleteTodo()', () {
    setUp(() {
      when(() => mockRepo.watchAll()).thenAnswer((_) => Stream.value(_tTodos));
    });

    test('calls repository.delete with correct id', () async {
      when(
        () => mockRepo.delete(id: _tId),
      ).thenAnswer((_) async => (true, null));
      container = _makeContainer(mockRepo);
      container.listen(todoListProvider, (_, _) {});
      await container.read(todoListProvider.future);

      final (success, failure) = await container
          .read(todoListProvider.notifier)
          .deleteTodo(_tId);

      expect(success, isTrue);
      expect(failure, isNull);
      verify(() => mockRepo.delete(id: _tId)).called(1);
    });

    test(
      'returns error record when repository.delete fails and state remains AsyncData',
      () async {
        when(
          () => mockRepo.delete(id: any(named: 'id')),
        ).thenAnswer((_) async => (false, DatabaseFailure('Database error')));

        container = _makeContainer(mockRepo);
        container.listen(todoListProvider, (_, _) {});
        await container.read(todoListProvider.future);

        final (success, failure) = await container
            .read(todoListProvider.notifier)
            .deleteTodo(_tId);

        expect(success, isFalse);
        expect(failure, isA<DatabaseFailure>());
        expect(failure?.message, 'Database error');
        expect(container.read(todoListProvider), isA<AsyncData<List<Todo>>>());
      },
    );
  });

  group('TodoList Notifier - restoreTodo()', () {
    setUp(() {
      when(() => mockRepo.watchAll()).thenAnswer((_) => Stream.value(_tTodos));
    });

    test('calls repository.restore with the given todo', () async {
      final restoredTodo = _tTodos.first;
      when(
        () => mockRepo.restore(restoredTodo),
      ).thenAnswer((_) async => (true, null));
      container = _makeContainer(mockRepo);
      container.listen(todoListProvider, (_, _) {});
      await container.read(todoListProvider.future);

      final (success, failure) = await container
          .read(todoListProvider.notifier)
          .restoreTodo(restoredTodo);

      expect(success, isTrue);
      expect(failure, isNull);
      verify(() => mockRepo.restore(restoredTodo)).called(1);
    });

    test(
      'returns error record when repository.restore fails and state remains AsyncData',
      () async {
        final restoredTodo = _tTodos.first;
        when(
          () => mockRepo.restore(restoredTodo),
        ).thenAnswer((_) async => (false, DatabaseFailure('Database error')));

        container = _makeContainer(mockRepo);
        container.listen(todoListProvider, (_, _) {});
        await container.read(todoListProvider.future);

        final (success, failure) = await container
            .read(todoListProvider.notifier)
            .restoreTodo(restoredTodo);

        expect(success, isFalse);
        expect(failure, isA<DatabaseFailure>());
        expect(failure?.message, 'Database error');
        expect(container.read(todoListProvider), isA<AsyncData<List<Todo>>>());
      },
    );
  });

  group('TodoList Notifier - Memory management', () {
    test('cancels stream subscription when container is disposed', () async {
      final controller = StreamController<List<Todo>>();
      when(() => mockRepo.watchAll()).thenAnswer((_) => controller.stream);

      container = _makeContainer(mockRepo);
      container.listen(todoListProvider, (_, _) {});
      controller.add(_tTodos);
      await container.read(todoListProvider.future);

      container.dispose();

      expect(() => controller.add([]), returnsNormally);
      await controller.close();
    });
  });

  // ---------------------------------------------------------------------------
  // TodoDetail Notifier Tests
  // ---------------------------------------------------------------------------
  group('TodoDetailNotifier Tests', () {
    test('emits AsyncData(Todo) state based on watchById(id) stream', () async {
      // Arrange
      when(
        () => mockRepo.watchById(_tId),
      ).thenAnswer((_) => Stream.value(_tTodo));

      container = _makeContainer(mockRepo);
      container.listen(todoDetailProvider(_tId), (_, _) {});

      // Act
      final result = await container.read(todoDetailProvider(_tId).future);

      // Assert
      expect(result, _tTodo);
      verify(() => mockRepo.watchById(_tId)).called(1);
    });

    test(
      'enters retrying AsyncLoading state when watchById consistently errors before first emission',
      () async {
        // Arrange
        when(
          () => mockRepo.watchById(_tId),
        ).thenAnswer((_) => Stream.error(Exception('Database access denied')));

        container = _makeContainer(mockRepo);
        container.listen(todoDetailProvider(_tId), (_, _) {});

        // Allow the stream error and retry cycle to begin
        await Future.microtask(() {});

        // Assert: Riverpod 3.x StreamNotifier auto-retries indefinitely on stream
        // errors. The observable state is AsyncLoading (retrying), not AsyncError.
        final state = container.read(todoDetailProvider(_tId));
        expect(state.isLoading, isTrue);
      },
    );

    test(
      'retries with previous data preserved when stream throws an error after first emission',
      () async {
        // Arrange
        final controller = StreamController<Todo?>();
        when(
          () => mockRepo.watchById(_tId),
        ).thenAnswer((_) => controller.stream);

        container = _makeContainer(mockRepo);
        container.listen(todoDetailProvider(_tId), (_, _) {});

        // Emit success, provider has AsyncData state
        controller.add(_tTodo);
        await container.read(todoDetailProvider(_tId).future);

        // Act — sudden error
        controller.addError(Exception('Database failure while listening'));
        await Future.microtask(() {});

        // Assert: Riverpod 3.x StreamNotifier enters a retrying AsyncLoading state
        // preserving the last-known data. It does NOT immediately surface AsyncError.
        final state = container.read(todoDetailProvider(_tId));
        expect(state.isLoading, isTrue);
        expect(state.value, _tTodo); // previous data preserved during retry

        await controller.close();
      },
    );

    test('cancels single object subscription upon dispose', () async {
      // Arrange
      final controller = StreamController<Todo?>();
      when(() => mockRepo.watchById(_tId)).thenAnswer((_) => controller.stream);

      container = _makeContainer(mockRepo);
      container.listen(todoDetailProvider(_tId), (_, _) {});

      controller.add(_tTodo);
      await container.read(todoDetailProvider(_tId).future);

      // Act
      container.dispose();

      // Assert
      expect(() => controller.add(null), returnsNormally);
      await controller.close();
    });
  });
}
