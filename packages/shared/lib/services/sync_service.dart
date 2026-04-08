import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/models.dart';
import '../utils/constants.dart';
import 'log_service.dart';
import 'storage_service.dart';
import 'chat_service.dart';
import 'schedule_service.dart';

/// Handles real-time cross-app communication via WebSocket.
///
/// Protocol — every message is JSON with `{"type": "...", "data": {...}}`.
///
/// Types sent/received:
///   chat_message    — a Message object
///   typing          — {chatRoomId, userId, isTyping}
///   read_receipt    — {chatRoomId, readerId}
///   schedule        — a Schedule object
///   presence        — {userId, isOnline} (server-generated)
class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  String? _userId;
  bool _connected = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const _maxReconnectAttempts = 10;
  static const _reconnectDelay = Duration(seconds: 3);

  bool get isConnected => _connected;

  final _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  // ─── Lifecycle ──────────────────────────────────────────────

  Future<void> connect(String userId) async {
    _userId = userId;
    _reconnectAttempts = 0;
    await _connectInternal();
  }

  Future<void> _connectInternal() async {
    if (_userId == null) return;

    try {
      // Use dart:io WebSocket directly for reliable connection on iOS/Android
      final ws = await WebSocket.connect(AppConstants.wsServerUrl)
          .timeout(const Duration(seconds: 5));
      _channel = IOWebSocketChannel(ws);

      // Register with server
      _send({'type': 'register', 'userId': _userId});

      _connected = true;
      _reconnectAttempts = 0;
      _connectionController.add(true);
      LogService.instance.log(AppConstants.tagChat, 'Sync connected as $_userId');

      _subscription = _channel!.stream.listen(
        _onData,
        onError: (e) {
          LogService.instance.error(AppConstants.tagChat, 'Sync error', e);
          _handleDisconnect();
        },
        onDone: _handleDisconnect,
      );
    } catch (e) {
      LogService.instance.error(
        AppConstants.tagChat,
        'Sync connect failed (attempt ${_reconnectAttempts + 1})',
        e,
      );
      _connected = false;
      _connectionController.add(false);
      _scheduleReconnect();
    }
  }

  void _handleDisconnect() {
    _connected = false;
    _connectionController.add(false);
    _subscription?.cancel();
    _subscription = null;
    LogService.instance.log(AppConstants.tagChat, 'Sync disconnected');
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_userId == null) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      LogService.instance.log(
        AppConstants.tagChat,
        'Sync: max reconnect attempts reached, giving up',
      );
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectAttempts++;
    _reconnectTimer = Timer(_reconnectDelay, _connectInternal);
  }

  Future<void> disconnect() async {
    _userId = null;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
    _connected = false;
    _connectionController.add(false);
    LogService.instance.log(AppConstants.tagChat, 'Sync disconnected (manual)');
  }

  // ─── Send helpers ───────────────────────────────────────────

  void _send(Map<String, dynamic> msg) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode(msg));
  }

  /// Send a chat message to the other app.
  void sendChatMessage(Message message) {
    _send({'type': 'chat_message', 'data': message.toJson()});
  }

  /// Send typing indicator.
  void sendTyping({
    required String chatRoomId,
    required String userId,
    required bool isTyping,
  }) {
    _send({
      'type': 'typing',
      'data': {
        'chatRoomId': chatRoomId,
        'userId': userId,
        'isTyping': isTyping,
      },
    });
  }

  /// Send read receipt.
  void sendReadReceipt({
    required String chatRoomId,
    required String readerId,
  }) {
    _send({
      'type': 'read_receipt',
      'data': {'chatRoomId': chatRoomId, 'readerId': readerId},
    });
  }

  /// Send schedule update (create, approve, decline, cancel).
  void sendSchedule(Schedule schedule) {
    _send({'type': 'schedule', 'data': schedule.toJson()});
  }

  // ─── Receive handler ───────────────────────────────────────

  void _onData(dynamic raw) {
    Map<String, dynamic> msg;
    try {
      msg = jsonDecode(raw as String) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final type = msg['type'] as String?;
    final data = msg['data'] as Map<String, dynamic>?;
    if (type == null || data == null) return;

    LogService.instance.log(AppConstants.tagChat, 'Sync received: $type');

    switch (type) {
      case 'chat_message':
        _onRemoteMessage(data);
      case 'typing':
        _onRemoteTyping(data);
      case 'read_receipt':
        _onRemoteReadReceipt(data);
      case 'schedule':
        _onRemoteSchedule(data);
      case 'presence':
        _onPresence(data);
    }
  }

  // ─── Remote event handlers ─────────────────────────────────

  Future<void> _onRemoteMessage(Map<String, dynamic> data) async {
    final message = Message.fromJson(data);

    // Save with 'sent' status — only changes to 'read' when
    // the recipient actually opens the chat screen.
    await StorageService.instance.saveMessage(message);

    // Update the chat room's last message + bump unread
    final room = StorageService.instance.getChatRoom(message.chatRoomId);
    if (room != null) {
      await StorageService.instance.saveChatRoom(room.copyWith(
        lastMessage: message.content,
        lastMessageTime: message.timestamp,
        unreadCount: room.unreadCount + 1,
      ));
    }

    ChatService.instance.onRemoteDataChanged();
  }

  void _onRemoteTyping(Map<String, dynamic> data) {
    final chatRoomId = data['chatRoomId'] as String;
    final userId = data['userId'] as String;
    final isTyping = data['isTyping'] as bool;
    ChatService.instance.setTyping(chatRoomId, userId, isTyping);
  }

  Future<void> _onRemoteReadReceipt(Map<String, dynamic> data) async {
    final chatRoomId = data['chatRoomId'] as String;
    final readerId = data['readerId'] as String;

    // Mark messages sent BY the current user as 'read'
    // (the other user read them)
    final messages = StorageService.instance.getMessagesForRoom(chatRoomId);
    for (final msg in messages) {
      if (msg.senderId != readerId && msg.status != 'read') {
        await StorageService.instance.saveMessage(msg.copyWith(status: 'read'));
      }
    }

    ChatService.instance.onRemoteDataChanged();
  }

  Future<void> _onRemoteSchedule(Map<String, dynamic> data) async {
    final schedule = Schedule.fromJson(data);

    // Check existing status before overwriting
    final existing = StorageService.instance.getSchedule(schedule.id);

    // Save the schedule
    await StorageService.instance.saveSchedule(schedule);

    // Add a system message if status changed or is new
    if (existing == null || existing.status != schedule.status) {
      String? systemMsg;
      switch (schedule.status) {
        case 'pending':
          systemMsg =
              '${schedule.guruName} requested a session on '
              '${schedule.scheduledAt.day}/${schedule.scheduledAt.month}/${schedule.scheduledAt.year} '
              'at ${schedule.scheduledAt.hour.toString().padLeft(2, '0')}:'
              '${schedule.scheduledAt.minute.toString().padLeft(2, '0')}';
        case 'approved':
          systemMsg = '${schedule.trainerName} approved the session request';
        case 'declined':
          systemMsg = '${schedule.trainerName} declined the session request';
        case 'cancelled':
          systemMsg = 'Session was cancelled';
      }
      if (systemMsg != null) {
        await ChatService.instance.addSystemMessage(
          schedule.chatRoomId,
          systemMsg,
        );
      }
    }

    ScheduleService.instance.onRemoteDataChanged();
  }

  void _onPresence(Map<String, dynamic> data) {
    final userId = data['userId'] as String?;
    final isOnline = data['isOnline'] as bool? ?? false;
    if (userId != null) {
      LogService.instance.log(
        AppConstants.tagChat,
        'Presence: $userId is ${isOnline ? "online" : "offline"}',
      );
    }
  }

  void dispose() {
    disconnect();
    _connectionController.close();
  }
}
