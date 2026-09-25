import 'package:shared_todo/domain/repositories/todo_repository.dart';

class DeleteTodoUseCase {
  const DeleteTodoUseCase(this._repository);

  final TodoRepository _repository;

  Future<void> call(int listId, int todoId) =>
      _repository.deleteTodo(listId, todoId);
}
