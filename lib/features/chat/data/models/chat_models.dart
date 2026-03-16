class ConversationModel {
  final String id;
  final String participantA;
  final String participantB;
  final String contextType;
  final String? contextId;
  final String? lastMessage;
  final int unreadCount;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final String? otherUserName;
  final String? otherUserId;

  const ConversationModel({
    required this.id,
    required this.participantA,
    required this.participantB,
    this.contextType = 'general',
    this.contextId,
    this.lastMessage,
    this.unreadCount = 0,
    this.lastMessageAt,
    required this.createdAt,
    this.otherUserName,
    this.otherUserId,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      participantA: json['participant_a'] as String? ?? '',
      participantB: json['participant_b'] as String? ?? '',
      contextType: json['context_type'] as String? ?? 'general',
      contextId: json['context_id'] as String?,
      lastMessage: json['last_message'] as String?,
      unreadCount: json['unread_count'] as int? ?? 0,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'] as String)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      otherUserName: json['other_user_name'] as String?,
      otherUserId: json['other_user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'participant_a': participantA,
        'participant_b': participantB,
        'context_type': contextType,
        if (contextId != null) 'context_id': contextId,
        if (lastMessage != null) 'last_message': lastMessage,
        'unread_count': unreadCount,
        if (lastMessageAt != null)
          'last_message_at': lastMessageAt!.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        if (otherUserName != null) 'other_user_name': otherUserName,
        if (otherUserId != null) 'other_user_id': otherUserId,
      };
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final bool isMe;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    this.isRead = false,
    required this.createdAt,
    this.isMe = false,
  });

  factory MessageModel.fromJson(
      Map<String, dynamic> json, String currentUserId) {
    final senderId = json['sender_id'] as String? ?? '';
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String? ?? '',
      senderId: senderId,
      body: json['body'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      isMe: senderId == currentUserId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversation_id': conversationId,
        'sender_id': senderId,
        'body': body,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
      };
}
