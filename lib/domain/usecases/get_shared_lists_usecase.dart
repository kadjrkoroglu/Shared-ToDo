import 'package:shared_todo/domain/entities/todo_list.dart';
import 'package:shared_todo/domain/repositories/todo_repository.dart';

class GetSharedListsUseCase {
  const GetSharedListsUseCase(this._repository);

  final TodoRepository _repository;

  Future<List<TodoList>> call() => _repository.getSharedLists();
}
