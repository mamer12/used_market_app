import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/chat_models.dart';
import '../../domain/repositories/chat_repository.dart';

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
  final ChatRepository _repository;

  // Will be set by the auth system; empty string means isMe will never match.
  String currentUserId = '';

  ChatCubit(this._repository) : super(ChatInitial());

  Future<void> loadConversations() async {
    emit(ChatLoading());
    try {
      final conversations = await _repository.getConversations();
      emit(ConversationsLoaded(conversations));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> loadMessages(String conversationId) async {
    emit(ChatLoading());
    try {
      final messages =
          await _repository.getMessages(conversationId, currentUserId);
      emit(MessagesLoaded(conversationId, messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> sendMessage(String conversationId, String body) async {
    try {
      await _repository.sendMessage(conversationId, body);
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
      return await _repository.createConversation(
        otherUserId: otherUserId,
        contextType: contextType,
        contextId: contextId,
      );
    } catch (_) {
      return null;
    }
  }
}
