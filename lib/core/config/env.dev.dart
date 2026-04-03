// Development environment configuration
// This file provides development-specific defaults when not using dart-define

/// Development environment constants
class EnvDev {
  const EnvDev._();

  /// API Configuration
  static const String apiBaseUrl = 'http://10.0.2.2:8080';
  static const String apiVersion = 'v1';
  static const String fullApiUrl = '$apiBaseUrl/api/$apiVersion';

  /// Web App Configuration (React Madhmoon)
  static const String webUrl = 'http://10.0.2.2:5173';
  static const String webBasePath = '/m';

  /// WebSocket Configuration
  static const String wsUrl = 'ws://10.0.2.2:8080';

  /// CDN Configuration
  static const String cdnUrl = 'http://10.0.2.2:9000';

  /// Cookie Configuration
  static const String cookieDomain = 'localhost';
  static const bool cookieSecure = false;
  static const bool cookieHttpOnly = true;
  static const String sameSite = 'lax';

  /// Feature Flags
  static const bool enableMazadat = true;
  static const bool enableMatajir = true;
  static const bool enableBalla = true;
  static const bool enableMustamal = true;
  static const bool enableDebugLogs = true;
  static const bool enableDevMenu = true;

  /// Timeouts
  static const int apiTimeoutMs = 30000;
  static const int webViewTimeoutMs = 60000;
  static const int splashScreenDelayMs = 0;

  /// Cache Configuration
  static const int cacheMaxAgeHours = 1;
  static const bool cacheEnabled = false;

  /// Image Upload
  static const int maxImageSizeMB = 10;
  static const int imageQuality = 85;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1920;

  /// Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// Deep Link Configuration
  static const String appScheme = 'luqta-dev';
  static const String universalLinkDomain = 'dev.luqta.app';
}
