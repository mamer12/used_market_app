import '../config/env.dart';

/// URL constants for the Madhmoon React mobile web app.
///
/// Uses the centralized [Env] configuration for environment-specific URLs.
/// Supports compile-time environment selection via dart-define.
///
/// Example usage:
/// ```dart
/// // Development (default)
/// WebConstants.sooqUrl('mazadat') // http://10.0.2.2:5173/m/mazadat
///
/// // Production
/// // flutter build --dart-define=ENV=prod
/// WebConstants.sooqUrl('mazadat') // https://m.luqta.app/m/mazadat
/// ```
class WebConstants {
  WebConstants._();

  /// Development host override (for local testing)
  static const String _devHostOverride =
      String.fromEnvironment('DEV_WEB_HOST');

  /// Vite default dev-server port
  static const int _devPort = 5173;

  /// Base URL of the React mobile web app.
  ///
  /// Uses [Env.webUrl] for environment-specific URL, with fallback
  /// to localhost for development debugging.
  static String get baseWebUrl {
    // Allow host override for local testing
    if (_devHostOverride.isNotEmpty) {
      return 'http://$_devHostOverride:$_devPort';
    }

    // Use the centralized Env configuration
    return Env.webUrl;
  }

  /// Base path for mobile routes
  static const String _mobilePath = '/m';

  /// Full URL for a given sooq slug's mobile web entry point.
  ///
  /// [sooq] must be one of: mazadat, matajir, balla, mustamal, chat, activity, feed
  ///
  /// Example:
  /// - `sooqUrl('mazadat')` → `https://m.luqta.app/m/mazadat`
  /// - `sooqUrl('balla')` → `https://m.luqta.app/m/balla`
  static String sooqUrl(String sooq) => '$baseWebUrl$_mobilePath/$sooq';

  /// Specific sooq URLs
  static String get mazadatUrl => sooqUrl('mazadat');
  static String get matajirUrl => sooqUrl('matajir');
  static String get ballaUrl => sooqUrl('balla');
  static String get mustamalUrl => sooqUrl('mustamal');
  static String get chatUrl => sooqUrl('chat');
  static String get activityUrl => sooqUrl('activity');
  static String get feedUrl => sooqUrl('feed');

  /// WebView timeout for loading (from Env config)
  static Duration get webViewTimeout => Env.webViewTimeout;

  /// Cookie configuration for session sharing
  static String get cookieDomain => Env.cookieDomain;
  static bool get cookieSecure => Env.isProd || Env.isStaging;
  static bool get cookieHttpOnly => true;
  static String get sameSite => 'strict';

  /// Check if WebView should be used for a given sooq
  ///
  /// Returns true for all sooqs in production, but can be
  /// overridden per-sooq for gradual rollout.
  static bool isWebViewEnabled(String sooq) {
    switch (sooq) {
      case 'mazadat':
        return Env.isProd || Env.isStaging || Env.isDev;
      case 'matajir':
        return Env.isProd || Env.isStaging || Env.isDev;
      case 'balla':
        return Env.isProd || Env.isStaging || Env.isDev;
      case 'mustamal':
        return Env.isProd || Env.isStaging || Env.isDev;
      case 'chat':
        return false; // Still using native implementation
      case 'activity':
        return Env.isProd || Env.isStaging;
      case 'feed':
        return Env.isStaging; // Beta testing
      default:
        return false;
    }
  }
}
