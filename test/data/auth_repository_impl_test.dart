import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_todo/core/errors/app_exception.dart';
import 'package:shared_todo/data/repositories/auth_repository_impl.dart';

import '../helpers/mocks.dart';

void main() {
  late MockApiClient api;
  late MockTokenStorage storage;
  late AuthRepositoryImpl repository;

  setUp(() {
    api = MockApiClient();
    storage = MockTokenStorage();
    repository = AuthRepositoryImpl(apiClient: api, tokenStorage: storage);

    when(() => storage.save(any())).thenAnswer((_) async {});
    when(() => storage.saveUser(any())).thenAnswer((_) async {});
    when(() => storage.clear()).thenAnswer((_) async {});
  });

  final authResponse = {'token': 'jwt', 'user': userJson()};

  test(
    'login posts credentials, stores session and returns the user',
    () async {
      when(
        () => api.post('/auth/login', body: any(named: 'body')),
      ).thenAnswer((_) async => authResponse);

      final user = await repository.login('a@a.com', 'pw');

      expect(user.email, 'a@a.com');
      expect(user.uniqueId, 'ABC123');
      verify(
        () => api.post(
          '/auth/login',
          body: {'email': 'a@a.com', 'password': 'pw'},
        ),
      ).called(1);
      verify(() => storage.save('jwt')).called(1);
      verify(() => storage.saveUser(userJson())).called(1);
    },
  );

  test('register uses the register endpoint and stores the session', () async {
    when(
      () => api.post('/auth/register', body: any(named: 'body')),
    ).thenAnswer((_) async => authResponse);

    await repository.register('a@a.com', 'pw');

    verify(() => storage.save('jwt')).called(1);
  });

  test('login does not store anything when the API rejects it', () async {
    when(
      () => api.post(any(), body: any(named: 'body')),
    ).thenThrow(const UnauthorizedException());

    await expectLater(
      repository.login('a@a.com', 'bad'),
      throwsA(isA<UnauthorizedException>()),
    );
    verifyNever(() => storage.save(any()));
  });

  test('restoreSession returns the stored user', () async {
    when(() => storage.read()).thenAnswer((_) async => 'jwt');
    when(() => storage.readUser()).thenAnswer((_) async => userJson());

    final user = await repository.restoreSession();

    expect(user?.id, 1);
  });

  test('restoreSession returns null without a token', () async {
    when(() => storage.read()).thenAnswer((_) async => null);
    when(() => storage.readUser()).thenAnswer((_) async => userJson());

    expect(await repository.restoreSession(), isNull);
  });

  test('logout clears the stored session', () async {
    await repository.logout();

    verify(() => storage.clear()).called(1);
  });
}
