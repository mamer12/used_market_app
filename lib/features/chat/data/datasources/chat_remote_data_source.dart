import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/chat_models.dart';

abstract class ChatRemoteDataSource {
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

@LazySingleton(as: ChatRemoteDataSource)
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio _dio;

  ChatRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ConversationModel>> getConversations() async {
    final resp = await _dio.get('/api/v1/conversations');
    final raw = (resp.data['data'] as List?) ?? [];
    return raw
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MessageModel>> getMessages(
      String conversationId, String currentUserId) async {
    final resp =
        await _dio.get('/api/v1/conversations/$conversationId/messages');
    final raw = (resp.data['data'] as List?) ?? [];
    return raw
        .map((e) =>
            MessageModel.fromJson(e as Map<String, dynamic>, currentUserId))
        .toList();
  }

  @override
  Future<void> sendMessage(String conversationId, String body) async {
    await _dio.post(
      '/api/v1/conversations/$conversationId/messages',
      data: {'body': body},
    );
  }

  @override
  Future<String?> createConversation({
    required String otherUserId,
    String contextType = 'general',
    String? contextId,
  }) async {
    final resp = await _dio.post(
      '/api/v1/conversations',
      data: {
        'other_user_id': otherUserId,
        'context_type': contextType,
        'context_id': contextId,
      },
    );
    return resp.data['data']['id'] as String?;
  }
}
