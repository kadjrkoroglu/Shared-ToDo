import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_todo/components/todo_tile.dart';
import 'package:shared_todo/domain/entities/todo_list.dart';
import 'package:shared_todo/domain/repositories/todo_repository.dart';
import 'package:shared_todo/domain/usecases/add_todo_usecase.dart';
import 'package:shared_todo/domain/usecases/delete_todo_usecase.dart';
import 'package:shared_todo/domain/usecases/get_todos_usecase.dart';
import 'package:shared_todo/domain/usecases/set_todo_completed_usecase.dart';
import 'package:shared_todo/presentation/viewmodels/todo_list_viewmodel.dart';

class TodoPage extends StatelessWidget {
  final TodoList list;

  const TodoPage({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final repository = context.read<TodoRepository>();
        return TodoListViewModel(
          listId: list.id,
          getTodos: GetTodosUseCase(repository),
          addTodo: AddTodoUseCase(repository),
          setTodoCompleted: SetTodoCompletedUseCase(repository),
          deleteTodo: DeleteTodoUseCase(repository),
        )..load();
      },
      child: _TodoView(list: list),
    );
  }
}

class _TodoView extends StatefulWidget {
  final TodoList list;

  const _TodoView({required this.list});

  @override
  State<_TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<_TodoView> {
  final TextEditingController _todoController = TextEditingController();

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  void _showError(TodoListViewModel viewModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(viewModel.errorMessage ?? 'An error occurred'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _showAddTodoBottomSheet() {
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

  Future<void> _addTodo() async {
    final title = _todoController.text.trim();
    if (title.isEmpty) return;

    final viewModel = context.read<TodoListViewModel>();
    final navigator = Navigator.of(context);

    final success = await viewModel.addTodo(title);
    if (!mounted) return;

    if (success) {
      _todoController.clear();
      navigator.pop(); // Close bottom sheet
    } else {
      _showError(viewModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TodoListViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Match HomeScreen background
      appBar: AppBar(
        title: Text(widget.list.name),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
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
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildMemberHeader(),
                const Divider(height: 1),
                Expanded(child: _buildTodoList(viewModel)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTodoBottomSheet,
        backgroundColor: Colors.blueAccent,
        label: const Text('New Task', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMemberHeader() {
    final members = widget.list.members;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        itemBuilder: (context, i) => Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              members[i].email,
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
  }

  Widget _buildTodoList(TodoListViewModel viewModel) {
    final todos = viewModel.sortedTodos;

    return RefreshIndicator(
      onRefresh: viewModel.load,
      child: todos.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_turned_in_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        viewModel.errorMessage ?? 'No tasks found.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return TodoTile(
                  todo: todo,
                  verticalMargin: 5,
                  onToggle: () async {
                    final ok = await viewModel.toggle(todo);
                    if (!ok && mounted) _showError(viewModel);
                  },
                  onDelete: () async {
                    await viewModel.deleteTodo(todo);
                    if (viewModel.errorMessage != null && mounted) {
                      _showError(viewModel);
                    }
                  },
                );
              },
            ),
    );
  }
}
