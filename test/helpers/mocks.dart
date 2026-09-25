import 'package:mocktail/mocktail.dart';
import 'package:shared_todo/data/services/api_client.dart';
import 'package:shared_todo/data/services/token_storage.dart';
import 'package:shared_todo/domain/entities/app_user.dart';
import 'package:shared_todo/domain/entities/todo.dart';
import 'package:shared_todo/domain/entities/todo_list.dart';
import 'package:shared_todo/domain/repositories/auth_repository.dart';
import 'package:shared_todo/domain/repositories/todo_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTodoRepository extends Mock implements TodoRepository {}

const testUser = AppUser(id: 1, email: 'a@a.com', uniqueId: 'ABC123');

const personalList = TodoList(
  id: 10,
  name: 'Personal',
  isPersonal: true,
  members: [testUser],
);

const sharedList = TodoList(
  id: 20,
  name: 'Trip',
  isPersonal: false,
  members: [testUser],
);

Todo todo(int id, {int listId = 10, bool done = false}) =>
    Todo(id: id, listId: listId, title: 'task $id', isCompleted: done);

Map<String, dynamic> todoJson(int id, {int listId = 10, bool done = false}) => {
  'id': id,
  'list_id': listId,
  'title': 'task $id',
  'is_completed': done,
};

Map<String, dynamic> userJson() => {
  'id': 1,
  'email': 'a@a.com',
  'uniqueId': 'ABC123',
};
