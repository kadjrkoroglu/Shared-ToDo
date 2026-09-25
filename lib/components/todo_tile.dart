import 'package:flutter/material.dart';
import 'package:shared_todo/domain/entities/todo.dart';

class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    this.verticalMargin = 4,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final double verticalMargin;

  @override
  Widget build(BuildContext context) {
    final isDone = todo.isCompleted;

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(vertical: verticalMargin),
        decoration: BoxDecoration(
          color: Colors.redAccent.shade100,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: verticalMargin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? const Color(0xFF10B981) : Colors.white,
                border: Border.all(
                  color: isDone
                      ? const Color(0xFF10B981)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: isDone ? Colors.white : Colors.transparent,
              ),
            ),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              fontSize: 15,
              color: isDone ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
              fontWeight: isDone ? FontWeight.normal : FontWeight.w500,
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: const Color(0xFFEF4444),
            iconSize: 22,
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}
