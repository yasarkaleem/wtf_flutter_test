import 'package:flutter_test/flutter_test.dart';

import 'package:shared/domain/entities/app_user.dart' as domain;
import 'package:shared/domain/entities/message.dart' as domain;
import 'package:shared/domain/entities/chat_room.dart' as domain;
import 'package:shared/domain/entities/schedule.dart' as domain;
import 'package:shared/domain/entities/session_log.dart' as domain;

import 'package:shared/models/user.dart' as model;
import 'package:shared/models/message.dart' as model;
import 'package:shared/models/chat_room.dart' as model;
import 'package:shared/models/schedule.dart' as model;
import 'package:shared/models/session_log.dart' as model;

import 'package:shared/data/mappers/user_mapper.dart';
import 'package:shared/data/mappers/message_mapper.dart';
import 'package:shared/data/mappers/chat_room_mapper.dart';
import 'package:shared/data/mappers/schedule_mapper.dart';
import 'package:shared/data/mappers/session_log_mapper.dart';

void main() {
  group('UserMapper roundtrip', () {
    test('toEntity and toModel preserve all fields', () {
      final lastSeen = DateTime(2025, 6, 15, 10, 30);
      final originalModel = model.AppUser(
        id: 'user_001',
        name: 'John Doe',
        email: 'john@example.com',
        avatarUrl: 'https://example.com/avatar.png',
        role: 'guru',
        isOnline: true,
        lastSeen: lastSeen,
      );

      final entity = UserMapper.toEntity(originalModel);

      expect(entity.id, originalModel.id);
      expect(entity.name, originalModel.name);
      expect(entity.email, originalModel.email);
      expect(entity.avatarUrl, originalModel.avatarUrl);
      expect(entity.role, originalModel.role);
      expect(entity.isOnline, originalModel.isOnline);
      expect(entity.lastSeen, originalModel.lastSeen);

      final roundTrippedModel = UserMapper.toModel(entity);

      expect(roundTrippedModel.id, originalModel.id);
      expect(roundTrippedModel.name, originalModel.name);
      expect(roundTrippedModel.email, originalModel.email);
      expect(roundTrippedModel.avatarUrl, originalModel.avatarUrl);
      expect(roundTrippedModel.role, originalModel.role);
      expect(roundTrippedModel.isOnline, originalModel.isOnline);
      expect(roundTrippedModel.lastSeen, originalModel.lastSeen);
    });

    test('handles default values', () {
      final lastSeen = DateTime(2025, 1, 1);
      final originalModel = model.AppUser(
        id: 'user_002',
        name: 'Jane',
        email: 'jane@test.com',
        role: 'trainer',
        lastSeen: lastSeen,
      );

      final entity = UserMapper.toEntity(originalModel);
      expect(entity.avatarUrl, '');
      expect(entity.isOnline, false);

      final roundTripped = UserMapper.toModel(entity);
      expect(roundTripped.avatarUrl, '');
      expect(roundTripped.isOnline, false);
    });
  });

  group('MessageMapper roundtrip', () {
    test('toEntity and toModel preserve all fields', () {
      final timestamp = DateTime(2025, 6, 15, 14, 0);
      final originalModel = model.Message(
        id: 'msg_001',
        chatRoomId: 'room_001',
        senderId: 'user_001',
        senderName: 'John',
        content: 'Hello there!',
        timestamp: timestamp,
        status: 'delivered',
        type: 'text',
        replyToId: 'msg_000',
      );

      final entity = MessageMapper.toEntity(originalModel);

      expect(entity.id, originalModel.id);
      expect(entity.chatRoomId, originalModel.chatRoomId);
      expect(entity.senderId, originalModel.senderId);
      expect(entity.senderName, originalModel.senderName);
      expect(entity.content, originalModel.content);
      expect(entity.timestamp, originalModel.timestamp);
      expect(entity.status, originalModel.status);
      expect(entity.type, originalModel.type);
      expect(entity.replyToId, originalModel.replyToId);

      final roundTripped = MessageMapper.toModel(entity);

      expect(roundTripped.id, originalModel.id);
      expect(roundTripped.chatRoomId, originalModel.chatRoomId);
      expect(roundTripped.senderId, originalModel.senderId);
      expect(roundTripped.senderName, originalModel.senderName);
      expect(roundTripped.content, originalModel.content);
      expect(roundTripped.timestamp, originalModel.timestamp);
      expect(roundTripped.status, originalModel.status);
      expect(roundTripped.type, originalModel.type);
      expect(roundTripped.replyToId, originalModel.replyToId);
    });

    test('handles null replyToId and default values', () {
      final timestamp = DateTime(2025, 1, 1);
      final originalModel = model.Message(
        id: 'msg_002',
        chatRoomId: 'room_001',
        senderId: 'user_002',
        senderName: 'Jane',
        content: 'Hi!',
        timestamp: timestamp,
      );

      final entity = MessageMapper.toEntity(originalModel);
      expect(entity.status, 'sending');
      expect(entity.type, 'text');
      expect(entity.replyToId, isNull);

      final roundTripped = MessageMapper.toModel(entity);
      expect(roundTripped.status, 'sending');
      expect(roundTripped.type, 'text');
      expect(roundTripped.replyToId, isNull);
    });
  });

  group('ChatRoomMapper roundtrip', () {
    test('toEntity and toModel preserve all fields', () {
      final lastMessageTime = DateTime(2025, 6, 15, 16, 0);
      final originalModel = model.ChatRoom(
        id: 'room_001',
        guruId: 'guru_001',
        trainerId: 'trainer_001',
        guruName: 'DK',
        trainerName: 'Aarav',
        lastMessage: 'See you later!',
        lastMessageTime: lastMessageTime,
        unreadCount: 3,
        isTyping: true,
        typingUserId: 'trainer_001',
      );

      final entity = ChatRoomMapper.toEntity(originalModel);

      expect(entity.id, originalModel.id);
      expect(entity.guruId, originalModel.guruId);
      expect(entity.trainerId, originalModel.trainerId);
      expect(entity.guruName, originalModel.guruName);
      expect(entity.trainerName, originalModel.trainerName);
      expect(entity.lastMessage, originalModel.lastMessage);
      expect(entity.lastMessageTime, originalModel.lastMessageTime);
      expect(entity.unreadCount, originalModel.unreadCount);
      expect(entity.isTyping, originalModel.isTyping);
      expect(entity.typingUserId, originalModel.typingUserId);

      final roundTripped = ChatRoomMapper.toModel(entity);

      expect(roundTripped.id, originalModel.id);
      expect(roundTripped.guruId, originalModel.guruId);
      expect(roundTripped.trainerId, originalModel.trainerId);
      expect(roundTripped.guruName, originalModel.guruName);
      expect(roundTripped.trainerName, originalModel.trainerName);
      expect(roundTripped.lastMessage, originalModel.lastMessage);
      expect(roundTripped.lastMessageTime, originalModel.lastMessageTime);
      expect(roundTripped.unreadCount, originalModel.unreadCount);
      expect(roundTripped.isTyping, originalModel.isTyping);
      expect(roundTripped.typingUserId, originalModel.typingUserId);
    });

    test('handles null optional fields and defaults', () {
      final originalModel = model.ChatRoom(
        id: 'room_002',
        guruId: 'guru_002',
        trainerId: 'trainer_002',
        guruName: 'Guru2',
        trainerName: 'Trainer2',
      );

      final entity = ChatRoomMapper.toEntity(originalModel);
      expect(entity.lastMessage, isNull);
      expect(entity.lastMessageTime, isNull);
      expect(entity.unreadCount, 0);
      expect(entity.isTyping, false);
      expect(entity.typingUserId, isNull);

      final roundTripped = ChatRoomMapper.toModel(entity);
      expect(roundTripped.lastMessage, isNull);
      expect(roundTripped.lastMessageTime, isNull);
      expect(roundTripped.unreadCount, 0);
      expect(roundTripped.isTyping, false);
      expect(roundTripped.typingUserId, isNull);
    });
  });

  group('ScheduleMapper roundtrip', () {
    test('toEntity and toModel preserve all fields', () {
      final scheduledAt = DateTime(2025, 6, 20, 10, 0);
      final createdAt = DateTime(2025, 6, 15, 12, 0);
      final originalModel = model.Schedule(
        id: 'sched_001',
        guruId: 'guru_001',
        trainerId: 'trainer_001',
        guruName: 'DK',
        trainerName: 'Aarav',
        scheduledAt: scheduledAt,
        durationMinutes: 45,
        status: 'approved',
        notes: 'Focus on breathing',
        createdAt: createdAt,
        chatRoomId: 'room_001',
      );

      final entity = ScheduleMapper.toEntity(originalModel);

      expect(entity.id, originalModel.id);
      expect(entity.guruId, originalModel.guruId);
      expect(entity.trainerId, originalModel.trainerId);
      expect(entity.guruName, originalModel.guruName);
      expect(entity.trainerName, originalModel.trainerName);
      expect(entity.scheduledAt, originalModel.scheduledAt);
      expect(entity.durationMinutes, originalModel.durationMinutes);
      expect(entity.status, originalModel.status);
      expect(entity.notes, originalModel.notes);
      expect(entity.createdAt, originalModel.createdAt);
      expect(entity.chatRoomId, originalModel.chatRoomId);

      final roundTripped = ScheduleMapper.toModel(entity);

      expect(roundTripped.id, originalModel.id);
      expect(roundTripped.guruId, originalModel.guruId);
      expect(roundTripped.trainerId, originalModel.trainerId);
      expect(roundTripped.guruName, originalModel.guruName);
      expect(roundTripped.trainerName, originalModel.trainerName);
      expect(roundTripped.scheduledAt, originalModel.scheduledAt);
      expect(roundTripped.durationMinutes, originalModel.durationMinutes);
      expect(roundTripped.status, originalModel.status);
      expect(roundTripped.notes, originalModel.notes);
      expect(roundTripped.createdAt, originalModel.createdAt);
      expect(roundTripped.chatRoomId, originalModel.chatRoomId);
    });

    test('handles null notes and default values', () {
      final scheduledAt = DateTime(2025, 7, 1, 9, 0);
      final createdAt = DateTime(2025, 6, 25);
      final originalModel = model.Schedule(
        id: 'sched_002',
        guruId: 'guru_002',
        trainerId: 'trainer_002',
        guruName: 'Guru2',
        trainerName: 'Trainer2',
        scheduledAt: scheduledAt,
        createdAt: createdAt,
        chatRoomId: 'room_002',
      );

      final entity = ScheduleMapper.toEntity(originalModel);
      expect(entity.durationMinutes, 30);
      expect(entity.status, 'pending');
      expect(entity.notes, isNull);

      final roundTripped = ScheduleMapper.toModel(entity);
      expect(roundTripped.durationMinutes, 30);
      expect(roundTripped.status, 'pending');
      expect(roundTripped.notes, isNull);
    });
  });

  group('SessionLogMapper roundtrip', () {
    test('toEntity and toModel preserve all fields', () {
      final startedAt = DateTime(2025, 6, 15, 10, 0);
      final endedAt = DateTime(2025, 6, 15, 10, 30);
      final originalModel = model.SessionLog(
        id: 'log_001',
        scheduleId: 'sched_001',
        guruId: 'guru_001',
        trainerId: 'trainer_001',
        guruName: 'DK',
        trainerName: 'Aarav',
        startedAt: startedAt,
        endedAt: endedAt,
        durationSeconds: 1800,
        rating: 5,
        guruNotes: 'Excellent progress',
        trainerNotes: 'Good session',
        callStatus: 'completed',
      );

      final entity = SessionLogMapper.toEntity(originalModel);

      expect(entity.id, originalModel.id);
      expect(entity.scheduleId, originalModel.scheduleId);
      expect(entity.guruId, originalModel.guruId);
      expect(entity.trainerId, originalModel.trainerId);
      expect(entity.guruName, originalModel.guruName);
      expect(entity.trainerName, originalModel.trainerName);
      expect(entity.startedAt, originalModel.startedAt);
      expect(entity.endedAt, originalModel.endedAt);
      expect(entity.durationSeconds, originalModel.durationSeconds);
      expect(entity.rating, originalModel.rating);
      expect(entity.guruNotes, originalModel.guruNotes);
      expect(entity.trainerNotes, originalModel.trainerNotes);
      expect(entity.callStatus, originalModel.callStatus);

      final roundTripped = SessionLogMapper.toModel(entity);

      expect(roundTripped.id, originalModel.id);
      expect(roundTripped.scheduleId, originalModel.scheduleId);
      expect(roundTripped.guruId, originalModel.guruId);
      expect(roundTripped.trainerId, originalModel.trainerId);
      expect(roundTripped.guruName, originalModel.guruName);
      expect(roundTripped.trainerName, originalModel.trainerName);
      expect(roundTripped.startedAt, originalModel.startedAt);
      expect(roundTripped.endedAt, originalModel.endedAt);
      expect(roundTripped.durationSeconds, originalModel.durationSeconds);
      expect(roundTripped.rating, originalModel.rating);
      expect(roundTripped.guruNotes, originalModel.guruNotes);
      expect(roundTripped.trainerNotes, originalModel.trainerNotes);
      expect(roundTripped.callStatus, originalModel.callStatus);
    });

    test('handles null optional fields and defaults', () {
      final startedAt = DateTime(2025, 7, 1, 14, 0);
      final endedAt = DateTime(2025, 7, 1, 14, 20);
      final originalModel = model.SessionLog(
        id: 'log_002',
        scheduleId: 'sched_002',
        guruId: 'guru_002',
        trainerId: 'trainer_002',
        guruName: 'Guru2',
        trainerName: 'Trainer2',
        startedAt: startedAt,
        endedAt: endedAt,
        durationSeconds: 1200,
      );

      final entity = SessionLogMapper.toEntity(originalModel);
      expect(entity.rating, isNull);
      expect(entity.guruNotes, isNull);
      expect(entity.trainerNotes, isNull);
      expect(entity.callStatus, 'completed');

      final roundTripped = SessionLogMapper.toModel(entity);
      expect(roundTripped.rating, isNull);
      expect(roundTripped.guruNotes, isNull);
      expect(roundTripped.trainerNotes, isNull);
      expect(roundTripped.callStatus, 'completed');
    });
  });
}
