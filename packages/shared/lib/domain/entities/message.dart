import 'package:equatable/equatable.dart';

enum MessageStatus { sending, sent, delivered, read }

enum MessageType { text, system, quickReply }

class Message extends Equatable {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final String status; // sending, sent, delivered, read
  final String type; // text, system, quickReply
  final String? replyToId;

  const Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.status = 'sending',
    this.type = 'text',
    this.replyToId,
  });

  MessageStatus get messageStatus {
    switch (status) {
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sending;
    }
  }

  MessageType get messageType {
    switch (type) {
      case 'system':
        return MessageType.system;
      case 'quickReply':
        return MessageType.quickReply;
      default:
        return MessageType.text;
    }
  }

  bool get isSystem => type == 'system';

  Message copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    String? status,
    String? type,
    String? replyToId,
  }) {
    return Message(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      type: type ?? this.type,
      replyToId: replyToId ?? this.replyToId,
    );
  }

  @override
  List<Object?> get props => [
        id, chatRoomId, senderId, senderName, content,
        timestamp, status, type, replyToId,
      ];
}
