// Environment configuration abstraction for Madhmoon WebView deployment
// Use `dart-define` for compile-time environment switching:
// flutter run --dart-define=ENV=dev
// flutter build apk --dart-define=ENV=prod

/// Enum representing deployment environments
enum Environment {
  dev,
  staging,
  prod,
}

/// Environment configuration for Madhmoon
class Env {
  const Env._();

  /// Current environment (set via dart-define)
  static const Environment current = String.fromEnvironment('ENV') == 'prod'
      ? Environment.prod
      : String.fromEnvironment('ENV') == 'staging'
          ? Environment.staging
          : Environment.dev;

  /// Check if running in production
  static bool get isProd => current == Environment.prod;

  /// Check if running in staging
  static bool get isStaging => current == Environment.staging;

  /// Check if running in development
  static bool get isDev => current == Environment.dev;

  /// API Base URL based on environment
  static String get apiBaseUrl {
    switch (current) {
      case Environment.prod:
        return 'https://luqta-api-production.up.railway.app';
      case Environment.staging:
        return 'https://staging-api.luqta.app';
      case Environment.dev:
        return 'http://10.0.2.2:8080'; // Android emulator localhost
    }
  }

  /// Web App URL (React Madhmoon) based on environment
  static String get webUrl {
    switch (current) {
      case Environment.prod:
        return 'https://m.luqta.app';
      case Environment.staging:
        return 'https://staging-m.luqta.app';
      case Environment.dev:
        return 'http://10.0.2.2:5173'; // Vite dev server
    }
  }

  /// Cookie Domain for session sharing
  static String get cookieDomain {
    switch (current) {
      case Environment.prod:
        return 'luqta.app';
      case Environment.staging:
        return 'staging.luqta.app';
      case Environment.dev:
        return 'localhost';
    }
  }

  /// WebSocket URL for real-time features (auctions, chat)
  static String get wsUrl {
    switch (current) {
      case Environment.prod:
        return 'wss://ws.luqta.app';
      case Environment.staging:
        return 'wss://staging-ws.luqta.app';
      case Environment.dev:
        return 'ws://10.0.2.2:8080';
    }
  }

  /// CDN URL for media assets
  static String get cdnUrl {
    switch (current) {
      case Environment.prod:
        return 'https://cdn.luqta.app';
      case Environment.staging:
        return 'https://staging-cdn.luqta.app';
      case Environment.dev:
        return 'http://10.0.2.2:9000';
    }
  }

  /// Sentry DSN for error tracking (optional)
  static String? get sentryDsn {
    switch (current) {
      case Environment.prod:
        return const String.fromEnvironment('SENTRY_DSN').isNotEmpty
            ? const String.fromEnvironment('SENTRY_DSN')
            : null;
      default:
        return null;
    }
  }

  /// Feature flags
  static bool get enableAnalytics => isProd;
  static bool get enableCrashReporting => isProd;
  static bool get enableLogging => !isProd;
  static bool get enableDebugMenu => !isProd;

  /// Timeout configurations
  static Duration get apiTimeout => const Duration(seconds: 30);
  static Duration get webViewTimeout => const Duration(seconds: 60);

  /// Cache configuration
  static Duration get cacheMaxAge =>
      isProd ? const Duration(hours: 24) : const Duration(minutes: 5);
}
