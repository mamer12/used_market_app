import 'package:injectable/injectable.dart';

import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_models.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ConversationModel>> getConversations() =>
      _remoteDataSource.getConversations();

  @override
  Future<List<MessageModel>> getMessages(
          String conversationId, String currentUserId) =>
      _remoteDataSource.getMessages(conversationId, currentUserId);

  @override
  Future<void> sendMessage(String conversationId, String body) =>
      _remoteDataSource.sendMessage(conversationId, body);

  @override
  Future<String?> createConversation({
    required String otherUserId,
    String contextType = 'general',
    String? contextId,
  }) =>
      _remoteDataSource.createConversation(
        otherUserId: otherUserId,
        contextType: contextType,
        contextId: contextId,
      );
}
