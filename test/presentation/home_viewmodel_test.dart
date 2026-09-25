import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_todo/core/errors/app_exception.dart';
import 'package:shared_todo/domain/usecases/add_todo_usecase.dart';
import 'package:shared_todo/domain/usecases/create_shared_list_usecase.dart';
import 'package:shared_todo/domain/usecases/delete_list_usecase.dart';
import 'package:shared_todo/domain/usecases/delete_todo_usecase.dart';
import 'package:shared_todo/domain/usecases/get_personal_list_usecase.dart';
import 'package:shared_todo/domain/usecases/get_shared_lists_usecase.dart';
import 'package:shared_todo/domain/usecases/get_todos_usecase.dart';
import 'package:shared_todo/domain/usecases/set_todo_completed_usecase.dart';
import 'package:shared_todo/presentation/viewmodels/home_viewmodel.dart';

import '../helpers/mocks.dart';

void main() {
  late MockTodoRepository repository;
  late HomeViewModel viewModel;

  setUp(() {
    repository = MockTodoRepository();
    viewModel = HomeViewModel(
      getPersonalList: GetPersonalListUseCase(repository),
      getSharedLists: GetSharedListsUseCase(repository),
      getTodos: GetTodosUseCase(repository),
      addTodo: AddTodoUseCase(repository),
      setTodoCompleted: SetTodoCompletedUseCase(repository),
      deleteTodo: DeleteTodoUseCase(repository),
      createSharedList: CreateSharedListUseCase(repository),
      deleteList: DeleteListUseCase(repository),
    );

    when(
      () => repository.getPersonalList(),
    ).thenAnswer((_) async => personalList);
    when(
      () => repository.getTodos(10),
    ).thenAnswer((_) async => [todo(1), todo(2)]);
    when(
      () => repository.getSharedLists(),
    ).thenAnswer((_) async => [sharedList]);
  });

  test('load fetches personal todos and shared lists', () async {
    await viewModel.load();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.personalTodos, hasLength(2));
    expect(viewModel.sharedLists, [sharedList]);
    expect(viewModel.errorMessage, isNull);
  });

  test('load exposes the error message on failure', () async {
    when(
      () => repository.getPersonalList(),
    ).thenThrow(const NetworkException());

    await viewModel.load();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.errorMessage, 'No connection to the server');
  });

  test('addPersonalTodo puts the new todo first', () async {
    await viewModel.load();
    when(() => repository.addTodo(10, 'new')).thenAnswer((_) async => todo(3));

    final ok = await viewModel.addPersonalTodo('new');

    expect(ok, isTrue);
    expect(viewModel.personalTodos.first.id, 3);
    expect(viewModel.personalTodos, hasLength(3));
  });

  test('togglePersonalTodo replaces the todo with the server copy', () async {
    await viewModel.load();
    when(
      () => repository.setTodoCompleted(10, 1, true),
    ).thenAnswer((_) async => todo(1, done: true));

    await viewModel.togglePersonalTodo(todo(1));

    expect(
      viewModel.personalTodos.firstWhere((t) => t.id == 1).isCompleted,
      isTrue,
    );
  });

  test('deletePersonalTodo removes the todo immediately', () async {
    await viewModel.load();
    when(() => repository.deleteTodo(10, 1)).thenAnswer((_) async {});

    await viewModel.deletePersonalTodo(todo(1));

    expect(viewModel.personalTodos.map((t) => t.id), [2]);
    verify(() => repository.deleteTodo(10, 1)).called(1);
  });

  test(
    'deletePersonalTodo reloads and keeps the error when the API fails',
    () async {
      await viewModel.load();
      when(
        () => repository.deleteTodo(10, 1),
      ).thenThrow(const ApiException('Nope'));

      await viewModel.deletePersonalTodo(todo(1));

      expect(viewModel.personalTodos, hasLength(2));
      expect(viewModel.errorMessage, 'Nope');
    },
  );

  test('createSharedList adds the list on success', () async {
    await viewModel.load();
    when(
      () => repository.createSharedList('Trip', 'ABC123'),
    ).thenAnswer((_) async => sharedList);

    final ok = await viewModel.createSharedList('Trip', 'ABC123');

    expect(ok, isTrue);
    expect(viewModel.sharedLists, hasLength(2));
  });

  test('createSharedList reports an unknown friend', () async {
    await viewModel.load();
    when(
      () => repository.createSharedList(any(), any()),
    ).thenThrow(const ApiException('Friend not found', statusCode: 404));

    final ok = await viewModel.createSharedList('Trip', 'ZZZZZZ');

    expect(ok, isFalse);
    expect(viewModel.errorMessage, 'Friend not found');
    expect(viewModel.sharedLists, hasLength(1));
  });

  test('deleteSharedList removes the list', () async {
    await viewModel.load();
    when(() => repository.deleteList(20)).thenAnswer((_) async {});

    await viewModel.deleteSharedList(sharedList);

    expect(viewModel.sharedLists, isEmpty);
  });
}
