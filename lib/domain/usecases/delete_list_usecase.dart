import 'package:shared_todo/domain/repositories/todo_repository.dart';

class DeleteListUseCase {
  const DeleteListUseCase(this._repository);

  final TodoRepository _repository;

  Future<void> call(int listId) => _repository.deleteList(listId);
}
