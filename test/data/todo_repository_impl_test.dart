import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_todo/data/repositories/todo_repository_impl.dart';

import '../helpers/mocks.dart';

void main() {
  late MockApiClient api;
  late TodoRepositoryImpl repository;

  setUp(() {
    api = MockApiClient();
    repository = TodoRepositoryImpl(api);
  });

  Map<String, dynamic> listJson(int id, {bool personal = false}) => {
    'id': id,
    'name': 'List $id',
    'ownerId': 1,
    'isPersonal': personal,
    'members': [userJson()],
  };

  test('getSharedLists parses lists with their members', () async {
    when(() => api.get('/lists')).thenAnswer((_) async => [listJson(1)]);

    final lists = await repository.getSharedLists();

    expect(lists, hasLength(1));
    expect(lists.first.name, 'List 1');
    expect(lists.first.members.first.email, 'a@a.com');
  });

  test('getPersonalList flags the list as personal', () async {
    when(
      () => api.get('/lists/personal'),
    ).thenAnswer((_) async => listJson(5, personal: true));

    final list = await repository.getPersonalList();

    expect(list.isPersonal, isTrue);
  });

  test('createSharedList sends the name and friend id', () async {
    when(
      () => api.post('/lists', body: any(named: 'body')),
    ).thenAnswer((_) async => listJson(2));

    await repository.createSharedList('Trip', 'ABC123');

    verify(
      () => api.post(
        '/lists',
        body: {'name': 'Trip', 'friendUniqueId': 'ABC123'},
      ),
    ).called(1);
  });

  test('deleteList calls the delete endpoint', () async {
    when(() => api.delete('/lists/3')).thenAnswer((_) async => {});

    await repository.deleteList(3);

    verify(() => api.delete('/lists/3')).called(1);
  });

  test('getTodos maps API fields to Todo', () async {
    when(
      () => api.get('/lists/10/todos'),
    ).thenAnswer((_) async => [todoJson(1, done: true), todoJson(2)]);

    final todos = await repository.getTodos(10);

    expect(todos.map((t) => t.id), [1, 2]);
    expect(todos.first.isCompleted, isTrue);
    expect(todos.last.isCompleted, isFalse);
  });

  test('addTodo posts the title to the list', () async {
    when(
      () => api.post('/lists/10/todos', body: any(named: 'body')),
    ).thenAnswer((_) async => todoJson(7));

    final created = await repository.addTodo(10, 'task 7');

    expect(created.id, 7);
    verify(
      () => api.post('/lists/10/todos', body: {'title': 'task 7'}),
    ).called(1);
  });

  test('setTodoCompleted patches is_completed', () async {
    when(
      () => api.patch('/lists/10/todos/7', body: any(named: 'body')),
    ).thenAnswer((_) async => todoJson(7, done: true));

    final updated = await repository.setTodoCompleted(10, 7, true);

    expect(updated.isCompleted, isTrue);
    verify(
      () => api.patch('/lists/10/todos/7', body: {'is_completed': true}),
    ).called(1);
  });

  test('deleteTodo calls the nested delete endpoint', () async {
    when(() => api.delete('/lists/10/todos/7')).thenAnswer((_) async => {});

    await repository.deleteTodo(10, 7);

    verify(() => api.delete('/lists/10/todos/7')).called(1);
  });
}
