import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_todo/core/errors/app_exception.dart';
import 'package:shared_todo/domain/usecases/add_todo_usecase.dart';
import 'package:shared_todo/domain/usecases/delete_todo_usecase.dart';
import 'package:shared_todo/domain/usecases/get_todos_usecase.dart';
import 'package:shared_todo/domain/usecases/set_todo_completed_usecase.dart';
import 'package:shared_todo/presentation/viewmodels/todo_list_viewmodel.dart';

import '../helpers/mocks.dart';

void main() {
  late MockTodoRepository repository;
  late TodoListViewModel viewModel;

  setUp(() {
    repository = MockTodoRepository();
    viewModel = TodoListViewModel(
      listId: 20,
      getTodos: GetTodosUseCase(repository),
      addTodo: AddTodoUseCase(repository),
      setTodoCompleted: SetTodoCompletedUseCase(repository),
      deleteTodo: DeleteTodoUseCase(repository),
    );
  });

  test('load fetches the todos of the list', () async {
    when(
      () => repository.getTodos(20),
    ).thenAnswer((_) async => [todo(1, listId: 20)]);

    await viewModel.load();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.todos, hasLength(1));
  });

  test('load exposes errors', () async {
    when(() => repository.getTodos(20)).thenThrow(const NetworkException());

    await viewModel.load();

    expect(viewModel.errorMessage, isNotNull);
    expect(viewModel.todos, isEmpty);
  });

  test('sortedTodos puts completed tasks last', () async {
    when(() => repository.getTodos(20)).thenAnswer(
      (_) async => [
        todo(1, listId: 20, done: true),
        todo(2, listId: 20),
        todo(3, listId: 20, done: true),
        todo(4, listId: 20),
      ],
    );
    await viewModel.load();

    expect(viewModel.sortedTodos.map((t) => t.id), [2, 4, 1, 3]);
  });

  test('addTodo adds to the top of the list', () async {
    when(
      () => repository.getTodos(20),
    ).thenAnswer((_) async => [todo(1, listId: 20)]);
    when(
      () => repository.addTodo(20, 'x'),
    ).thenAnswer((_) async => todo(2, listId: 20));
    await viewModel.load();

    expect(await viewModel.addTodo('x'), isTrue);
    expect(viewModel.todos.first.id, 2);
  });

  test('addTodo failure keeps the list and reports the error', () async {
    when(
      () => repository.getTodos(20),
    ).thenAnswer((_) async => [todo(1, listId: 20)]);
    when(
      () => repository.addTodo(any(), any()),
    ).thenThrow(const ApiException('Not authorized', statusCode: 403));
    await viewModel.load();

    expect(await viewModel.addTodo('x'), isFalse);
    expect(viewModel.todos, hasLength(1));
    expect(viewModel.errorMessage, 'Not authorized');
  });

  test('toggle updates the todo', () async {
    when(
      () => repository.getTodos(20),
    ).thenAnswer((_) async => [todo(1, listId: 20)]);
    when(
      () => repository.setTodoCompleted(20, 1, true),
    ).thenAnswer((_) async => todo(1, listId: 20, done: true));
    await viewModel.load();

    await viewModel.toggle(todo(1, listId: 20));

    expect(viewModel.todos.single.isCompleted, isTrue);
  });

  test('deleteTodo removes the todo and calls the API', () async {
    when(
      () => repository.getTodos(20),
    ).thenAnswer((_) async => [todo(1, listId: 20), todo(2, listId: 20)]);
    when(() => repository.deleteTodo(20, 1)).thenAnswer((_) async {});
    await viewModel.load();

    await viewModel.deleteTodo(todo(1, listId: 20));

    expect(viewModel.todos.map((t) => t.id), [2]);
    verify(() => repository.deleteTodo(20, 1)).called(1);
  });
}
