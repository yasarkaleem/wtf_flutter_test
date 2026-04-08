import 'dart:async';

import '../entities/entities.dart';

/// Abstract interface for chat operations.
abstract class ChatRepository {
  /// Stream that emits a version counter whenever messages change.
  Stream<int> get messageNotifier;

  /// Stream that emits a version counter whenever chat rooms change.
  Stream<int> get roomNotifier;

  /// Stream of per-user typing indicators ({userId: isTyping}).
  Stream<Map<String, bool>> get typingStream;

  /// Initialize the chat system for the given [currentUserId].
  Future<void> init(String currentUserId);

  /// Send a text (or other type) message in the given chat room.
  Future<Message> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String content,
    String type,
  });

  /// Mark all messages in [chatRoomId] as read for [readerId].
  Future<void> markAsRead(String chatRoomId, String readerId);

  /// Update the local typing indicator for [userId] in [chatRoomId].
  void setTyping(String chatRoomId, String userId, bool isTyping);

  /// Send a typing event to the remote app for [userId] in [chatRoomId].
  void sendTypingToRemote(String chatRoomId, String userId, bool isTyping);

  /// Add a system-generated message to the given chat room.
  Future<void> addSystemMessage(String chatRoomId, String content);

  /// Return all messages for [chatRoomId], ordered by timestamp.
  List<Message> getMessagesForRoom(String chatRoomId);

  /// Return all chat rooms.
  List<ChatRoom> getAllChatRooms();

  /// Notify the UI that remote data has changed (e.g. from sync).
  void onRemoteDataChanged();

  /// Release resources.
  void dispose();
}
