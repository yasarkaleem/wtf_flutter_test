import 'package:flutter_test/flutter_test.dart';
import 'package:shared/domain/entities/chat_room.dart';

void main() {
  final now = DateTime(2026, 4, 9, 10, 0, 0);

  ChatRoom createChatRoom({
    String id = 'room-1',
    String guruId = 'guru-1',
    String trainerId = 'trainer-1',
    String guruName = 'Guru Alice',
    String trainerName = 'Trainer Bob',
    String? lastMessage,
    DateTime? lastMessageTime,
    int unreadCount = 0,
    bool isTyping = false,
    String? typingUserId,
  }) {
    return ChatRoom(
      id: id,
      guruId: guruId,
      trainerId: trainerId,
      guruName: guruName,
      trainerName: trainerName,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
      isTyping: isTyping,
      typingUserId: typingUserId,
    );
  }

  group('ChatRoom', () {
    group('default values', () {
      test('unreadCount defaults to 0', () {
        final room = ChatRoom(
          id: 'room-1',
          guruId: 'guru-1',
          trainerId: 'trainer-1',
          guruName: 'Alice',
          trainerName: 'Bob',
        );
        expect(room.unreadCount, 0);
      });

      test('isTyping defaults to false', () {
        final room = createChatRoom();
        expect(room.isTyping, false);
      });

      test('lastMessage defaults to null', () {
        final room = createChatRoom();
        expect(room.lastMessage, isNull);
      });

      test('lastMessageTime defaults to null', () {
        final room = createChatRoom();
        expect(room.lastMessageTime, isNull);
      });

      test('typingUserId defaults to null', () {
        final room = createChatRoom();
        expect(room.typingUserId, isNull);
      });
    });

    group('getOtherUserName', () {
      test('returns trainerName when currentUserId is the guru', () {
        final room = createChatRoom(
          guruId: 'guru-1',
          trainerName: 'Trainer Bob',
        );
        expect(room.getOtherUserName('guru-1'), 'Trainer Bob');
      });

      test('returns guruName when currentUserId is the trainer', () {
        final room = createChatRoom(
          trainerId: 'trainer-1',
          guruName: 'Guru Alice',
        );
        expect(room.getOtherUserName('trainer-1'), 'Guru Alice');
      });

      test('returns guruName when currentUserId is unknown', () {
        final room = createChatRoom(guruName: 'Guru Alice');
        expect(room.getOtherUserName('random-user'), 'Guru Alice');
      });
    });

    group('getOtherUserId', () {
      test('returns trainerId when currentUserId is the guru', () {
        final room = createChatRoom(
          guruId: 'guru-1',
          trainerId: 'trainer-1',
        );
        expect(room.getOtherUserId('guru-1'), 'trainer-1');
      });

      test('returns guruId when currentUserId is the trainer', () {
        final room = createChatRoom(
          guruId: 'guru-1',
          trainerId: 'trainer-1',
        );
        expect(room.getOtherUserId('trainer-1'), 'guru-1');
      });

      test('returns guruId when currentUserId is unknown', () {
        final room = createChatRoom(guruId: 'guru-1');
        expect(room.getOtherUserId('random-user'), 'guru-1');
      });
    });

    group('copyWith', () {
      test('updates lastMessage', () {
        final room = createChatRoom();
        final updated = room.copyWith(lastMessage: 'New message');
        expect(updated.lastMessage, 'New message');
      });

      test('updates unreadCount', () {
        final room = createChatRoom(unreadCount: 0);
        final updated = room.copyWith(unreadCount: 5);
        expect(updated.unreadCount, 5);
      });

      test('updates lastMessageTime', () {
        final room = createChatRoom();
        final updated = room.copyWith(lastMessageTime: now);
        expect(updated.lastMessageTime, now);
      });

      test('updates isTyping and typingUserId', () {
        final room = createChatRoom();
        final updated = room.copyWith(
          isTyping: true,
          typingUserId: 'trainer-1',
        );
        expect(updated.isTyping, true);
        expect(updated.typingUserId, 'trainer-1');
      });

      test('preserves unchanged fields', () {
        final room = createChatRoom(
          id: 'room-42',
          guruId: 'guru-1',
          trainerId: 'trainer-1',
          guruName: 'Guru Alice',
          trainerName: 'Trainer Bob',
          lastMessage: 'Hi',
          lastMessageTime: now,
          unreadCount: 3,
        );
        final updated = room.copyWith(unreadCount: 0);

        expect(updated.id, 'room-42');
        expect(updated.guruId, 'guru-1');
        expect(updated.trainerId, 'trainer-1');
        expect(updated.guruName, 'Guru Alice');
        expect(updated.trainerName, 'Trainer Bob');
        expect(updated.lastMessage, 'Hi');
        expect(updated.lastMessageTime, now);
        expect(updated.unreadCount, 0);
      });

      test('with no arguments returns equal object', () {
        final room = createChatRoom();
        final copy = room.copyWith();
        expect(copy, equals(room));
      });
    });

    group('Equatable', () {
      test('two chat rooms with the same properties are equal', () {
        final room1 = createChatRoom();
        final room2 = createChatRoom();
        expect(room1, equals(room2));
      });

      test('two chat rooms with different ids are not equal', () {
        final room1 = createChatRoom(id: 'room-1');
        final room2 = createChatRoom(id: 'room-2');
        expect(room1, isNot(equals(room2)));
      });

      test('two chat rooms with different unreadCount are not equal', () {
        final room1 = createChatRoom(unreadCount: 0);
        final room2 = createChatRoom(unreadCount: 3);
        expect(room1, isNot(equals(room2)));
      });

      test('two chat rooms with different lastMessage are not equal', () {
        final room1 = createChatRoom(lastMessage: 'Hello');
        final room2 = createChatRoom(lastMessage: 'Goodbye');
        expect(room1, isNot(equals(room2)));
      });

      test('props contains all fields', () {
        final room = createChatRoom();
        expect(room.props.length, 10);
      });
    });
  });
}
