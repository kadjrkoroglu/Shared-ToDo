import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_todo/components/todo_tile.dart';
import 'package:shared_todo/domain/entities/todo_list.dart';
import 'package:shared_todo/domain/repositories/todo_repository.dart';
import 'package:shared_todo/domain/usecases/add_todo_usecase.dart';
import 'package:shared_todo/domain/usecases/create_shared_list_usecase.dart';
import 'package:shared_todo/domain/usecases/delete_list_usecase.dart';
import 'package:shared_todo/domain/usecases/delete_todo_usecase.dart';
import 'package:shared_todo/domain/usecases/get_personal_list_usecase.dart';
import 'package:shared_todo/domain/usecases/get_shared_lists_usecase.dart';
import 'package:shared_todo/domain/usecases/get_todos_usecase.dart';
import 'package:shared_todo/domain/usecases/set_todo_completed_usecase.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/viewmodels/home_viewmodel.dart';
import 'todo_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final repository = context.read<TodoRepository>();
        return HomeViewModel(
          getPersonalList: GetPersonalListUseCase(repository),
          getSharedLists: GetSharedListsUseCase(repository),
          getTodos: GetTodosUseCase(repository),
          addTodo: AddTodoUseCase(repository),
          setTodoCompleted: SetTodoCompletedUseCase(repository),
          deleteTodo: DeleteTodoUseCase(repository),
          createSharedList: CreateSharedListUseCase(repository),
          deleteList: DeleteListUseCase(repository),
        )..load();
      },
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final TextEditingController _personalTodoController = TextEditingController();

  @override
  void dispose() {
    _personalTodoController.dispose();
    super.dispose();
  }

  void _showError(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'An error occurred'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _addPersonalTodo() async {
    final title = _personalTodoController.text.trim();
    if (title.isEmpty) return;

    final viewModel = context.read<HomeViewModel>();
    final success = await viewModel.addPersonalTodo(title);

    if (!mounted) return;
    if (success) {
      _personalTodoController.clear();
    } else {
      _showError(viewModel.errorMessage);
    }
  }

  void _showAddFriendDialog() {
    final idController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('New Shared List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter list name and friend\'s ID.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'List Name (e.g. Shopping)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: idController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Friend ID (e.g. AB1234)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final friendId = idController.text.trim();
              if (friendId.isEmpty) return;

              final viewModel = context.read<HomeViewModel>();
              final name = nameController.text.trim();
              final success = await viewModel.createSharedList(
                name.isEmpty ? 'New Shared List' : name,
                friendId,
              );

              if (!mounted || !dialogContext.mounted) return;
              if (success) {
                Navigator.pop(dialogContext);
              } else {
                _showError(viewModel.errorMessage);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteList(TodoList list) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete List?'),
        content: const Text('Are you sure you want to remove this list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final viewModel = context.read<HomeViewModel>();
              final success = await viewModel.deleteSharedList(list);
              if (!success && mounted) _showError(viewModel.errorMessage);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Workspace')),
      drawer: _buildDrawer(context),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: viewModel.load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'What\'s on your mind?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildPersonalTodoEntry(),
                      const SizedBox(height: 32),
                      _buildSectionHeader(
                        icon: Icons.task_alt_rounded,
                        color: const Color(0xFF6366F1),
                        title: 'Personal Tasks',
                      ),
                      const SizedBox(height: 10),
                      _buildPersonalTodos(viewModel),
                      const SizedBox(height: 40),
                      _buildSectionHeader(
                        icon: Icons.groups_rounded,
                        color: const Color(0xFF8B5CF6),
                        title: 'Shared Lists',
                      ),
                      const SizedBox(height: 16),
                      _buildSharedLists(viewModel),
                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.group_add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color color,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalTodoEntry() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _personalTodoController,
            onSubmitted: (_) => _addPersonalTodo(),
            decoration: const InputDecoration(
              hintText: 'Add a personal task...',
              prefixIcon: Icon(
                Icons.edit_note_rounded,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: _addPersonalTodo,
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalTodos(HomeViewModel viewModel) {
    if (viewModel.personalTodos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          viewModel.errorMessage ?? 'No personal tasks yet.',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.personalTodos.length,
      itemBuilder: (context, index) {
        final todo = viewModel.personalTodos[index];
        return TodoTile(
          todo: todo,
          onToggle: () async {
            final ok = await viewModel.togglePersonalTodo(todo);
            if (!ok && mounted) _showError(viewModel.errorMessage);
          },
          onDelete: () async {
            await viewModel.deletePersonalTodo(todo);
            if (viewModel.errorMessage != null && mounted) {
              _showError(viewModel.errorMessage);
            }
          },
        );
      },
    );
  }

  Widget _buildSharedLists(HomeViewModel viewModel) {
    if (viewModel.sharedLists.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No collaborations yet.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.sharedLists.length,
      itemBuilder: (context, index) {
        final list = viewModel.sharedLists[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
              vertical: 12,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.folder_shared_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text(
              list.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF1E293B),
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF64748B),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TodoPage(list: list)),
            ),
            onLongPress: () => _confirmDeleteList(list),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;
    final uniqueId = user?.uniqueId ?? '---';

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6366F1).withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Profile Section
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Divider(),
              // ID Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.fingerprint,
                            color: Color(0xFF6366F1),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Your Personal ID',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          uniqueId,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            letterSpacing: 1.5,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 20),
                          color: const Color(0xFF6366F1),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: uniqueId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('ID Copied!'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Logout
              Container(
                margin: const EdgeInsets.all(16),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => context.read<AuthViewModel>().logout(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
