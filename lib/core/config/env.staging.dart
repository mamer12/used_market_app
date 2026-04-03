// Staging environment configuration
// Used for QA testing and pre-production validation

/// Staging environment constants
class EnvStaging {
  const EnvStaging._();

  /// API Configuration
  static const String apiBaseUrl = 'https://staging-api.luqta.app';
  static const String apiVersion = 'v1';
  static const String fullApiUrl = '$apiBaseUrl/api/$apiVersion';

  /// Web App Configuration (React Madhmoon)
  static const String webUrl = 'https://staging-m.luqta.app';
  static const String webBasePath = '/m';

  /// WebSocket Configuration
  static const String wsUrl = 'wss://staging-ws.luqta.app';

  /// CDN Configuration
  static const String cdnUrl = 'https://staging-cdn.luqta.app';

  /// Cookie Configuration
  static const String cookieDomain = 'staging.luqta.app';
  static const bool cookieSecure = true;
  static const bool cookieHttpOnly = true;
  static const String sameSite = 'strict';

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
  static const int splashScreenDelayMs = 2000;

  /// Cache Configuration
  static const int cacheMaxAgeHours = 12;
  static const bool cacheEnabled = true;

  /// Image Upload
  static const int maxImageSizeMB = 10;
  static const int imageQuality = 85;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1920;

  /// Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// Deep Link Configuration
  static const String appScheme = 'luqta-staging';
  static const String universalLinkDomain = 'staging.luqta.app';
}
