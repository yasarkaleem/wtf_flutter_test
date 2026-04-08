import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'message.g.dart';

enum MessageStatus { sending, sent, delivered, read }

enum MessageType { text, system, quickReply }

@HiveType(typeId: 1)
class Message extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String chatRoomId;

  @HiveField(2)
  final String senderId;

  @HiveField(3)
  final String senderName;

  @HiveField(4)
  final String content;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final String status; // sending, sent, delivered, read

  @HiveField(7)
  final String type; // text, system, quickReply

  @HiveField(8)
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'chatRoomId': chatRoomId,
        'senderId': senderId,
        'senderName': senderName,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'status': status,
        'type': type,
        'replyToId': replyToId,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String,
        chatRoomId: json['chatRoomId'] as String,
        senderId: json['senderId'] as String,
        senderName: json['senderName'] as String,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        status: json['status'] as String? ?? 'sending',
        type: json['type'] as String? ?? 'text',
        replyToId: json['replyToId'] as String?,
      );

  @override
  List<Object?> get props => [
        id, chatRoomId, senderId, senderName, content,
        timestamp, status, type, replyToId,
      ];
}
