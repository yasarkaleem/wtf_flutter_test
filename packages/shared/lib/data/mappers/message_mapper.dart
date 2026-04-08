import '../../domain/entities/message.dart' as domain;
import '../../models/message.dart' as model;

/// Maps between the domain [domain.Message] entity and the
/// Hive-annotated [model.Message] data model.
class MessageMapper {
  MessageMapper._();

  /// Converts a Hive [model.Message] to a domain [domain.Message].
  static domain.Message toEntity(model.Message m) {
    return domain.Message(
      id: m.id,
      chatRoomId: m.chatRoomId,
      senderId: m.senderId,
      senderName: m.senderName,
      content: m.content,
      timestamp: m.timestamp,
      status: m.status,
      type: m.type,
      replyToId: m.replyToId,
    );
  }

  /// Converts a domain [domain.Message] to a Hive [model.Message].
  static model.Message toModel(domain.Message entity) {
    return model.Message(
      id: entity.id,
      chatRoomId: entity.chatRoomId,
      senderId: entity.senderId,
      senderName: entity.senderName,
      content: entity.content,
      timestamp: entity.timestamp,
      status: entity.status,
      type: entity.type,
      replyToId: entity.replyToId,
    );
  }
}
