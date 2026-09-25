import 'package:shared_todo/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> login(String email, String password);
  Future<AppUser> register(String email, String password);

  /// Returns the signed-in user, or null if there is no valid session.
  Future<AppUser?> restoreSession();

  Future<void> logout();
}
