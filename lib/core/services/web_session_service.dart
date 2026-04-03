import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../services/log_service.dart';

/// Manages the server-side web session cookie used to authenticate the
/// embedded WebView without re-sending the JWT on every request.
///
/// The backend sets a `Set-Cookie` header on `POST /api/v1/auth/web-session`.
/// The cookie is picked up automatically by the WebView's cookie jar once the
/// WebView navigates to the same domain.
@lazySingleton
class WebSessionService {
  final Dio _dio;
  final LogService _log;

  WebSessionService(this._dio, this._log);

  // Relative path — Dio baseUrl already includes /api/v1/
  static const _sessionEndpoint = 'auth/web-session';

  /// Epoch of the last successful session initialisation.
  DateTime? _lastInit;

  /// Sessions are valid for 55 minutes (backend expiry is 60 min).
  static const _sessionTtl = Duration(minutes: 55);

  /// Whether a session is currently considered valid.
  bool get isSessionValid {
    final last = _lastInit;
    if (last == null) return false;
    return DateTime.now().difference(last) < _sessionTtl;
  }

  /// Calls `POST /api/v1/auth/web-session` to obtain a session cookie.
  ///
  /// The caller may pass [force] = true to skip the TTL cache and always
  /// refresh (e.g. after an `auth:expired` bridge message).
  Future<void> initSession({bool force = false}) async {
    if (!force && isSessionValid) {
      _log.debug('[WebSessionService] session still valid — skipping init');
      return;
    }

    _log.info('[WebSessionService] initialising web session');
    try {
      await _dio.post<void>(_sessionEndpoint);
      _lastInit = DateTime.now();
      _log.info('[WebSessionService] session cookie obtained');
    } on DioException catch (e, st) {
      _log.error('[WebSessionService] failed to init session', e, st);
      rethrow;
    }
  }

  /// Invalidates the cached session so the next call to [initSession] always
  /// hits the network (used on logout).
  void invalidate() => _lastInit = null;
}
