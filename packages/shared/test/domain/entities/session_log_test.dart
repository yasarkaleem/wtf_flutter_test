import 'package:flutter_test/flutter_test.dart';
import 'package:shared/domain/entities/session_log.dart';

void main() {
  final startedAt = DateTime(2026, 4, 9, 10, 0, 0);
  final endedAt = DateTime(2026, 4, 9, 10, 30, 0);

  SessionLog createSessionLog({
    String id = 'log-1',
    String scheduleId = 'sched-1',
    String guruId = 'guru-1',
    String trainerId = 'trainer-1',
    String guruName = 'Guru Alice',
    String trainerName = 'Trainer Bob',
    DateTime? startedAtOverride,
    DateTime? endedAtOverride,
    int durationSeconds = 1800,
    int? rating,
    String? guruNotes,
    String? trainerNotes,
    String callStatus = 'completed',
  }) {
    return SessionLog(
      id: id,
      scheduleId: scheduleId,
      guruId: guruId,
      trainerId: trainerId,
      guruName: guruName,
      trainerName: trainerName,
      startedAt: startedAtOverride ?? startedAt,
      endedAt: endedAtOverride ?? endedAt,
      durationSeconds: durationSeconds,
      rating: rating,
      guruNotes: guruNotes,
      trainerNotes: trainerNotes,
      callStatus: callStatus,
    );
  }

  group('SessionLog', () {
    group('formattedDuration', () {
      test('formats minutes correctly (e.g., "30m 0s")', () {
        final log = createSessionLog(durationSeconds: 1800); // 30 * 60
        expect(log.formattedDuration, '30m 0s');
      });

      test('formats minutes and seconds correctly', () {
        final log = createSessionLog(durationSeconds: 125); // 2m 5s
        expect(log.formattedDuration, '2m 5s');
      });

      test('formats zero seconds', () {
        final log = createSessionLog(durationSeconds: 0);
        expect(log.formattedDuration, '0m 0s');
      });

      test('formats hours correctly (e.g., "1h 15m 0s")', () {
        final log = createSessionLog(durationSeconds: 4500); // 1h 15m
        expect(log.formattedDuration, '1h 15m 0s');
      });

      test('formats hours with minutes and seconds', () {
        final log = createSessionLog(durationSeconds: 3661); // 1h 1m 1s
        expect(log.formattedDuration, '1h 1m 1s');
      });

      test('formats exactly one hour', () {
        final log = createSessionLog(durationSeconds: 3600);
        expect(log.formattedDuration, '1h 0m 0s');
      });

      test('formats multiple hours', () {
        final log = createSessionLog(durationSeconds: 7200); // 2h 0m 0s
        expect(log.formattedDuration, '2h 0m 0s');
      });

      test('does not include hours prefix when under one hour', () {
        final log = createSessionLog(durationSeconds: 3599); // 59m 59s
        expect(log.formattedDuration, '59m 59s');
      });
    });

    group('duration getter', () {
      test('returns correct Duration object for 1800 seconds', () {
        final log = createSessionLog(durationSeconds: 1800);
        expect(log.duration, const Duration(seconds: 1800));
        expect(log.duration.inMinutes, 30);
      });

      test('returns correct Duration object for 3661 seconds', () {
        final log = createSessionLog(durationSeconds: 3661);
        expect(log.duration, const Duration(seconds: 3661));
        expect(log.duration.inHours, 1);
        expect(log.duration.inMinutes, 61);
      });

      test('returns zero duration for 0 seconds', () {
        final log = createSessionLog(durationSeconds: 0);
        expect(log.duration, Duration.zero);
      });
    });

    group('isWithinLast7Days', () {
      test('returns true for a session that started recently', () {
        final recentStart = DateTime.now().subtract(const Duration(days: 3));
        final log = createSessionLog(
          startedAtOverride: recentStart,
          endedAtOverride: recentStart.add(const Duration(minutes: 30)),
        );
        expect(log.isWithinLast7Days, isTrue);
      });

      test('returns true for a session started just now', () {
        final now = DateTime.now();
        final log = createSessionLog(
          startedAtOverride: now,
          endedAtOverride: now.add(const Duration(minutes: 30)),
        );
        expect(log.isWithinLast7Days, isTrue);
      });

      test('returns true for a session started 6 days ago', () {
        final sixDaysAgo = DateTime.now().subtract(const Duration(days: 6));
        final log = createSessionLog(
          startedAtOverride: sixDaysAgo,
          endedAtOverride: sixDaysAgo.add(const Duration(minutes: 30)),
        );
        expect(log.isWithinLast7Days, isTrue);
      });

      test('returns false for a session started 10 days ago', () {
        final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
        final log = createSessionLog(
          startedAtOverride: tenDaysAgo,
          endedAtOverride: tenDaysAgo.add(const Duration(minutes: 30)),
        );
        expect(log.isWithinLast7Days, isFalse);
      });

      test('returns false for a session started 30 days ago', () {
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        final log = createSessionLog(
          startedAtOverride: thirtyDaysAgo,
          endedAtOverride: thirtyDaysAgo.add(const Duration(minutes: 30)),
        );
        expect(log.isWithinLast7Days, isFalse);
      });
    });

    group('isThisMonth', () {
      test('returns true for a session started this month', () {
        final now = DateTime.now();
        final thisMonthDate = DateTime(now.year, now.month, 1, 10, 0, 0);
        final log = createSessionLog(
          startedAtOverride: thisMonthDate,
          endedAtOverride: thisMonthDate.add(const Duration(minutes: 30)),
        );
        expect(log.isThisMonth, isTrue);
      });

      test('returns false for a session from last month', () {
        final now = DateTime.now();
        final lastMonth = DateTime(now.year, now.month - 1, 15, 10, 0, 0);
        final log = createSessionLog(
          startedAtOverride: lastMonth,
          endedAtOverride: lastMonth.add(const Duration(minutes: 30)),
        );
        expect(log.isThisMonth, isFalse);
      });

      test('returns false for a session from a different year', () {
        final differentYear = DateTime(2024, 1, 15, 10, 0, 0);
        final log = createSessionLog(
          startedAtOverride: differentYear,
          endedAtOverride: differentYear.add(const Duration(minutes: 30)),
        );
        expect(log.isThisMonth, isFalse);
      });
    });

    group('copyWith', () {
      test('updates rating', () {
        final log = createSessionLog(rating: null);
        final updated = log.copyWith(rating: 5);
        expect(updated.rating, 5);
      });

      test('updates guruNotes', () {
        final log = createSessionLog(guruNotes: null);
        final updated = log.copyWith(guruNotes: 'Great session');
        expect(updated.guruNotes, 'Great session');
      });

      test('updates trainerNotes', () {
        final log = createSessionLog(trainerNotes: null);
        final updated = log.copyWith(trainerNotes: 'Need more work on form');
        expect(updated.trainerNotes, 'Need more work on form');
      });

      test('updates callStatus', () {
        final log = createSessionLog(callStatus: 'completed');
        final updated = log.copyWith(callStatus: 'dropped');
        expect(updated.callStatus, 'dropped');
      });

      test('preserves unchanged fields', () {
        final log = createSessionLog(
          id: 'log-42',
          scheduleId: 'sched-5',
          guruId: 'guru-1',
          trainerId: 'trainer-1',
          durationSeconds: 1800,
          callStatus: 'completed',
        );
        final updated = log.copyWith(rating: 4);

        expect(updated.id, 'log-42');
        expect(updated.scheduleId, 'sched-5');
        expect(updated.guruId, 'guru-1');
        expect(updated.trainerId, 'trainer-1');
        expect(updated.durationSeconds, 1800);
        expect(updated.callStatus, 'completed');
        expect(updated.startedAt, startedAt);
        expect(updated.endedAt, endedAt);
      });

      test('with no arguments returns equal object', () {
        final log = createSessionLog();
        final copy = log.copyWith();
        expect(copy, equals(log));
      });
    });

    group('default values', () {
      test('rating defaults to null', () {
        final log = createSessionLog();
        expect(log.rating, isNull);
      });

      test('guruNotes defaults to null', () {
        final log = createSessionLog();
        expect(log.guruNotes, isNull);
      });

      test('trainerNotes defaults to null', () {
        final log = createSessionLog();
        expect(log.trainerNotes, isNull);
      });

      test('callStatus defaults to "completed"', () {
        final log = SessionLog(
          id: 'log-1',
          scheduleId: 'sched-1',
          guruId: 'guru-1',
          trainerId: 'trainer-1',
          guruName: 'Alice',
          trainerName: 'Bob',
          startedAt: startedAt,
          endedAt: endedAt,
          durationSeconds: 1800,
        );
        expect(log.callStatus, 'completed');
      });
    });

    group('Equatable', () {
      test('two session logs with the same properties are equal', () {
        final log1 = createSessionLog();
        final log2 = createSessionLog();
        expect(log1, equals(log2));
      });

      test('two session logs with different ids are not equal', () {
        final log1 = createSessionLog(id: 'log-1');
        final log2 = createSessionLog(id: 'log-2');
        expect(log1, isNot(equals(log2)));
      });

      test('two session logs with different ratings are not equal', () {
        final log1 = createSessionLog(rating: 3);
        final log2 = createSessionLog(rating: 5);
        expect(log1, isNot(equals(log2)));
      });

      test('two session logs with different callStatus are not equal', () {
        final log1 = createSessionLog(callStatus: 'completed');
        final log2 = createSessionLog(callStatus: 'dropped');
        expect(log1, isNot(equals(log2)));
      });

      test('props contains all fields', () {
        final log = createSessionLog();
        expect(log.props.length, 13);
      });
    });
  });
}
