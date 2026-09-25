import 'package:shared_todo/domain/entities/todo_list.dart';
import 'package:shared_todo/domain/repositories/todo_repository.dart';

class GetPersonalListUseCase {
  const GetPersonalListUseCase(this._repository);

  final TodoRepository _repository;

  Future<TodoList> call() => _repository.getPersonalList();
}
