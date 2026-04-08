import 'package:flutter_test/flutter_test.dart';
import 'package:shared/domain/entities/message.dart';

void main() {
  final now = DateTime(2026, 4, 9, 14, 30, 0);

  Message createMessage({
    String id = 'msg-1',
    String chatRoomId = 'room-1',
    String senderId = 'user-1',
    String senderName = 'John',
    String content = 'Hello',
    DateTime? timestamp,
    String status = 'sending',
    String type = 'text',
    String? replyToId,
  }) {
    return Message(
      id: id,
      chatRoomId: chatRoomId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: timestamp ?? now,
      status: status,
      type: type,
      replyToId: replyToId,
    );
  }

  group('Message', () {
    group('default values', () {
      test('status defaults to "sending"', () {
        final message = Message(
          id: 'msg-1',
          chatRoomId: 'room-1',
          senderId: 'user-1',
          senderName: 'John',
          content: 'Hello',
          timestamp: now,
        );
        expect(message.status, 'sending');
      });

      test('type defaults to "text"', () {
        final message = Message(
          id: 'msg-1',
          chatRoomId: 'room-1',
          senderId: 'user-1',
          senderName: 'John',
          content: 'Hello',
          timestamp: now,
        );
        expect(message.type, 'text');
      });

      test('replyToId defaults to null', () {
        final message = createMessage();
        expect(message.replyToId, isNull);
      });
    });

    group('messageStatus getter', () {
      test('returns MessageStatus.sending for "sending"', () {
        final message = createMessage(status: 'sending');
        expect(message.messageStatus, MessageStatus.sending);
      });

      test('returns MessageStatus.sent for "sent"', () {
        final message = createMessage(status: 'sent');
        expect(message.messageStatus, MessageStatus.sent);
      });

      test('returns MessageStatus.delivered for "delivered"', () {
        final message = createMessage(status: 'delivered');
        expect(message.messageStatus, MessageStatus.delivered);
      });

      test('returns MessageStatus.read for "read"', () {
        final message = createMessage(status: 'read');
        expect(message.messageStatus, MessageStatus.read);
      });

      test('returns MessageStatus.sending for unknown status string', () {
        final message = createMessage(status: 'unknown');
        expect(message.messageStatus, MessageStatus.sending);
      });
    });

    group('messageType getter', () {
      test('returns MessageType.text for "text"', () {
        final message = createMessage(type: 'text');
        expect(message.messageType, MessageType.text);
      });

      test('returns MessageType.system for "system"', () {
        final message = createMessage(type: 'system');
        expect(message.messageType, MessageType.system);
      });

      test('returns MessageType.quickReply for "quickReply"', () {
        final message = createMessage(type: 'quickReply');
        expect(message.messageType, MessageType.quickReply);
      });

      test('returns MessageType.text for unknown type string', () {
        final message = createMessage(type: 'image');
        expect(message.messageType, MessageType.text);
      });
    });

    group('isSystem', () {
      test('returns true when type is "system"', () {
        final message = createMessage(type: 'system');
        expect(message.isSystem, isTrue);
      });

      test('returns false when type is "text"', () {
        final message = createMessage(type: 'text');
        expect(message.isSystem, isFalse);
      });

      test('returns false when type is "quickReply"', () {
        final message = createMessage(type: 'quickReply');
        expect(message.isSystem, isFalse);
      });
    });

    group('copyWith', () {
      test('updates status while preserving other fields', () {
        final message = createMessage(status: 'sending');
        final updated = message.copyWith(status: 'sent');

        expect(updated.status, 'sent');
        expect(updated.id, message.id);
        expect(updated.content, message.content);
        expect(updated.chatRoomId, message.chatRoomId);
        expect(updated.senderId, message.senderId);
        expect(updated.senderName, message.senderName);
        expect(updated.timestamp, message.timestamp);
        expect(updated.type, message.type);
        expect(updated.replyToId, message.replyToId);
      });

      test('updates type', () {
        final message = createMessage(type: 'text');
        final updated = message.copyWith(type: 'system');
        expect(updated.type, 'system');
      });

      test('updates replyToId', () {
        final message = createMessage();
        final updated = message.copyWith(replyToId: 'reply-1');
        expect(updated.replyToId, 'reply-1');
      });

      test('with no arguments returns equal object', () {
        final message = createMessage();
        final copy = message.copyWith();
        expect(copy, equals(message));
      });
    });

    group('Equatable', () {
      test('two messages with the same properties are equal', () {
        final msg1 = createMessage();
        final msg2 = createMessage();
        expect(msg1, equals(msg2));
      });

      test('two messages with different ids are not equal', () {
        final msg1 = createMessage(id: 'msg-1');
        final msg2 = createMessage(id: 'msg-2');
        expect(msg1, isNot(equals(msg2)));
      });

      test('two messages with different content are not equal', () {
        final msg1 = createMessage(content: 'Hello');
        final msg2 = createMessage(content: 'Goodbye');
        expect(msg1, isNot(equals(msg2)));
      });

      test('two messages with different statuses are not equal', () {
        final msg1 = createMessage(status: 'sending');
        final msg2 = createMessage(status: 'sent');
        expect(msg1, isNot(equals(msg2)));
      });

      test('props contains all fields including nullable replyToId', () {
        final message = createMessage(replyToId: 'reply-1');
        expect(message.props.length, 9);
        expect(message.props, contains('reply-1'));
      });
    });
  });
}
