import 'package:flutter_test/flutter_test.dart';
import 'package:shared/domain/entities/schedule.dart';

void main() {
  final createdAt = DateTime(2026, 4, 1, 8, 0, 0);

  Schedule createSchedule({
    String id = 'sched-1',
    String guruId = 'guru-1',
    String trainerId = 'trainer-1',
    String guruName = 'Guru Alice',
    String trainerName = 'Trainer Bob',
    DateTime? scheduledAt,
    int durationMinutes = 30,
    String status = 'pending',
    String? notes,
    DateTime? createdAtOverride,
    String chatRoomId = 'room-1',
  }) {
    return Schedule(
      id: id,
      guruId: guruId,
      trainerId: trainerId,
      guruName: guruName,
      trainerName: trainerName,
      scheduledAt: scheduledAt ?? DateTime(2026, 4, 10, 14, 0, 0),
      durationMinutes: durationMinutes,
      status: status,
      notes: notes,
      createdAt: createdAtOverride ?? createdAt,
      chatRoomId: chatRoomId,
    );
  }

  group('Schedule', () {
    group('endTime', () {
      test('is calculated as scheduledAt + durationMinutes', () {
        final schedule = createSchedule(
          scheduledAt: DateTime(2026, 4, 10, 14, 0, 0),
          durationMinutes: 30,
        );
        expect(schedule.endTime, DateTime(2026, 4, 10, 14, 30, 0));
      });

      test('works with 60-minute duration', () {
        final schedule = createSchedule(
          scheduledAt: DateTime(2026, 4, 10, 14, 0, 0),
          durationMinutes: 60,
        );
        expect(schedule.endTime, DateTime(2026, 4, 10, 15, 0, 0));
      });

      test('works with 15-minute duration', () {
        final schedule = createSchedule(
          scheduledAt: DateTime(2026, 4, 10, 14, 0, 0),
          durationMinutes: 15,
        );
        expect(schedule.endTime, DateTime(2026, 4, 10, 14, 15, 0));
      });
    });

    group('isPast', () {
      test('returns true for a schedule in the past', () {
        final schedule = createSchedule(
          scheduledAt: DateTime(2020, 1, 1, 10, 0, 0),
        );
        expect(schedule.isPast, isTrue);
      });

      test('returns false for a schedule far in the future', () {
        final schedule = createSchedule(
          scheduledAt: DateTime(2030, 12, 31, 23, 59, 59),
        );
        expect(schedule.isPast, isFalse);
      });
    });

    group('isJoinable', () {
      test('returns true when approved and within 10 minutes of start', () {
        final now = DateTime.now();
        final schedule = createSchedule(
          status: 'approved',
          scheduledAt: now.add(const Duration(minutes: 5)),
          durationMinutes: 30,
        );
        expect(schedule.isJoinable, isTrue);
      });

      test('returns true when approved and session has already started but not ended', () {
        final now = DateTime.now();
        final schedule = createSchedule(
          status: 'approved',
          scheduledAt: now.subtract(const Duration(minutes: 10)),
          durationMinutes: 30,
        );
        // started 10 min ago, ends in 20 min => joinable
        expect(schedule.isJoinable, isTrue);
      });

      test('returns true when approved and exactly at start time', () {
        final now = DateTime.now();
        final schedule = createSchedule(
          status: 'approved',
          scheduledAt: now,
          durationMinutes: 30,
        );
        expect(schedule.isJoinable, isTrue);
      });

      test('returns false when status is pending', () {
        final now = DateTime.now();
        final schedule = createSchedule(
          status: 'pending',
          scheduledAt: now.add(const Duration(minutes: 5)),
          durationMinutes: 30,
        );
        expect(schedule.isJoinable, isFalse);
      });

      test('returns false when status is declined', () {
        final now = DateTime.now();
        final schedule = createSchedule(
          status: 'declined',
          scheduledAt: now.add(const Duration(minutes: 5)),
          durationMinutes: 30,
        );
        expect(schedule.isJoinable, isFalse);
      });

      test('returns false when status is cancelled', () {
        final now = DateTime.now();
        final schedule = createSchedule(
          status: 'cancelled',
          scheduledAt: now.add(const Duration(minutes: 5)),
          durationMinutes: 30,
        );
        expect(schedule.isJoinable, isFalse);
      });

      test('returns false when approved but more than 10 minutes in the future', () {
        final now = DateTime.now();
        final schedule = createSchedule(
          status: 'approved',
          scheduledAt: now.add(const Duration(minutes: 20)),
          durationMinutes: 30,
        );
        expect(schedule.isJoinable, isFalse);
      });

      test('returns false when approved but past endTime', () {
        final now = DateTime.now();
        final schedule = createSchedule(
          status: 'approved',
          scheduledAt: now.subtract(const Duration(minutes: 60)),
          durationMinutes: 30,
        );
        // started 60 min ago, ended 30 min ago => not joinable
        expect(schedule.isJoinable, isFalse);
      });
    });

    group('conflictsWith', () {
      test('detects overlapping schedules', () {
        final schedule1 = createSchedule(
          id: 'sched-1',
          scheduledAt: DateTime(2026, 4, 10, 14, 0, 0),
          durationMinutes: 30,
        );
        final schedule2 = createSchedule(
          id: 'sched-2',
          scheduledAt: DateTime(2026, 4, 10, 14, 15, 0),
          durationMinutes: 30,
        );
        // sched-1: 14:00 - 14:30, sched-2: 14:15 - 14:45 => overlap
        expect(schedule1.conflictsWith(schedule2), isTrue);
        expect(schedule2.conflictsWith(schedule1), isTrue);
      });

      test('detects when one schedule is fully contained within another', () {
        final outer = createSchedule(
          id: 'outer',
          scheduledAt: DateTime(2026, 4, 10, 14, 0, 0),
          durationMinutes: 60,
        );
        final inner = createSchedule(
          id: 'inner',
          scheduledAt: DateTime(2026, 4, 10, 14, 15, 0),
          durationMinutes: 15,
        );
        expect(outer.conflictsWith(inner), isTrue);
        expect(inner.conflictsWith(outer), isTrue);
      });

      test('returns false for non-overlapping schedules', () {
        final schedule1 = createSchedule(
          id: 'sched-1',
          scheduledAt: DateTime(2026, 4, 10, 14, 0, 0),
          durationMinutes: 30,
        );
        final schedule2 = createSchedule(
          id: 'sched-2',
          scheduledAt: DateTime(2026, 4, 10, 15, 0, 0),
          durationMinutes: 30,
        );
        // sched-1: 14:00 - 14:30, sched-2: 15:00 - 15:30 => no overlap
        expect(schedule1.conflictsWith(schedule2), isFalse);
        expect(schedule2.conflictsWith(schedule1), isFalse);
      });

      test('returns false for back-to-back schedules (exact boundary)', () {
        final schedule1 = createSchedule(
          id: 'sched-1',
          scheduledAt: DateTime(2026, 4, 10, 14, 0, 0),
          durationMinutes: 30,
        );
        final schedule2 = createSchedule(
          id: 'sched-2',
          scheduledAt: DateTime(2026, 4, 10, 14, 30, 0),
          durationMinutes: 30,
        );
        // sched-1: 14:00 - 14:30, sched-2: 14:30 - 15:00
        // endTime of sched-1 is NOT after scheduledAt of sched-2 (they are equal)
        expect(schedule1.conflictsWith(schedule2), isFalse);
        expect(schedule2.conflictsWith(schedule1), isFalse);
      });
    });

    group('scheduleStatus getter', () {
      test('returns ScheduleStatus.pending for "pending"', () {
        final schedule = createSchedule(status: 'pending');
        expect(schedule.scheduleStatus, ScheduleStatus.pending);
      });

      test('returns ScheduleStatus.approved for "approved"', () {
        final schedule = createSchedule(status: 'approved');
        expect(schedule.scheduleStatus, ScheduleStatus.approved);
      });

      test('returns ScheduleStatus.declined for "declined"', () {
        final schedule = createSchedule(status: 'declined');
        expect(schedule.scheduleStatus, ScheduleStatus.declined);
      });

      test('returns ScheduleStatus.cancelled for "cancelled"', () {
        final schedule = createSchedule(status: 'cancelled');
        expect(schedule.scheduleStatus, ScheduleStatus.cancelled);
      });

      test('returns ScheduleStatus.pending for unknown status string', () {
        final schedule = createSchedule(status: 'unknown');
        expect(schedule.scheduleStatus, ScheduleStatus.pending);
      });
    });

    group('default values', () {
      test('durationMinutes defaults to 30', () {
        final schedule = Schedule(
          id: 'sched-1',
          guruId: 'guru-1',
          trainerId: 'trainer-1',
          guruName: 'Alice',
          trainerName: 'Bob',
          scheduledAt: DateTime(2026, 4, 10, 14, 0, 0),
          createdAt: createdAt,
          chatRoomId: 'room-1',
        );
        expect(schedule.durationMinutes, 30);
      });

      test('status defaults to "pending"', () {
        final schedule = Schedule(
          id: 'sched-1',
          guruId: 'guru-1',
          trainerId: 'trainer-1',
          guruName: 'Alice',
          trainerName: 'Bob',
          scheduledAt: DateTime(2026, 4, 10, 14, 0, 0),
          createdAt: createdAt,
          chatRoomId: 'room-1',
        );
        expect(schedule.status, 'pending');
      });

      test('notes defaults to null', () {
        final schedule = createSchedule();
        expect(schedule.notes, isNull);
      });
    });

    group('copyWith', () {
      test('updates status', () {
        final schedule = createSchedule(status: 'pending');
        final updated = schedule.copyWith(status: 'approved');
        expect(updated.status, 'approved');
      });

      test('updates notes', () {
        final schedule = createSchedule();
        final updated = schedule.copyWith(notes: 'Please review posture');
        expect(updated.notes, 'Please review posture');
      });

      test('preserves unchanged fields', () {
        final schedule = createSchedule(
          id: 'sched-42',
          guruId: 'guru-1',
          trainerId: 'trainer-1',
          durationMinutes: 45,
        );
        final updated = schedule.copyWith(status: 'approved');

        expect(updated.id, 'sched-42');
        expect(updated.guruId, 'guru-1');
        expect(updated.trainerId, 'trainer-1');
        expect(updated.durationMinutes, 45);
        expect(updated.scheduledAt, schedule.scheduledAt);
        expect(updated.createdAt, schedule.createdAt);
        expect(updated.chatRoomId, schedule.chatRoomId);
      });

      test('with no arguments returns equal object', () {
        final schedule = createSchedule();
        final copy = schedule.copyWith();
        expect(copy, equals(schedule));
      });
    });

    group('Equatable', () {
      test('two schedules with the same properties are equal', () {
        final s1 = createSchedule();
        final s2 = createSchedule();
        expect(s1, equals(s2));
      });

      test('two schedules with different ids are not equal', () {
        final s1 = createSchedule(id: 'sched-1');
        final s2 = createSchedule(id: 'sched-2');
        expect(s1, isNot(equals(s2)));
      });

      test('two schedules with different statuses are not equal', () {
        final s1 = createSchedule(status: 'pending');
        final s2 = createSchedule(status: 'approved');
        expect(s1, isNot(equals(s2)));
      });

      test('props contains all fields', () {
        final schedule = createSchedule();
        expect(schedule.props.length, 11);
      });
    });
  });
}
