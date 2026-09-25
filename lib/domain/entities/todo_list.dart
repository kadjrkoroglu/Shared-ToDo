import 'package:shared_todo/domain/entities/app_user.dart';

class TodoList {
  final int id;
  final String name;
  final bool isPersonal;
  final List<AppUser> members;

  const TodoList({
    required this.id,
    required this.name,
    required this.isPersonal,
    required this.members,
  });
}
