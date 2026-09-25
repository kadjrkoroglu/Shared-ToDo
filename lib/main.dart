import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_todo/data/repositories/auth_repository_impl.dart';
import 'package:shared_todo/data/services/api_client.dart';
import 'package:shared_todo/data/services/token_storage.dart';
import 'package:shared_todo/domain/usecases/login_usecase.dart';
import 'package:shared_todo/domain/usecases/logout_usecase.dart';
import 'package:shared_todo/domain/usecases/register_usecase.dart';
import 'package:shared_todo/domain/usecases/restore_session_usecase.dart';
import 'package:shared_todo/presentation/viewmodels/auth_viewmodel.dart';
import 'package:shared_todo/theme/app_theme.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: remove once lists and todos are migrated to the REST API.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final tokenStorage = TokenStorage();
  final authRepository = AuthRepositoryImpl(
    apiClient: ApiClient(tokenStorage: tokenStorage),
    tokenStorage: tokenStorage,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthViewModel(
        login: LoginUseCase(authRepository),
        register: RegisterUseCase(authRepository),
        restoreSession: RestoreSessionUseCase(authRepository),
        logout: LogoutUseCase(authRepository),
      )..init(),
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
