import 'package:shared_todo/domain/entities/todo.dart';
import 'package:shared_todo/domain/repositories/todo_repository.dart';

class AddTodoUseCase {
  const AddTodoUseCase(this._repository);

  final TodoRepository _repository;

  Future<Todo> call(int listId, String title) =>
      _repository.addTodo(listId, title);
}
