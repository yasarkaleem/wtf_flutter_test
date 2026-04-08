import 'package:flutter_test/flutter_test.dart';
import 'package:shared/utils/validators.dart';
import 'package:shared/utils/constants.dart';

void main() {
  group('Validators.validateScheduleTime', () {
    test('rejects null', () {
      final result = Validators.validateScheduleTime(null);
      expect(result, isNotNull);
      expect(result, 'Please select a time slot');
    });

    test('rejects past time', () {
      final pastTime = DateTime.now().subtract(const Duration(hours: 1));
      final result = Validators.validateScheduleTime(pastTime);
      expect(result, 'Cannot schedule in the past');
    });

    test('accepts valid future time within business hours', () {
      // Build a time that is tomorrow at 10:00 (well within business hours
      // and within the schedulable window).
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 10, 0);
      final result = Validators.validateScheduleTime(tomorrow);
      expect(result, isNull);
    });

    test('rejects time before dayStartHour', () {
      final now = DateTime.now();
      // Tomorrow at 5:00 AM -- before dayStartHour (8)
      final early = DateTime(now.year, now.month, now.day + 1, 5, 0);
      final result = Validators.validateScheduleTime(early);
      expect(result, contains('Slots available between'));
    });

    test('rejects time at or after dayEndHour', () {
      final now = DateTime.now();
      // Tomorrow at 20:00 -- at dayEndHour boundary (>= 20 is rejected)
      final late = DateTime(now.year, now.month, now.day + 1, 20, 0);
      final result = Validators.validateScheduleTime(late);
      expect(result, contains('Slots available between'));
    });

    test('rejects time beyond schedulable window', () {
      final now = DateTime.now();
      // Far in the future -- beyond schedulableDays
      final farFuture = DateTime(
        now.year,
        now.month,
        now.day + AppConstants.schedulableDays + 5,
        10,
        0,
      );
      final result = Validators.validateScheduleTime(farFuture);
      expect(
        result,
        'Can only schedule within the next ${AppConstants.schedulableDays} days',
      );
    });

    test('accepts time at dayStartHour boundary', () {
      final now = DateTime.now();
      final boundary = DateTime(now.year, now.month, now.day + 1, 8, 0);
      final result = Validators.validateScheduleTime(boundary);
      expect(result, isNull);
    });

    test('accepts time just before dayEndHour', () {
      final now = DateTime.now();
      final boundary = DateTime(now.year, now.month, now.day + 1, 19, 30);
      final result = Validators.validateScheduleTime(boundary);
      expect(result, isNull);
    });
  });

  group('Validators.validateRating', () {
    test('rejects null', () {
      expect(Validators.validateRating(null), 'Please provide a rating');
    });

    test('rejects 0', () {
      expect(Validators.validateRating(0), 'Rating must be between 1 and 5');
    });

    test('rejects 6', () {
      expect(Validators.validateRating(6), 'Rating must be between 1 and 5');
    });

    test('rejects negative number', () {
      expect(Validators.validateRating(-1), 'Rating must be between 1 and 5');
    });

    test('accepts 1', () {
      expect(Validators.validateRating(1), isNull);
    });

    test('accepts 3', () {
      expect(Validators.validateRating(3), isNull);
    });

    test('accepts 5', () {
      expect(Validators.validateRating(5), isNull);
    });
  });

  group('Validators.validateNotes', () {
    test('rejects null', () {
      expect(Validators.validateNotes(null), 'Notes cannot be empty');
    });

    test('rejects empty string', () {
      expect(Validators.validateNotes(''), 'Notes cannot be empty');
    });

    test('rejects whitespace-only string', () {
      expect(Validators.validateNotes('   '), 'Notes cannot be empty');
    });

    test('rejects string longer than 500 characters', () {
      final longNotes = 'a' * 501;
      expect(
        Validators.validateNotes(longNotes),
        'Notes must be under 500 characters',
      );
    });

    test('accepts valid notes', () {
      expect(Validators.validateNotes('Great session!'), isNull);
    });

    test('accepts notes exactly 500 characters', () {
      final exactNotes = 'a' * 500;
      expect(Validators.validateNotes(exactNotes), isNull);
    });
  });

  group('Validators.validateMessage', () {
    test('rejects null', () {
      expect(Validators.validateMessage(null), 'Message cannot be empty');
    });

    test('rejects empty string', () {
      expect(Validators.validateMessage(''), 'Message cannot be empty');
    });

    test('rejects whitespace-only string', () {
      expect(Validators.validateMessage('   '), 'Message cannot be empty');
    });

    test('rejects string longer than 2000 characters', () {
      final longMessage = 'x' * 2001;
      expect(Validators.validateMessage(longMessage), 'Message too long');
    });

    test('accepts valid message', () {
      expect(Validators.validateMessage('Hello!'), isNull);
    });

    test('accepts message exactly 2000 characters', () {
      final exactMessage = 'x' * 2000;
      expect(Validators.validateMessage(exactMessage), isNull);
    });
  });

  group('Validators.calculateSessionDuration', () {
    test('returns correct duration for normal case', () {
      final start = DateTime(2025, 1, 1, 10, 0, 0);
      final end = DateTime(2025, 1, 1, 10, 30, 0);
      expect(Validators.calculateSessionDuration(start, end), 1800);
    });

    test('returns 0 if end is before start', () {
      final start = DateTime(2025, 1, 1, 10, 30, 0);
      final end = DateTime(2025, 1, 1, 10, 0, 0);
      expect(Validators.calculateSessionDuration(start, end), 0);
    });

    test('returns 0 for same start and end', () {
      final time = DateTime(2025, 1, 1, 10, 0, 0);
      expect(Validators.calculateSessionDuration(time, time), 0);
    });

    test('handles multi-hour sessions', () {
      final start = DateTime(2025, 1, 1, 9, 0, 0);
      final end = DateTime(2025, 1, 1, 11, 15, 30);
      // 2 hours 15 minutes 30 seconds = 8130 seconds
      expect(Validators.calculateSessionDuration(start, end), 8130);
    });
  });
}
