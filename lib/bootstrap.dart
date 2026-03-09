import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

import 'core/config/flavor.dart';
import 'core/di/injection.dart';
import 'core/services/log_service.dart';

Future<void> bootstrap(
  FutureOr<Widget> Function() builder,
  AppFlavor flavor,
) async {
  // ── CRITICAL: Must be called before any plugin usage ───
  WidgetsFlutterBinding.ensureInitialized();

  final log = LogService();

  // ── Global Flutter error handler ──────────────────────
  // Deduplicate to prevent infinite loops when the error itself
  // triggers a new frame (e.g. semantics assertions → Talker log → rebuild).
  String? lastError;
  DateTime lastErrorTime = DateTime(2000);

  FlutterError.onError = (details) {
    final errorStr = details.exceptionAsString();
    final now = DateTime.now();

    // Skip if identical error within last second (breaks the loop)
    if (errorStr == lastError &&
        now.difference(lastErrorTime).inMilliseconds < 1000) {
      return;
    }

    lastError = errorStr;
    lastErrorTime = now;
    log.error(errorStr, details.exception, details.stack);
  };

  // ── BLoC Observer ─────────────────────────────────────
  Bloc.observer = _AppBlocObserver();

  configureDependencies();
  log.info('🚀 Bootstrapping with flavor: ${flavor.name}');

  // ── MCP Toolkit (debug only) ────────────────────────
  // Registers VM service extensions so the Flutter Inspector
  // MCP server can take screenshots, read widget tree, etc.
  assert(() {
    MCPToolkitBinding.instance
      ..initialize()
      ..initializeFlutterToolkit();
    log.info('🔌 MCP Toolkit initialized');
    return true;
  }());

  runApp(await builder());
}

/// Observes all BLoC state changes and errors, forwarding them to [LogService].
class _AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    LogService().debug('BLoC: ${bloc.runtimeType} → $change');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    LogService().error('BLoC Error in ${bloc.runtimeType}', error, stackTrace);
  }
}
