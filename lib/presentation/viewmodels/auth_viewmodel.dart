import 'package:flutter/foundation.dart';
import 'package:shared_todo/core/errors/app_exception.dart';
import 'package:shared_todo/domain/entities/app_user.dart';
import 'package:shared_todo/domain/usecases/login_usecase.dart';
import 'package:shared_todo/domain/usecases/logout_usecase.dart';
import 'package:shared_todo/domain/usecases/register_usecase.dart';
import 'package:shared_todo/domain/usecases/restore_session_usecase.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({
    required LoginUseCase login,
    required RegisterUseCase register,
    required RestoreSessionUseCase restoreSession,
    required LogoutUseCase logout,
  }) : _login = login,
       _register = register,
       _restoreSession = restoreSession,
       _logout = logout;

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final RestoreSessionUseCase _restoreSession;
  final LogoutUseCase _logout;

  AuthStatus status = AuthStatus.unknown;
  AppUser? user;
  bool isLoading = false;
  String? errorMessage;

  Future<void> init() async {
    try {
      user = await _restoreSession();
    } on AppException {
      user = null;
    }
    status = user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> login(String email, String password) =>
      _authenticate(() => _login(email, password));

  Future<bool> register(String email, String password) =>
      _authenticate(() => _register(email, password));

  Future<bool> _authenticate(Future<AppUser> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await action();
      status = AuthStatus.authenticated;
      return true;
    } on AppException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
