import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'chat_room.g.dart';

@HiveType(typeId: 2)
class ChatRoom extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String guruId;

  @HiveField(2)
  final String trainerId;

  @HiveField(3)
  final String guruName;

  @HiveField(4)
  final String trainerName;

  @HiveField(5)
  final String? lastMessage;

  @HiveField(6)
  final DateTime? lastMessageTime;

  @HiveField(7)
  final int unreadCount;

  @HiveField(8)
  final bool isTyping;

  @HiveField(9)
  final String? typingUserId;

  const ChatRoom({
    required this.id,
    required this.guruId,
    required this.trainerId,
    required this.guruName,
    required this.trainerName,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isTyping = false,
    this.typingUserId,
  });

  String getOtherUserName(String currentUserId) {
    return currentUserId == guruId ? trainerName : guruName;
  }

  String getOtherUserId(String currentUserId) {
    return currentUserId == guruId ? trainerId : guruId;
  }

  ChatRoom copyWith({
    String? id,
    String? guruId,
    String? trainerId,
    String? guruName,
    String? trainerName,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isTyping,
    String? typingUserId,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      guruId: guruId ?? this.guruId,
      trainerId: trainerId ?? this.trainerId,
      guruName: guruName ?? this.guruName,
      trainerName: trainerName ?? this.trainerName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isTyping: isTyping ?? this.isTyping,
      typingUserId: typingUserId ?? this.typingUserId,
    );
  }

  @override
  List<Object?> get props => [
        id, guruId, trainerId, guruName, trainerName,
        lastMessage, lastMessageTime, unreadCount, isTyping, typingUserId,
      ];
}
