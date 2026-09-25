import 'package:shared_todo/domain/entities/todo.dart';
import 'package:shared_todo/domain/repositories/todo_repository.dart';

class SetTodoCompletedUseCase {
  const SetTodoCompletedUseCase(this._repository);

  final TodoRepository _repository;

  Future<Todo> call(int listId, int todoId, bool isCompleted) =>
      _repository.setTodoCompleted(listId, todoId, isCompleted);
}
