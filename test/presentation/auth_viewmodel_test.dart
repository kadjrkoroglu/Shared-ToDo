import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_todo/core/errors/app_exception.dart';
import 'package:shared_todo/domain/usecases/login_usecase.dart';
import 'package:shared_todo/domain/usecases/logout_usecase.dart';
import 'package:shared_todo/domain/usecases/register_usecase.dart';
import 'package:shared_todo/domain/usecases/restore_session_usecase.dart';
import 'package:shared_todo/presentation/viewmodels/auth_viewmodel.dart';

import '../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late AuthViewModel viewModel;

  setUp(() {
    repository = MockAuthRepository();
    viewModel = AuthViewModel(
      login: LoginUseCase(repository),
      register: RegisterUseCase(repository),
      restoreSession: RestoreSessionUseCase(repository),
      logout: LogoutUseCase(repository),
    );
  });

  test('starts in the unknown state', () {
    expect(viewModel.status, AuthStatus.unknown);
  });

  test('init authenticates when a session is restored', () async {
    when(() => repository.restoreSession()).thenAnswer((_) async => testUser);

    await viewModel.init();

    expect(viewModel.status, AuthStatus.authenticated);
    expect(viewModel.user, testUser);
  });

  test('init is unauthenticated without a stored session', () async {
    when(() => repository.restoreSession()).thenAnswer((_) async => null);

    await viewModel.init();

    expect(viewModel.status, AuthStatus.unauthenticated);
  });

  test('init is unauthenticated when storage fails', () async {
    when(() => repository.restoreSession()).thenThrow(const StorageException());

    await viewModel.init();

    expect(viewModel.status, AuthStatus.unauthenticated);
  });

  test('login success authenticates the user', () async {
    when(
      () => repository.login('a@a.com', 'pw'),
    ).thenAnswer((_) async => testUser);

    final ok = await viewModel.login('a@a.com', 'pw');

    expect(ok, isTrue);
    expect(viewModel.status, AuthStatus.authenticated);
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.isLoading, isFalse);
  });

  test('login failure exposes the error message', () async {
    when(
      () => repository.login(any(), any()),
    ).thenThrow(const UnauthorizedException('Invalid credentials'));

    final ok = await viewModel.login('a@a.com', 'bad');

    expect(ok, isFalse);
    expect(viewModel.errorMessage, 'Invalid credentials');
    expect(viewModel.status, isNot(AuthStatus.authenticated));
    expect(viewModel.isLoading, isFalse);
  });

  test('register success authenticates the user', () async {
    when(
      () => repository.register(any(), any()),
    ).thenAnswer((_) async => testUser);

    expect(await viewModel.register('a@a.com', 'pw'), isTrue);
    expect(viewModel.status, AuthStatus.authenticated);
  });

  test('logout clears the user', () async {
    when(
      () => repository.login(any(), any()),
    ).thenAnswer((_) async => testUser);
    when(() => repository.logout()).thenAnswer((_) async {});
    await viewModel.login('a@a.com', 'pw');

    await viewModel.logout();

    expect(viewModel.status, AuthStatus.unauthenticated);
    expect(viewModel.user, isNull);
  });
}
