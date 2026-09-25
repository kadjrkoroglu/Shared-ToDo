import 'package:shared_todo/domain/entities/todo_list.dart';
import 'package:shared_todo/domain/repositories/todo_repository.dart';

class CreateSharedListUseCase {
  const CreateSharedListUseCase(this._repository);

  final TodoRepository _repository;

  Future<TodoList> call(String name, String friendUniqueId) =>
      _repository.createSharedList(name, friendUniqueId);
}
