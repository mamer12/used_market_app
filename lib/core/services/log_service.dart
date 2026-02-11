import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Centralized logging service — the "Black Box Recorder".
///
/// Routes logs based on environment:
/// - **Debug mode**: Pretty console logs + in-app Talker screen.
/// - **Release mode**: Errors forwarded to Firebase Crashlytics, sensitive data masked.
class LogService {
  // ── Singleton ──────────────────────────────────────────
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;

  late final Talker _talker;

  LogService._internal() {
    _talker = TalkerFlutter.init(
      settings: TalkerSettings(
        enabled: true,
        useHistory: true,
        maxHistoryItems: 100,
        useConsoleLogs: kDebugMode, // Only print to console in debug
      ),
      // Pipe errors to Crashlytics in production
      observer: _CrashlyticsObserver(),
    );
  }

  // ── Public API ─────────────────────────────────────────

  /// The underlying [Talker] instance — useful for Dio interceptors, etc.
  Talker get talker => _talker;

  /// Opens the in-app log console (QA shake menu).
  Widget get screen => TalkerScreen(talker: _talker);

  void info(String message) => _talker.info(message);

  void debug(String message) => _talker.debug(message);

  void warning(String message) => _talker.warning(message);

  void error(String message, [Object? error, StackTrace? stack]) {
    _talker.handle(error ?? Exception(message), stack, message);
  }

  void verbose(String message) => _talker.verbose(message);
}

// ── Crashlytics Observer ───────────────────────────────────
/// Forwards errors & exceptions to Firebase Crashlytics in release mode.
class _CrashlyticsObserver extends TalkerObserver {
  @override
  void onError(TalkerError err) {
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        err.error,
        err.stackTrace,
        reason: err.message,
      );
    }
  }

  @override
  void onException(TalkerException err) {
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        err.exception,
        err.stackTrace,
        reason: err.message,
      );
    }
  }
}
