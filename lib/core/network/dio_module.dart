import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import '../services/log_service.dart';

/// Configures the Dio HTTP client with interceptors.
///
/// Every request/response is automatically logged via [TalkerDioLogger],
/// visible in the in-app console and dev terminal.
class DioModule {
  static Dio create({required String baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Talker Dio Logger ────────────────────────────────
    // Auto-logs every HTTP call into the Talker console.
    dio.interceptors.add(
      TalkerDioLogger(
        talker: LogService().talker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: false,
          printResponseMessage: true,
        ),
      ),
    );

    // TODO: Add auth interceptor (attach JWT tokens)
    // TODO: Add retry interceptor for transient failures

    return dio;
  }
}
