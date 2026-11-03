abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Mirrors the backend DEMO_MODE switch.
  static const bool demoMode = bool.fromEnvironment('DEMO_MODE');

  /// When true, features use their MockRepository and the UI runs without the API.
  static const bool useMockRepositories = bool.fromEnvironment(
    'USE_MOCK_REPOSITORIES',
    defaultValue: true,
  );
}
