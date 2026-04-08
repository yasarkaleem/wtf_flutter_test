import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../utils/constants.dart';
import 'log_service.dart';
import 'storage_service.dart';
import 'sync_service.dart';

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final _uuid = const Uuid();

  final _messageNotifier = BehaviorSubject<int>.seeded(0);
  final _roomNotifier = BehaviorSubject<int>.seeded(0);
  final _typingController = BehaviorSubject<Map<String, bool>>.seeded({});

  Stream<int> get messageNotifier => _messageNotifier.stream;
  Stream<int> get roomNotifier => _roomNotifier.stream;
  Stream<Map<String, bool>> get typingStream => _typingController.stream;

  int _messageVersion = 0;
  int _roomVersion = 0;

  Timer? _typingTimer;

  /// Initialize chat system and ensure default chat room exists.
  Future<void> init(String currentUserId) async {
    final storage = StorageService.instance;

    var room = storage.getChatRoom(AppConstants.defaultChatRoomId);
    if (room == null) {
      room = ChatRoom(
        id: AppConstants.defaultChatRoomId,
        guruId: AppConstants.guruId,
        trainerId: AppConstants.trainerId,
        guruName: AppConstants.guruName,
        trainerName: AppConstants.trainerName,
      );
      await storage.saveChatRoom(room);
    }

    _notifyRoomsChanged();
    _notifyMessagesChanged();
    LogService.instance.log(AppConstants.tagChat, 'Chat service initialized');
  }

  /// Send a message in the chat room.
  Future<Message> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String content,
    String type = 'text',
  }) async {
    final storage = StorageService.instance;

    final message = Message(
      id: _uuid.v4(),
      chatRoomId: chatRoomId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: DateTime.now(),
      status: 'sent',
      type: type,
    );

    await storage.saveMessage(message);
    _notifyMessagesChanged();
    LogService.instance.log(
      AppConstants.tagChat,
      'Message sent: ${content.length > 50 ? '${content.substring(0, 50)}...' : content}',
    );

    // Send to the other app via WebSocket
    SyncService.instance.sendChatMessage(message);

    // Update chat room with last message
    final room = storage.getChatRoom(chatRoomId);
    if (room != null) {
      await storage.saveChatRoom(room.copyWith(
        lastMessage: content,
        lastMessageTime: message.timestamp,
      ));
      _notifyRoomsChanged();
    }

    return message;
  }

  /// Mark all messages as read for a user in a chat room.
  Future<void> markAsRead(String chatRoomId, String readerId) async {
    final storage = StorageService.instance;
    final messages = storage.getMessagesForRoom(chatRoomId);
    bool changed = false;

    for (final msg in messages) {
      if (msg.senderId != readerId && msg.status != 'read') {
        await storage.saveMessage(msg.copyWith(status: 'read'));
        changed = true;
      }
    }

    // Reset unread count
    final room = storage.getChatRoom(chatRoomId);
    if (room != null) {
      await storage.saveChatRoom(room.copyWith(unreadCount: 0));
      _notifyRoomsChanged();
    }

    if (changed) {
      _notifyMessagesChanged();
      // Tell the other app so their message ticks update to blue
      SyncService.instance.sendReadReceipt(
        chatRoomId: chatRoomId,
        readerId: readerId,
      );
    }

    LogService.instance.log(
      AppConstants.tagChat,
      'Messages marked as read in $chatRoomId',
    );
  }

  /// Update typing indicator. Also syncs to the other app.
  void setTyping(String chatRoomId, String userId, bool isTyping) {
    final current = Map<String, bool>.from(_typingController.value);
    current[userId] = isTyping;
    _typingController.add(current);

    if (isTyping) {
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(milliseconds: 3000), () {
        final updated = Map<String, bool>.from(_typingController.value);
        updated[userId] = false;
        _typingController.add(updated);
      });
    }
  }

  /// Send typing event to remote app (call from ChatBloc only for local user).
  void sendTypingToRemote(String chatRoomId, String userId, bool isTyping) {
    SyncService.instance.sendTyping(
      chatRoomId: chatRoomId,
      userId: userId,
      isTyping: isTyping,
    );
  }

  /// Add a system message to a chat room.
  Future<void> addSystemMessage(String chatRoomId, String content) async {
    final message = Message(
      id: _uuid.v4(),
      chatRoomId: chatRoomId,
      senderId: 'system',
      senderName: 'System',
      content: content,
      timestamp: DateTime.now(),
      status: 'read',
      type: 'system',
    );

    await StorageService.instance.saveMessage(message);
    _notifyMessagesChanged();
    LogService.instance.log(AppConstants.tagChat, 'System message: $content');
  }

  // ─── Called by SyncService when remote data arrives ─────────

  /// Notify the UI that messages or rooms changed (called by SyncService).
  void onRemoteDataChanged() {
    _notifyMessagesChanged();
    _notifyRoomsChanged();
  }

  // ─── Internal ──────────────────────────────────────────────

  void _notifyMessagesChanged() {
    _messageVersion++;
    _messageNotifier.add(_messageVersion);
  }

  void _notifyRoomsChanged() {
    _roomVersion++;
    _roomNotifier.add(_roomVersion);
  }

  List<Message> getMessagesForRoom(String chatRoomId) {
    return StorageService.instance.getMessagesForRoom(chatRoomId);
  }

  List<ChatRoom> getAllChatRooms() {
    return StorageService.instance.getAllChatRooms();
  }

  void dispose() {
    _typingTimer?.cancel();
    _messageNotifier.close();
    _roomNotifier.close();
    _typingController.close();
  }
}
