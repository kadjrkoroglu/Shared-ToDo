class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://shared-todo-api-production.up.railway.app',
  );

  static const Duration timeout = Duration(seconds: 20);
}
