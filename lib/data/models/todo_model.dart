import 'package:shared_todo/domain/entities/todo.dart';

class TodoModel extends Todo {
  const TodoModel({
    required super.id,
    required super.listId,
    required super.title,
    required super.isCompleted,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
    id: json['id'] as int,
    listId: json['list_id'] as int,
    title: json['title'] as String,
    isCompleted: json['is_completed'] as bool? ?? false,
  );
}
