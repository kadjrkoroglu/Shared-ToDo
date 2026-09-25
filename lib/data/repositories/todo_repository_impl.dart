import 'package:shared_todo/data/models/todo_list_model.dart';
import 'package:shared_todo/data/models/todo_model.dart';
import 'package:shared_todo/data/services/api_client.dart';
import 'package:shared_todo/domain/entities/todo.dart';
import 'package:shared_todo/domain/entities/todo_list.dart';
import 'package:shared_todo/domain/repositories/todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<TodoList>> getSharedLists() async {
    final json = await _api.get('/lists') as List<dynamic>;
    return json
        .map((e) => TodoListModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TodoList> getPersonalList() async {
    final json = await _api.get('/lists/personal') as Map<String, dynamic>;
    return TodoListModel.fromJson(json);
  }

  @override
  Future<TodoList> createSharedList(String name, String friendUniqueId) async {
    final json =
        await _api.post(
              '/lists',
              body: {'name': name, 'friendUniqueId': friendUniqueId},
            )
            as Map<String, dynamic>;
    return TodoListModel.fromJson(json);
  }

  @override
  Future<void> deleteList(int listId) async {
    await _api.delete('/lists/$listId');
  }

  @override
  Future<List<Todo>> getTodos(int listId) async {
    final json = await _api.get('/lists/$listId/todos') as List<dynamic>;
    return json
        .map((e) => TodoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Todo> addTodo(int listId, String title) async {
    final json =
        await _api.post('/lists/$listId/todos', body: {'title': title})
            as Map<String, dynamic>;
    return TodoModel.fromJson(json);
  }

  @override
  Future<Todo> setTodoCompleted(
    int listId,
    int todoId,
    bool isCompleted,
  ) async {
    final json =
        await _api.patch(
              '/lists/$listId/todos/$todoId',
              body: {'is_completed': isCompleted},
            )
            as Map<String, dynamic>;
    return TodoModel.fromJson(json);
  }

  @override
  Future<void> deleteTodo(int listId, int todoId) async {
    await _api.delete('/lists/$listId/todos/$todoId');
  }
}
