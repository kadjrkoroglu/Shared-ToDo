abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No connection to the server']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Invalid credentials']);
}

class ApiException extends AppException {
  const ApiException(super.message, {this.statusCode});

  final int? statusCode;
}

class StorageException extends AppException {
  const StorageException([super.message = 'Could not access secure storage']);
}
