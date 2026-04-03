// Production environment configuration
// This file contains production values for the live app

/// Production environment constants
class EnvProd {
  const EnvProd._();

  /// API Configuration
  static const String apiBaseUrl = 'https://luqta-api-production.up.railway.app';
  static const String apiVersion = 'v1';
  static const String fullApiUrl = '$apiBaseUrl/api/$apiVersion';

  /// Web App Configuration (React Madhmoon)
  static const String webUrl = 'https://m.luqta.app';
  static const String webBasePath = '/m';

  /// WebSocket Configuration
  static const String wsUrl = 'wss://ws.luqta.app';

  /// CDN Configuration
  static const String cdnUrl = 'https://cdn.luqta.app';

  /// Cookie Configuration
  static const String cookieDomain = 'luqta.app';
  static const bool cookieSecure = true;
  static const bool cookieHttpOnly = true;
  static const String sameSite = 'strict';

  /// Feature Flags
  static const bool enableMazadat = true;
  static const bool enableMatajir = true;
  static const bool enableBalla = true;
  static const bool enableMustamal = true;
  static const bool enableDebugLogs = false;
  static const bool enableDevMenu = false;

  /// Timeouts
  static const int apiTimeoutMs = 30000;
  static const int webViewTimeoutMs = 60000;
  static const int splashScreenDelayMs = 2500;

  /// Cache Configuration
  static const int cacheMaxAgeHours = 24;
  static const bool cacheEnabled = true;

  /// Image Upload
  static const int maxImageSizeMB = 10;
  static const int imageQuality = 90;
  static const int maxImageWidth = 2048;
  static const int maxImageHeight = 2048;

  /// Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// Deep Link Configuration
  static const String appScheme = 'luqta';
  static const String universalLinkDomain = 'luqta.app';
}
