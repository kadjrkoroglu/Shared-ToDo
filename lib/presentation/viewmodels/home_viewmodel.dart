import 'package:flutter/foundation.dart';
import 'package:shared_todo/core/errors/app_exception.dart';
import 'package:shared_todo/domain/entities/todo.dart';
import 'package:shared_todo/domain/entities/todo_list.dart';
import 'package:shared_todo/domain/usecases/add_todo_usecase.dart';
import 'package:shared_todo/domain/usecases/create_shared_list_usecase.dart';
import 'package:shared_todo/domain/usecases/delete_list_usecase.dart';
import 'package:shared_todo/domain/usecases/delete_todo_usecase.dart';
import 'package:shared_todo/domain/usecases/get_personal_list_usecase.dart';
import 'package:shared_todo/domain/usecases/get_shared_lists_usecase.dart';
import 'package:shared_todo/domain/usecases/get_todos_usecase.dart';
import 'package:shared_todo/domain/usecases/set_todo_completed_usecase.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required GetPersonalListUseCase getPersonalList,
    required GetSharedListsUseCase getSharedLists,
    required GetTodosUseCase getTodos,
    required AddTodoUseCase addTodo,
    required SetTodoCompletedUseCase setTodoCompleted,
    required DeleteTodoUseCase deleteTodo,
    required CreateSharedListUseCase createSharedList,
    required DeleteListUseCase deleteList,
  }) : _getPersonalList = getPersonalList,
       _getSharedLists = getSharedLists,
       _getTodos = getTodos,
       _addTodo = addTodo,
       _setTodoCompleted = setTodoCompleted,
       _deleteTodo = deleteTodo,
       _createSharedList = createSharedList,
       _deleteList = deleteList;

  final GetPersonalListUseCase _getPersonalList;
  final GetSharedListsUseCase _getSharedLists;
  final GetTodosUseCase _getTodos;
  final AddTodoUseCase _addTodo;
  final SetTodoCompletedUseCase _setTodoCompleted;
  final DeleteTodoUseCase _deleteTodo;
  final CreateSharedListUseCase _createSharedList;
  final DeleteListUseCase _deleteList;

  TodoList? _personalList;
  List<Todo> personalTodos = [];
  List<TodoList> sharedLists = [];
  bool isLoading = true;
  String? errorMessage;

  Future<void> load() async {
    errorMessage = null;
    try {
      final personal = await _getPersonalList();
      _personalList = personal;
      personalTodos = await _getTodos(personal.id);
      sharedLists = await _getSharedLists();
    } on AppException catch (e) {
      errorMessage = e.message;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> addPersonalTodo(String title) => _run(() async {
    final todo = await _addTodo(_personalList!.id, title);
    personalTodos = [todo, ...personalTodos];
  });

  Future<bool> togglePersonalTodo(Todo todo) => _run(() async {
    final updated = await _setTodoCompleted(
      todo.listId,
      todo.id,
      !todo.isCompleted,
    );
    personalTodos = [
      for (final t in personalTodos) t.id == updated.id ? updated : t,
    ];
  });

  /// Removes the todo right away so a swipe-to-dismiss row leaves the tree,
  /// then reloads if the server rejects the delete.
  Future<void> deletePersonalTodo(Todo todo) async {
    personalTodos = personalTodos.where((t) => t.id != todo.id).toList();
    notifyListeners();

    final ok = await _run(() => _deleteTodo(todo.listId, todo.id));
    if (!ok) {
      final message = errorMessage;
      await load();
      errorMessage ??= message;
      notifyListeners();
    }
  }

  Future<bool> createSharedList(String name, String friendUniqueId) =>
      _run(() async {
        final list = await _createSharedList(name, friendUniqueId);
        sharedLists = [list, ...sharedLists];
      });

  Future<bool> deleteSharedList(TodoList list) => _run(() async {
    await _deleteList(list.id);
    sharedLists = sharedLists.where((l) => l.id != list.id).toList();
  });

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
