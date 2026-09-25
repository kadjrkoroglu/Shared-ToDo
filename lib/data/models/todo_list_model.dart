import 'package:shared_todo/data/models/user_model.dart';
import 'package:shared_todo/domain/entities/todo_list.dart';

class TodoListModel extends TodoList {
  const TodoListModel({
    required super.id,
    required super.name,
    required super.isPersonal,
    required super.members,
  });

  factory TodoListModel.fromJson(Map<String, dynamic> json) => TodoListModel(
    id: json['id'] as int,
    name: json['name'] as String,
    isPersonal: json['isPersonal'] as bool? ?? false,
    members: (json['members'] as List<dynamic>)
        .map((m) => UserModel.fromJson(m as Map<String, dynamic>))
        .toList(),
  );
}
