import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/log_service.dart';
import '../../data/datasources/feed_remote_datasource.dart';
import '../../data/models/feed_models.dart';

// ── State ─────────────────────────────────────────────────────────────────

class FeedState {
  final bool isLoading;
  final bool personalized;
  final List<FeedItem> items;
  final String? error;

  const FeedState({
    this.isLoading = false,
    this.personalized = false,
    this.items = const [],
    this.error,
  });

  FeedState copyWith({
    bool? isLoading,
    bool? personalized,
    List<FeedItem>? items,
    String? error,
    bool clearError = false,
  }) {
    return FeedState(
      isLoading: isLoading ?? this.isLoading,
      personalized: personalized ?? this.personalized,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Cubit ─────────────────────────────────────────────────────────────────

@injectable
class FeedCubit extends Cubit<FeedState> {
  final FeedRemoteDataSource _dataSource;

  FeedCubit(this._dataSource) : super(const FeedState());

  Future<void> loadFeed() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final result = await _dataSource.getForYouFeed();
      emit(state.copyWith(
        isLoading: false,
        personalized: result.personalized,
        items: result.items,
      ));
    } on DioException catch (e, st) {
      LogService().error('FeedCubit: loadFeed failed', e, st);
      emit(state.copyWith(
        isLoading: false,
        error: 'تعذر تحميل الفيد — تحقق من الاتصال',
      ));
    } catch (e, st) {
      LogService().error('FeedCubit: loadFeed unexpected error', e, st);
      emit(state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع'));
    }
  }

  /// Fire-and-forget event tracking; errors are logged but not surfaced.
  void trackView(FeedItem item) {
    final entityType = item.kind == 'auction' ? 'auction' : 'product';
    _dataSource
        .trackEvent(
          eventType: 'view',
          entityType: entityType,
          entityId: item.id,
        )
        .catchError((Object e) {
      LogService().error('FeedCubit: trackView failed', e, null);
      return null;
    });
  }
}
