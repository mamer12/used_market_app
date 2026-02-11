import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/flavor.dart';
import 'core/services/log_service.dart';

Future<void> bootstrap(
  FutureOr<Widget> Function() builder,
  AppFlavor flavor,
) async {
  final log = LogService();

  // ── Global Flutter error handler ──────────────────────
  FlutterError.onError = (details) {
    log.error(
      details.exceptionAsString(),
      details.exception,
      details.stack,
    );
  };

  // ── BLoC Observer ─────────────────────────────────────
  Bloc.observer = _AppBlocObserver();

  // TODO: Initialize DI (GetIt) here

  log.info('🚀 Bootstrapping with flavor: ${flavor.name}');

  runApp(await builder());
}

/// Observes all BLoC state changes and errors, forwarding them to [LogService].
class _AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    // Tracks exactly what the user did before a crash
    LogService().debug('BLoC: ${bloc.runtimeType} → $change');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    LogService().error(
      'BLoC Error in ${bloc.runtimeType}',
      error,
      stackTrace,
    );
  }
}