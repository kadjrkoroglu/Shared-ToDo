import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_todo/data/repositories/auth_repository_impl.dart';
import 'package:shared_todo/data/repositories/todo_repository_impl.dart';
import 'package:shared_todo/data/services/api_client.dart';
import 'package:shared_todo/data/services/token_storage.dart';
import 'package:shared_todo/domain/repositories/todo_repository.dart';
import 'package:shared_todo/domain/usecases/login_usecase.dart';
import 'package:shared_todo/domain/usecases/logout_usecase.dart';
import 'package:shared_todo/domain/usecases/register_usecase.dart';
import 'package:shared_todo/domain/usecases/restore_session_usecase.dart';
import 'package:shared_todo/presentation/viewmodels/auth_viewmodel.dart';
import 'package:shared_todo/theme/app_theme.dart';
import 'auth_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage: tokenStorage);
  final authRepository = AuthRepositoryImpl(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );

  final authViewModel = AuthViewModel(
    login: LoginUseCase(authRepository),
    register: RegisterUseCase(authRepository),
    restoreSession: RestoreSessionUseCase(authRepository),
    logout: LogoutUseCase(authRepository),
  );
  apiClient.onUnauthorized = authViewModel.logout;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authViewModel..init()),
        Provider<TodoRepository>.value(value: TodoRepositoryImpl(apiClient)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}
