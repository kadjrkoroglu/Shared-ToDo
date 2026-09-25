import 'package:flutter/foundation.dart';
import 'package:shared_todo/core/errors/app_exception.dart';
import 'package:shared_todo/domain/entities/todo.dart';
import 'package:shared_todo/domain/usecases/add_todo_usecase.dart';
import 'package:shared_todo/domain/usecases/delete_todo_usecase.dart';
import 'package:shared_todo/domain/usecases/get_todos_usecase.dart';
import 'package:shared_todo/domain/usecases/set_todo_completed_usecase.dart';

class TodoListViewModel extends ChangeNotifier {
  TodoListViewModel({
    required this.listId,
    required GetTodosUseCase getTodos,
    required AddTodoUseCase addTodo,
    required SetTodoCompletedUseCase setTodoCompleted,
    required DeleteTodoUseCase deleteTodo,
  }) : _getTodos = getTodos,
       _addTodo = addTodo,
       _setTodoCompleted = setTodoCompleted,
       _deleteTodo = deleteTodo;

  final int listId;
  final GetTodosUseCase _getTodos;
  final AddTodoUseCase _addTodo;
  final SetTodoCompletedUseCase _setTodoCompleted;
  final DeleteTodoUseCase _deleteTodo;

  List<Todo> todos = [];
  bool isLoading = true;
  String? errorMessage;

  /// Active tasks first, completed ones last.
  List<Todo> get sortedTodos {
    final sorted = [...todos];
    sorted.sort((a, b) {
      if (a.isCompleted == b.isCompleted) return 0;
      return a.isCompleted ? 1 : -1;
    });
    return sorted;
  }

  Future<void> load() async {
    errorMessage = null;
    try {
      todos = await _getTodos(listId);
    } on AppException catch (e) {
      errorMessage = e.message;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> addTodo(String title) => _run(() async {
    final todo = await _addTodo(listId, title);
    todos = [todo, ...todos];
  });

  Future<bool> toggle(Todo todo) => _run(() async {
    final updated = await _setTodoCompleted(listId, todo.id, !todo.isCompleted);
    todos = [for (final t in todos) t.id == updated.id ? updated : t];
  });

  Future<void> deleteTodo(Todo todo) async {
    todos = todos.where((t) => t.id != todo.id).toList();
    notifyListeners();

    final ok = await _run(() => _deleteTodo(listId, todo.id));
    if (!ok) {
      final message = errorMessage;
      await load();
      errorMessage ??= message;
      notifyListeners();
    }
  }

  Future<bool> _run(Future<void> Function() action) async {
    errorMessage = null;
    try {
      await action();
      return true;
    } on AppException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      notifyListeners();
    }
  }
}
