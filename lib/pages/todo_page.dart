import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_todo/services/firestore_service.dart';

class TodoPage extends StatefulWidget {
  final String listId;
  final String listName;

  const TodoPage({super.key, required this.listId, required this.listName});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _todoController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  void _showAddTodoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New Task',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _todoController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'What needs to be done?',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _addTodo(),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _addTodo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Add Task',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _addTodo() async {
    if (_todoController.text.trim().isNotEmpty) {
      await _firestoreService.addTodo(
        widget.listId,
        _todoController.text.trim(),
      );
      _todoController.clear();
      if (mounted) Navigator.pop(context); // Close bottom sheet
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Match HomeScreen background
      appBar: AppBar(
        title: Text(widget.listName),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.groups_2_rounded,
              color: Color(0xFF6366F1),
              size: 20,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getTodos(widget.listId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- MEMBER LIST HEADER ---
          return Column(
            children: [
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('shared_lists')
                    .doc(widget.listId)
                    .get(),
                builder: (context, listDoc) {
                  if (!listDoc.hasData) return const SizedBox();
                  List members =
                      (listDoc.data!.data()
                          as Map<String, dynamic>)['members'] ??
                      [];

                  return FutureBuilder<List<String>>(
                    future: _firestoreService.getMemberEmails(members),
                    builder: (context, emailSnapshot) {
                      if (!emailSnapshot.hasData) return const SizedBox();
                      return Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: emailSnapshot.data!.length,
                          itemBuilder: (context, i) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                emailSnapshot.data![i],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const Divider(height: 1),
              Expanded(child: _buildTodoList(snapshot)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTodoBottomSheet(context),
        backgroundColor: Colors.blueAccent,
        label: const Text('New Task', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTodoList(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 15),
            const Text('No tasks found.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Sort tasks: Active first, Completed last
    var todos = snapshot.data!.docs;
    todos.sort((a, b) {
      bool aDone = (a.data() as Map<String, dynamic>)['isDone'] ?? false;
      bool bDone = (b.data() as Map<String, dynamic>)['isDone'] ?? false;
      if (aDone && !bDone) return 1;
      if (!aDone && bDone) return -1;
      return 0;
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        var todoDoc = todos[index];
        var todoData = todoDoc.data() as Map<String, dynamic>;
        bool isDone = todoData['isDone'] ?? false;

        return Dismissible(
          key: Key(todoDoc.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.redAccent.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            _firestoreService.deleteTodo(widget.listId, todoDoc.id);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
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
                onTap: () {
                  _firestoreService.toggleTodoStatus(
                    widget.listId,
                    todoDoc.id,
                    isDone,
                  );
                },
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
                todoData['title'] ?? '',
                style: TextStyle(
                  fontSize: 15,
                  color: isDone
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF1E293B),
                  fontWeight: isDone ? FontWeight.normal : FontWeight.w500,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: const Color(0xFFEF4444),
                iconSize: 22,
                onPressed: () {
                  _firestoreService.deleteTodo(widget.listId, todoDoc.id);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
