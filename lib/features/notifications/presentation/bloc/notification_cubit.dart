import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// ── States ────────────────────────────────────────────────────────────────────

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<Map<String, dynamic>> notifications;
  final int unreadCount;

  NotificationsLoaded(this.notifications, this.unreadCount);

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

@injectable
class NotificationCubit extends Cubit<NotificationState> {
  final Dio _dio;

  NotificationCubit(this._dio) : super(NotificationInitial());

  Future<void> loadNotifications() async {
    emit(NotificationLoading());
    try {
      final resp = await _dio.get('/api/v1/notifications');
      final data = (resp.data['data'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
      final unread =
          data.where((n) => !(n['is_read'] as bool? ?? false)).length;
      emit(NotificationsLoaded(data, unread));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _dio.patch('/api/v1/notifications/$id/read');
      final current = state;
      if (current is NotificationsLoaded) {
        final updated = current.notifications.map((n) {
          if (n['id'] == id) {
            return {...n, 'is_read': true};
          }
          return n;
        }).toList();
        final unread =
            updated.where((n) => !(n['is_read'] as bool? ?? false)).length;
        emit(NotificationsLoaded(updated, unread));
      }
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _dio.patch('/api/v1/notifications/read-all');
      final current = state;
      if (current is NotificationsLoaded) {
        final updated = current.notifications
            .map((n) => {...n, 'is_read': true})
            .toList();
        emit(NotificationsLoaded(updated, 0));
      }
    } catch (_) {}
  }
}
