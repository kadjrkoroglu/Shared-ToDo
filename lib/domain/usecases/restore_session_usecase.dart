import 'package:shared_todo/domain/entities/app_user.dart';
import 'package:shared_todo/domain/repositories/auth_repository.dart';

class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppUser?> call() => _repository.restoreSession();
}
