import 'dart:async';

import '../../domain/entities/entities.dart' as domain;
import '../../domain/repositories/chat_repository.dart';
import '../../services/chat_service.dart';
import '../mappers/message_mapper.dart';
import '../mappers/chat_room_mapper.dart';

/// Thin wrapper around [ChatService] that satisfies the [ChatRepository]
/// contract.  Delegates every call to the existing singleton and uses
/// mappers to convert between model and domain types.
class ChatRepositoryImpl implements ChatRepository {
  final ChatService _service = ChatService.instance;

  @override
  Stream<int> get messageNotifier => _service.messageNotifier;

  @override
  Stream<int> get roomNotifier => _service.roomNotifier;

  @override
  Stream<Map<String, bool>> get typingStream => _service.typingStream;

  @override
  Future<void> init(String currentUserId) => _service.init(currentUserId);

  @override
  Future<domain.Message> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String content,
    String type = 'text',
  }) async {
    final model = await _service.sendMessage(
      chatRoomId: chatRoomId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
    );
    return MessageMapper.toEntity(model);
  }

  @override
  Future<void> markAsRead(String chatRoomId, String readerId) =>
      _service.markAsRead(chatRoomId, readerId);

  @override
  void setTyping(String chatRoomId, String userId, bool isTyping) =>
      _service.setTyping(chatRoomId, userId, isTyping);

  @override
  void sendTypingToRemote(String chatRoomId, String userId, bool isTyping) =>
      _service.sendTypingToRemote(chatRoomId, userId, isTyping);

  @override
  Future<void> addSystemMessage(String chatRoomId, String content) =>
      _service.addSystemMessage(chatRoomId, content);

  @override
  List<domain.Message> getMessagesForRoom(String chatRoomId) =>
      _service.getMessagesForRoom(chatRoomId).map(MessageMapper.toEntity).toList();

  @override
  List<domain.ChatRoom> getAllChatRooms() =>
      _service.getAllChatRooms().map(ChatRoomMapper.toEntity).toList();

  @override
  void onRemoteDataChanged() => _service.onRemoteDataChanged();

  @override
  void dispose() => _service.dispose();
}
