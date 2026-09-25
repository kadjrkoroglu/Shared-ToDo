import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_todo/core/config/api_config.dart';
import 'package:shared_todo/core/errors/app_exception.dart';
import 'package:shared_todo/data/services/token_storage.dart';

class ApiClient {
  ApiClient({required TokenStorage tokenStorage, http.Client? client})
    : _tokenStorage = tokenStorage,
      _client = client ?? http.Client();

  final TokenStorage _tokenStorage;
  final http.Client _client;

  Future<dynamic> get(String path) => _send('GET', path);

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) =>
      _send('POST', path, body: body);

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) =>
      _send('PATCH', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final request = http.Request(method, Uri.parse('${ApiConfig.baseUrl}$path'))
      ..headers['Content-Type'] = 'application/json';

    final token = await _tokenStorage.read();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    if (body != null) {
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _client.send(request).timeout(ApiConfig.timeout),
      );
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException('The server took too long to respond');
    } on http.ClientException {
      throw const NetworkException();
    }

    return _handle(response);
  }

  dynamic _handle(http.Response response) {
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = decoded is Map && decoded['error'] is String
        ? decoded['error'] as String
        : 'Something went wrong';

    if (response.statusCode == 401) {
      throw UnauthorizedException(message);
    }
    throw ApiException(message, statusCode: response.statusCode);
  }
}
