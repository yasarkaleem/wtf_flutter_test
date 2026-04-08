import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/models.dart';

void main() {
  group('Message Model', () {
    test('creates message with default values', () {
      final msg = Message(
        id: 'msg-1',
        chatRoomId: 'room-1',
        senderId: 'user-1',
        senderName: 'DK',
        content: 'Hello',
        timestamp: DateTime(2026, 4, 7, 10, 0),
      );

      expect(msg.status, 'sending');
      expect(msg.type, 'text');
      expect(msg.replyToId, isNull);
      expect(msg.messageStatus, MessageStatus.sending);
      expect(msg.messageType, MessageType.text);
      expect(msg.isSystem, false);
    });

    test('messageStatus parses all statuses correctly', () {
      final base = Message(
        id: '1',
        chatRoomId: 'r',
        senderId: 's',
        senderName: 'n',
        content: 'c',
        timestamp: DateTime.now(),
      );

      expect(base.copyWith(status: 'sending').messageStatus, MessageStatus.sending);
      expect(base.copyWith(status: 'sent').messageStatus, MessageStatus.sent);
      expect(base.copyWith(status: 'delivered').messageStatus, MessageStatus.delivered);
      expect(base.copyWith(status: 'read').messageStatus, MessageStatus.read);
      expect(base.copyWith(status: 'unknown').messageStatus, MessageStatus.sending);
    });

    test('messageType parses all types correctly', () {
      final base = Message(
        id: '1',
        chatRoomId: 'r',
        senderId: 's',
        senderName: 'n',
        content: 'c',
        timestamp: DateTime.now(),
      );

      expect(base.copyWith(type: 'text').messageType, MessageType.text);
      expect(base.copyWith(type: 'system').messageType, MessageType.system);
      expect(base.copyWith(type: 'quickReply').messageType, MessageType.quickReply);
    });

    test('system message is detected correctly', () {
      final sysMsg = Message(
        id: '1',
        chatRoomId: 'r',
        senderId: 'system',
        senderName: 'System',
        content: 'User joined',
        timestamp: DateTime.now(),
        type: 'system',
      );

      expect(sysMsg.isSystem, true);
      expect(sysMsg.messageType, MessageType.system);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = Message(
        id: '1',
        chatRoomId: 'room',
        senderId: 'user',
        senderName: 'DK',
        content: 'Hello',
        timestamp: DateTime(2026, 4, 7),
        status: 'sending',
      );

      final updated = original.copyWith(status: 'sent', content: 'Updated');

      expect(updated.status, 'sent');
      expect(updated.content, 'Updated');
      expect(updated.id, original.id);
      expect(updated.senderId, original.senderId);
    });

    test('toJson and fromJson roundtrip', () {
      final original = Message(
        id: 'msg-abc',
        chatRoomId: 'room-1',
        senderId: 'user-1',
        senderName: 'DK',
        content: 'Test message',
        timestamp: DateTime(2026, 4, 7, 14, 30),
        status: 'delivered',
        type: 'text',
        replyToId: 'msg-prev',
      );

      final json = original.toJson();
      final restored = Message.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.chatRoomId, original.chatRoomId);
      expect(restored.senderId, original.senderId);
      expect(restored.senderName, original.senderName);
      expect(restored.content, original.content);
      expect(restored.timestamp, original.timestamp);
      expect(restored.status, original.status);
      expect(restored.type, original.type);
      expect(restored.replyToId, original.replyToId);
    });

    test('equatable compares by props', () {
      final ts = DateTime(2026, 4, 7);
      final a = Message(
        id: '1', chatRoomId: 'r', senderId: 's', senderName: 'n',
        content: 'c', timestamp: ts,
      );
      final b = Message(
        id: '1', chatRoomId: 'r', senderId: 's', senderName: 'n',
        content: 'c', timestamp: ts,
      );
      final c = Message(
        id: '2', chatRoomId: 'r', senderId: 's', senderName: 'n',
        content: 'c', timestamp: ts,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
