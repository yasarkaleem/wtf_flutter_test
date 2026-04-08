import 'package:flutter_test/flutter_test.dart';
import 'package:shared/presentation/bloc/chat/chat_bloc.dart';
import 'package:shared/domain/entities/entities.dart';

void main() {
  group('ChatState.isOtherUserTyping', () {
    test('returns false when typingStatus is empty', () {
      const state = ChatState(
        currentUserId: 'user_1',
        typingStatus: {},
      );
      expect(state.isOtherUserTyping, isFalse);
    });

    test('returns false when only current user is typing', () {
      const state = ChatState(
        currentUserId: 'user_1',
        typingStatus: {'user_1': true},
      );
      expect(state.isOtherUserTyping, isFalse);
    });

    test('returns true when other user is typing', () {
      const state = ChatState(
        currentUserId: 'user_1',
        typingStatus: {'user_2': true},
      );
      expect(state.isOtherUserTyping, isTrue);
    });

    test('returns true when other user is typing alongside current user', () {
      const state = ChatState(
        currentUserId: 'user_1',
        typingStatus: {'user_1': true, 'user_2': true},
      );
      expect(state.isOtherUserTyping, isTrue);
    });

    test('returns false when other user typing value is false', () {
      const state = ChatState(
        currentUserId: 'user_1',
        typingStatus: {'user_2': false},
      );
      expect(state.isOtherUserTyping, isFalse);
    });

    test('returns false when currentUserId is null', () {
      const state = ChatState(
        currentUserId: null,
        typingStatus: {'user_2': true},
      );
      expect(state.isOtherUserTyping, isFalse);
    });
  });

  group('ChatState.copyWith', () {
    test('preserves unchanged fields', () {
      final now = DateTime(2025, 6, 1, 12, 0);
      final messages = [
        Message(
          id: 'msg_1',
          chatRoomId: 'room_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
          timestamp: now,
        ),
      ];

      final state = ChatState(
        messages: messages,
        isLoading: true,
        activeChatRoomId: 'room_1',
        version: 5,
        currentUserId: 'user_1',
      );

      final newState = state.copyWith(isLoading: false);

      expect(newState.messages, messages);
      expect(newState.isLoading, isFalse);
      expect(newState.activeChatRoomId, 'room_1');
      expect(newState.version, 5);
      expect(newState.currentUserId, 'user_1');
    });

    test('clears error when not passed', () {
      const state = ChatState(error: 'Something went wrong');

      // copyWith without passing error should result in null error
      final newState = state.copyWith(isLoading: true);

      expect(newState.error, isNull);
    });

    test('sets error when passed', () {
      const state = ChatState();
      final newState = state.copyWith(error: 'Network error');
      expect(newState.error, 'Network error');
    });

    test('updates multiple fields at once', () {
      const state = ChatState(
        isLoading: false,
        version: 0,
        currentUserId: 'user_1',
      );

      final newState = state.copyWith(
        isLoading: true,
        version: 1,
        activeChatRoomId: 'room_1',
      );

      expect(newState.isLoading, isTrue);
      expect(newState.version, 1);
      expect(newState.activeChatRoomId, 'room_1');
      expect(newState.currentUserId, 'user_1');
    });
  });

  group('ChatState version', () {
    test('default version is 0', () {
      const state = ChatState();
      expect(state.version, 0);
    });

    test('version increments via copyWith', () {
      const state = ChatState(version: 0);
      final next = state.copyWith(version: 1);
      expect(next.version, 1);

      final next2 = next.copyWith(version: 2);
      expect(next2.version, 2);
    });
  });

  group('ChatState equality', () {
    test('two states with same fields are equal', () {
      const state1 = ChatState(
        isLoading: true,
        version: 1,
        currentUserId: 'user_1',
      );
      const state2 = ChatState(
        isLoading: true,
        version: 1,
        currentUserId: 'user_1',
      );
      expect(state1, equals(state2));
    });

    test('two states with different fields are not equal', () {
      const state1 = ChatState(version: 1);
      const state2 = ChatState(version: 2);
      expect(state1, isNot(equals(state2)));
    });
  });
}
