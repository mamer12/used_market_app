import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../di/injection.dart';
import '../network/api_constants.dart';

// ── Model ────────────────────────────────────────────────────────────────────

class SooqAvailability {
  final String sooqId;
  final bool isActive;
  final List<String> cityCodes;

  const SooqAvailability({
    required this.sooqId,
    required this.isActive,
    this.cityCodes = const [],
  });

  factory SooqAvailability.fromJson(Map<String, dynamic> json) =>
      SooqAvailability(
        sooqId: json['sooq_id'] as String,
        isActive: json['is_active'] as bool,
        cityCodes: (json['city_codes'] as List<dynamic>?)
                ?.cast<String>() ??
            const [],
      );
}

// ── State ─────────────────────────────────────────────────────────────────────

sealed class SooqConfigState {
  const SooqConfigState();
}

class SooqConfigLoading extends SooqConfigState {
  const SooqConfigLoading();
}

class SooqConfigLoaded extends SooqConfigState {
  final List<SooqAvailability> sooqs;
  const SooqConfigLoaded(this.sooqs);

  bool isSooqActive(String sooqId) =>
      sooqs.any((s) => s.sooqId == sooqId && s.isActive);
}

class SooqConfigError extends SooqConfigState {
  /// On error we still provide a fallback list so the app stays usable.
  final List<SooqAvailability> fallback;
  const SooqConfigError(this.fallback);

  bool isSooqActive(String sooqId) =>
      fallback.any((s) => s.sooqId == sooqId && s.isActive);
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

@injectable
class SooqConfigCubit extends Cubit<SooqConfigState> {
  SooqConfigCubit() : super(const SooqConfigLoading());

  /// Fetches active Sooqs for the given [cityCode] from the backend.
  /// On network failure, fails open with all Sooqs active so a temporary
  /// server issue doesn't block the entire app.
  Future<void> loadConfig({String cityCode = 'BGW'}) async {
    emit(const SooqConfigLoading());
    try {
      final dio = getIt<Dio>();
      final response = await dio.get(
        '${ApiConstants.baseUrl}sooqs/available',
        options: Options(headers: {'X-City-Code': cityCode}),
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      final sooqs = data
          .map((e) => SooqAvailability.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(SooqConfigLoaded(sooqs));
    } catch (_) {
      emit(SooqConfigError(_defaultAllActive()));
    }
  }

  /// Convenience: returns true if the given Sooq is active in current state.
  bool isSooqActive(String sooqId) {
    final s = state;
    if (s is SooqConfigLoaded) return s.isSooqActive(sooqId);
    if (s is SooqConfigError) return s.isSooqActive(sooqId);
    return true; // while loading, don't block UI
  }

  static List<SooqAvailability> _defaultAllActive() => const [
        SooqAvailability(sooqId: 'mazadat',  isActive: true),
        SooqAvailability(sooqId: 'matajir',  isActive: true),
        SooqAvailability(sooqId: 'balla',    isActive: true),
        SooqAvailability(sooqId: 'mustamal', isActive: true),
      ];
}
