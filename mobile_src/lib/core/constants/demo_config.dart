import 'app_config.dart';

/// Matches backend DEMO_MODE: 72 hours, or 20 seconds when the demo switch is on.
abstract final class DemoConfig {
  static const bool enabled = AppConfig.demoMode;

  static const Duration withdrawalDelay = enabled ? Duration(seconds: 20) : Duration(hours: 72);
}
