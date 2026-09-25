import 'package:shared_todo/domain/entities/app_user.dart';
import 'package:shared_todo/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call(String email, String password) =>
      _repository.register(email, password);
}
