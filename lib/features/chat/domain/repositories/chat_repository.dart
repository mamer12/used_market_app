import '../../data/models/chat_models.dart';

abstract class ChatRepository {
  Future<List<ConversationModel>> getConversations();
  Future<List<MessageModel>> getMessages(
      String conversationId, String currentUserId);
  Future<void> sendMessage(String conversationId, String body);
  Future<String?> createConversation({
    required String otherUserId,
    String contextType = 'general',
    String? contextId,
  });
}
