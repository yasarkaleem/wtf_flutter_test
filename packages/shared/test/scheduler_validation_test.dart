import 'package:flutter_test/flutter_test.dart';
import 'package:shared/utils/validators.dart';
import 'package:shared/utils/constants.dart';
import 'package:shared/models/schedule.dart';

void main() {
  group('Scheduler Validation', () {
    test('rejects past time', () {
      final pastTime = DateTime.now().subtract(const Duration(hours: 1));
      final result = Validators.validateScheduleTime(pastTime);
      expect(result, isNotNull);
      expect(result, contains('past'));
    });

    test('rejects null time', () {
      final result = Validators.validateScheduleTime(null);
      expect(result, isNotNull);
      expect(result, contains('select'));
    });

    test('accepts valid future time within business hours', () {
      // Tomorrow at 10:00 AM
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final validTime = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        10,
        0,
      );
      final result = Validators.validateScheduleTime(validTime);
      expect(result, isNull);
    });

    test('rejects time outside business hours (too early)', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final earlyTime = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        6, // Before dayStartHour (8)
        0,
      );
      final result = Validators.validateScheduleTime(earlyTime);
      expect(result, isNotNull);
      expect(result, contains('between'));
    });

    test('rejects time outside business hours (too late)', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final lateTime = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        21, // After dayEndHour (20)
        0,
      );
      final result = Validators.validateScheduleTime(lateTime);
      expect(result, isNotNull);
      expect(result, contains('between'));
    });

    test('rejects time beyond schedulable window', () {
      final farFuture = DateTime.now().add(
        Duration(days: AppConstants.schedulableDays + 5),
      );
      final result = Validators.validateScheduleTime(farFuture);
      expect(result, isNotNull);
      expect(result, contains('within'));
    });

    test('validates message is not empty', () {
      expect(Validators.validateMessage(null), isNotNull);
      expect(Validators.validateMessage(''), isNotNull);
      expect(Validators.validateMessage('   '), isNotNull);
      expect(Validators.validateMessage('Hello'), isNull);
    });

    test('validates message length limit', () {
      final longMessage = 'a' * 2001;
      expect(Validators.validateMessage(longMessage), isNotNull);
    });

    test('validates rating range', () {
      expect(Validators.validateRating(null), isNotNull);
      expect(Validators.validateRating(0), isNotNull);
      expect(Validators.validateRating(6), isNotNull);
      expect(Validators.validateRating(1), isNull);
      expect(Validators.validateRating(5), isNull);
      expect(Validators.validateRating(3), isNull);
    });

    test('validates notes', () {
      expect(Validators.validateNotes(null), isNotNull);
      expect(Validators.validateNotes(''), isNotNull);
      expect(Validators.validateNotes('Great session'), isNull);
      expect(Validators.validateNotes('a' * 501), isNotNull);
    });
  });

  group('Schedule Model - Conflict Detection', () {
    test('detects overlapping schedules', () {
      final now = DateTime.now();
      final s1 = Schedule(
        id: '1',
        guruId: 'g',
        trainerId: 't',
        guruName: 'G',
        trainerName: 'T',
        scheduledAt: now,
        durationMinutes: 30,
        createdAt: now,
        chatRoomId: 'r',
      );
      final s2 = Schedule(
        id: '2',
        guruId: 'g',
        trainerId: 't',
        guruName: 'G',
        trainerName: 'T',
        scheduledAt: now.add(const Duration(minutes: 15)),
        durationMinutes: 30,
        createdAt: now,
        chatRoomId: 'r',
      );

      expect(s1.conflictsWith(s2), true);
      expect(s2.conflictsWith(s1), true);
    });

    test('no conflict for non-overlapping schedules', () {
      final now = DateTime.now();
      final s1 = Schedule(
        id: '1',
        guruId: 'g',
        trainerId: 't',
        guruName: 'G',
        trainerName: 'T',
        scheduledAt: now,
        durationMinutes: 30,
        createdAt: now,
        chatRoomId: 'r',
      );
      final s2 = Schedule(
        id: '2',
        guruId: 'g',
        trainerId: 't',
        guruName: 'G',
        trainerName: 'T',
        scheduledAt: now.add(const Duration(hours: 1)),
        durationMinutes: 30,
        createdAt: now,
        chatRoomId: 'r',
      );

      expect(s1.conflictsWith(s2), false);
      expect(s2.conflictsWith(s1), false);
    });

    test('no conflict for back-to-back schedules', () {
      final now = DateTime.now();
      final s1 = Schedule(
        id: '1',
        guruId: 'g',
        trainerId: 't',
        guruName: 'G',
        trainerName: 'T',
        scheduledAt: now,
        durationMinutes: 30,
        createdAt: now,
        chatRoomId: 'r',
      );
      final s2 = Schedule(
        id: '2',
        guruId: 'g',
        trainerId: 't',
        guruName: 'G',
        trainerName: 'T',
        scheduledAt: now.add(const Duration(minutes: 30)),
        durationMinutes: 30,
        createdAt: now,
        chatRoomId: 'r',
      );

      expect(s1.conflictsWith(s2), false);
    });

    test('endTime is calculated correctly', () {
      final base = DateTime(2026, 4, 7, 10, 0);
      final s = Schedule(
        id: '1',
        guruId: 'g',
        trainerId: 't',
        guruName: 'G',
        trainerName: 'T',
        scheduledAt: base,
        durationMinutes: 30,
        createdAt: base,
        chatRoomId: 'r',
      );

      expect(s.endTime, DateTime(2026, 4, 7, 10, 30));
    });
  });
}
