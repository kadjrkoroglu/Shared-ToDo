import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_todo/core/errors/app_exception.dart';

class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final FlutterSecureStorage _storage;

  Future<String?> read() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      throw const StorageException();
    }
  }

  Future<void> save(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (_) {
      throw const StorageException();
    }
  }

  Future<Map<String, dynamic>?> readUser() async {
    try {
      final raw = await _storage.read(key: _userKey);
      return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw const StorageException();
    }
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    try {
      await _storage.write(key: _userKey, value: jsonEncode(user));
    } catch (_) {
      throw const StorageException();
    }
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
    } catch (_) {
      throw const StorageException();
    }
  }
}
