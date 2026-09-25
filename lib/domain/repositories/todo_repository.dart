import 'package:shared_todo/domain/entities/todo.dart';
import 'package:shared_todo/domain/entities/todo_list.dart';

abstract class TodoRepository {
  Future<List<TodoList>> getSharedLists();
  Future<TodoList> getPersonalList();
  Future<TodoList> createSharedList(String name, String friendUniqueId);
  Future<void> deleteList(int listId);

  Future<List<Todo>> getTodos(int listId);
  Future<Todo> addTodo(int listId, String title);
  Future<Todo> setTodoCompleted(int listId, int todoId, bool isCompleted);
  Future<void> deleteTodo(int listId, int todoId);
}
