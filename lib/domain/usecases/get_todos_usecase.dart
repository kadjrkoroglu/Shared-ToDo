import 'package:shared_todo/domain/entities/todo.dart';
import 'package:shared_todo/domain/repositories/todo_repository.dart';

class GetTodosUseCase {
  const GetTodosUseCase(this._repository);

  final TodoRepository _repository;

  Future<List<Todo>> call(int listId) => _repository.getTodos(listId);
}
