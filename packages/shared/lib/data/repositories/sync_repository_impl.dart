import 'dart:async';

import '../../domain/entities/entities.dart' as domain;
import '../../domain/repositories/sync_repository.dart';
import '../../services/sync_service.dart';
import '../mappers/message_mapper.dart';
import '../mappers/schedule_mapper.dart';

/// Thin wrapper around [SyncService] that satisfies the [SyncRepository]
/// contract.  Delegates every call to the existing singleton and uses
/// mappers to convert domain entities to the model types expected by the
/// service.
class SyncRepositoryImpl implements SyncRepository {
  final SyncService _service = SyncService.instance;

  @override
  bool get isConnected => _service.isConnected;

  @override
  Stream<bool> get connectionStream => _service.connectionStream;

  @override
  Future<void> connect(String userId) => _service.connect(userId);

  @override
  Future<void> disconnect() => _service.disconnect();

  @override
  void sendChatMessage(domain.Message message) =>
      _service.sendChatMessage(MessageMapper.toModel(message));

  @override
  void sendTyping({
    required String chatRoomId,
    required String userId,
    required bool isTyping,
  }) =>
      _service.sendTyping(
        chatRoomId: chatRoomId,
        userId: userId,
        isTyping: isTyping,
      );

  @override
  void sendReadReceipt({
    required String chatRoomId,
    required String readerId,
  }) =>
      _service.sendReadReceipt(
        chatRoomId: chatRoomId,
        readerId: readerId,
      );

  @override
  void sendSchedule(domain.Schedule schedule) =>
      _service.sendSchedule(ScheduleMapper.toModel(schedule));

  @override
  void dispose() => _service.dispose();
}
