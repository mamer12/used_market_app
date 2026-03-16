import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/chat_models.dart';

// ── States ────────────────────────────────────────────────────────────────────

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<ConversationModel> conversations;

  ConversationsLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class MessagesLoaded extends ChatState {
  final String conversationId;
  final List<MessageModel> messages;

  MessagesLoaded(this.conversationId, this.messages);

  @override
  List<Object?> get props => [conversationId, messages];
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

@injectable
class ChatCubit extends Cubit<ChatState> {
  final Dio _dio;

  // Will be set by the auth system; empty string means isMe will never match.
  String currentUserId = '';

  ChatCubit(this._dio) : super(ChatInitial());

  Future<void> loadConversations() async {
    emit(ChatLoading());
    try {
      final resp = await _dio.get('/api/v1/conversations');
      final raw = (resp.data['data'] as List?) ?? [];
      final conversations = raw
          .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(ConversationsLoaded(conversations));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> loadMessages(String conversationId) async {
    emit(ChatLoading());
    try {
      final resp =
          await _dio.get('/api/v1/conversations/$conversationId/messages');
      final raw = (resp.data['data'] as List?) ?? [];
      final messages = raw
          .map((e) => MessageModel.fromJson(
              e as Map<String, dynamic>, currentUserId))
          .toList();
      emit(MessagesLoaded(conversationId, messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> sendMessage(String conversationId, String body) async {
    try {
      await _dio.post(
        '/api/v1/conversations/$conversationId/messages',
        data: {'body': body},
      );
      await loadMessages(conversationId);
    } catch (_) {
      // Keep current state; caller may show snackbar
    }
  }

  Future<String?> startConversation({
    required String otherUserId,
    String contextType = 'general',
    String? contextId,
  }) async {
    try {
      final resp = await _dio.post(
        '/api/v1/conversations',
        data: {
          'other_user_id': otherUserId,
          'context_type': contextType,
          if (contextId != null) 'context_id': contextId,
        },
      );
      return resp.data['data']['id'] as String?;
    } catch (_) {
      return null;
    }
  }
}
