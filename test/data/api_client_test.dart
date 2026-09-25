import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_todo/core/errors/app_exception.dart';
import 'package:shared_todo/data/services/api_client.dart';

import '../helpers/mocks.dart';

void main() {
  late MockTokenStorage tokenStorage;

  setUp(() {
    tokenStorage = MockTokenStorage();
    when(() => tokenStorage.read()).thenAnswer((_) async => null);
  });

  ApiClient clientWith(MockClientHandler handler) =>
      ApiClient(tokenStorage: tokenStorage, client: MockClient(handler));

  test('returns decoded JSON on success', () async {
    final client = clientWith((_) async => http.Response('{"a":1}', 200));

    expect(await client.get('/x'), {'a': 1});
  });

  test('sends bearer token when one is stored', () async {
    when(() => tokenStorage.read()).thenAnswer((_) async => 'tok');
    late http.Request captured;
    final client = clientWith((request) async {
      captured = request;
      return http.Response('{}', 200);
    });

    await client.get('/x');

    expect(captured.headers['Authorization'], 'Bearer tok');
  });

  test('sends JSON body on post', () async {
    late http.Request captured;
    final client = clientWith((request) async {
      captured = request;
      return http.Response('{}', 201);
    });

    await client.post('/x', body: {'k': 'v'});

    expect(captured.method, 'POST');
    expect(jsonDecode(captured.body), {'k': 'v'});
  });

  test('maps 401 to UnauthorizedException with server message', () async {
    final client = clientWith(
      (_) async => http.Response('{"error":"Invalid credentials"}', 401),
    );

    expect(
      () => client.post('/auth/login'),
      throwsA(
        isA<UnauthorizedException>().having(
          (e) => e.message,
          'message',
          'Invalid credentials',
        ),
      ),
    );
  });

  test('calls onUnauthorized only when a token was sent', () async {
    var calls = 0;
    final client = clientWith((_) async => http.Response('{}', 401))
      ..onUnauthorized = () => calls++;

    await expectLater(client.get('/x'), throwsA(isA<UnauthorizedException>()));
    expect(calls, 0);

    when(() => tokenStorage.read()).thenAnswer((_) async => 'tok');
    await expectLater(client.get('/x'), throwsA(isA<UnauthorizedException>()));
    expect(calls, 1);
  });

  test('maps other error statuses to ApiException with status code', () async {
    final client = clientWith(
      (_) async => http.Response('{"error":"Not authorized"}', 403),
    );

    expect(
      () => client.get('/x'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 403)
            .having((e) => e.message, 'message', 'Not authorized'),
      ),
    );
  });

  test('falls back to a generic message when the body has no error', () async {
    final client = clientWith((_) async => http.Response('', 500));

    expect(
      () => client.get('/x'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Something went wrong',
        ),
      ),
    );
  });

  test('maps connection failures to NetworkException', () async {
    final client = clientWith((_) async => throw http.ClientException('down'));

    expect(() => client.get('/x'), throwsA(isA<NetworkException>()));
  });
}
