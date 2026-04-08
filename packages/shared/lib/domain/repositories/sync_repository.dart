import 'dart:async';

import '../entities/entities.dart';

/// Abstract interface for real-time cross-app synchronisation.
abstract class SyncRepository {
  /// Whether the WebSocket connection is currently active.
  bool get isConnected;

  /// Stream that emits `true`/`false` on connection state changes.
  Stream<bool> get connectionStream;

  /// Connect to the sync server as [userId].
  Future<void> connect(String userId);

  /// Disconnect from the sync server.
  Future<void> disconnect();

  /// Send a chat [message] to the remote app.
  void sendChatMessage(Message message);

  /// Send a typing indicator to the remote app.
  void sendTyping({
    required String chatRoomId,
    required String userId,
    required bool isTyping,
  });

  /// Send a read receipt to the remote app.
  void sendReadReceipt({
    required String chatRoomId,
    required String readerId,
  });

  /// Send a schedule create/update to the remote app.
  void sendSchedule(Schedule schedule);

  /// Release resources.
  void dispose();
}
