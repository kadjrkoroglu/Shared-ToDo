import 'package:shared_todo/data/models/user_model.dart';
import 'package:shared_todo/data/services/api_client.dart';
import 'package:shared_todo/data/services/token_storage.dart';
import 'package:shared_todo/domain/entities/app_user.dart';
import 'package:shared_todo/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  }) : _api = apiClient,
       _tokenStorage = tokenStorage;

  final ApiClient _api;
  final TokenStorage _tokenStorage;

  @override
  Future<AppUser> login(String email, String password) =>
      _authenticate('/auth/login', email, password);

  @override
  Future<AppUser> register(String email, String password) =>
      _authenticate('/auth/register', email, password);

  Future<AppUser> _authenticate(
    String path,
    String email,
    String password,
  ) async {
    final json =
        await _api.post(path, body: {'email': email, 'password': password})
            as Map<String, dynamic>;

    final userJson = json['user'] as Map<String, dynamic>;
    await _tokenStorage.save(json['token'] as String);
    await _tokenStorage.saveUser(userJson);
    return UserModel.fromJson(userJson);
  }

  @override
  Future<AppUser?> restoreSession() async {
    final token = await _tokenStorage.read();
    final userJson = await _tokenStorage.readUser();
    if (token == null || userJson == null) return null;

    return UserModel.fromJson(userJson);
  }

  @override
  Future<void> logout() => _tokenStorage.clear();
}
