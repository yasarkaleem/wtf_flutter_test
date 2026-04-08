import '../../domain/entities/chat_room.dart' as domain;
import '../../models/chat_room.dart' as model;

/// Maps between the domain [domain.ChatRoom] entity and the
/// Hive-annotated [model.ChatRoom] data model.
class ChatRoomMapper {
  ChatRoomMapper._();

  /// Converts a Hive [model.ChatRoom] to a domain [domain.ChatRoom].
  static domain.ChatRoom toEntity(model.ChatRoom m) {
    return domain.ChatRoom(
      id: m.id,
      guruId: m.guruId,
      trainerId: m.trainerId,
      guruName: m.guruName,
      trainerName: m.trainerName,
      lastMessage: m.lastMessage,
      lastMessageTime: m.lastMessageTime,
      unreadCount: m.unreadCount,
      isTyping: m.isTyping,
      typingUserId: m.typingUserId,
    );
  }

  /// Converts a domain [domain.ChatRoom] to a Hive [model.ChatRoom].
  static model.ChatRoom toModel(domain.ChatRoom entity) {
    return model.ChatRoom(
      id: entity.id,
      guruId: entity.guruId,
      trainerId: entity.trainerId,
      guruName: entity.guruName,
      trainerName: entity.trainerName,
      lastMessage: entity.lastMessage,
      lastMessageTime: entity.lastMessageTime,
      unreadCount: entity.unreadCount,
      isTyping: entity.isTyping,
      typingUserId: entity.typingUserId,
    );
  }
}
