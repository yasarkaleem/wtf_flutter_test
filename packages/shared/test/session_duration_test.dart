import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/session_log.dart';
import 'package:shared/utils/validators.dart';

void main() {
  group('Session Duration', () {
    test('calculates duration correctly', () {
      final start = DateTime(2026, 4, 7, 10, 0, 0);
      final end = DateTime(2026, 4, 7, 10, 30, 0);

      final duration = Validators.calculateSessionDuration(start, end);
      expect(duration, 1800); // 30 minutes in seconds
    });

    test('returns 0 for end before start', () {
      final start = DateTime(2026, 4, 7, 11, 0);
      final end = DateTime(2026, 4, 7, 10, 0);

      final duration = Validators.calculateSessionDuration(start, end);
      expect(duration, 0);
    });

    test('handles same start and end', () {
      final time = DateTime(2026, 4, 7, 10, 0);
      final duration = Validators.calculateSessionDuration(time, time);
      expect(duration, 0);
    });

    test('SessionLog.formattedDuration formats correctly', () {
      final session = SessionLog(
        id: '1',
        scheduleId: 's1',
        guruId: 'g',
        trainerId: 't',
        guruName: 'DK',
        trainerName: 'Aarav',
        startedAt: DateTime(2026, 4, 7, 10, 0),
        endedAt: DateTime(2026, 4, 7, 10, 30),
        durationSeconds: 1800,
      );

      expect(session.formattedDuration, '30m 0s');
    });

    test('SessionLog.formattedDuration with hours', () {
      final session = SessionLog(
        id: '1',
        scheduleId: 's1',
        guruId: 'g',
        trainerId: 't',
        guruName: 'DK',
        trainerName: 'Aarav',
        startedAt: DateTime(2026, 4, 7, 10, 0),
        endedAt: DateTime(2026, 4, 7, 11, 15),
        durationSeconds: 4500, // 1h 15m
      );

      expect(session.formattedDuration, '1h 15m 0s');
    });

    test('SessionLog.duration returns correct Duration', () {
      final session = SessionLog(
        id: '1',
        scheduleId: 's1',
        guruId: 'g',
        trainerId: 't',
        guruName: 'DK',
        trainerName: 'Aarav',
        startedAt: DateTime(2026, 4, 7, 10, 0),
        endedAt: DateTime(2026, 4, 7, 10, 45),
        durationSeconds: 2700,
      );

      expect(session.duration, const Duration(seconds: 2700));
      expect(session.duration.inMinutes, 45);
    });

    test('SessionLog.isWithinLast7Days works correctly', () {
      final recent = SessionLog(
        id: '1',
        scheduleId: 's1',
        guruId: 'g',
        trainerId: 't',
        guruName: 'DK',
        trainerName: 'Aarav',
        startedAt: DateTime.now().subtract(const Duration(days: 3)),
        endedAt: DateTime.now().subtract(const Duration(days: 3, hours: -1)),
        durationSeconds: 3600,
      );

      final old = SessionLog(
        id: '2',
        scheduleId: 's2',
        guruId: 'g',
        trainerId: 't',
        guruName: 'DK',
        trainerName: 'Aarav',
        startedAt: DateTime.now().subtract(const Duration(days: 10)),
        endedAt: DateTime.now().subtract(const Duration(days: 10, hours: -1)),
        durationSeconds: 3600,
      );

      expect(recent.isWithinLast7Days, true);
      expect(old.isWithinLast7Days, false);
    });

    test('SessionLog.isThisMonth works correctly', () {
      final now = DateTime.now();
      final thisMonth = SessionLog(
        id: '1',
        scheduleId: 's1',
        guruId: 'g',
        trainerId: 't',
        guruName: 'DK',
        trainerName: 'Aarav',
        startedAt: DateTime(now.year, now.month, 1, 10, 0),
        endedAt: DateTime(now.year, now.month, 1, 11, 0),
        durationSeconds: 3600,
      );

      expect(thisMonth.isThisMonth, true);
    });

    test('SessionLog copyWith updates only specified fields', () {
      final original = SessionLog(
        id: '1',
        scheduleId: 's1',
        guruId: 'g',
        trainerId: 't',
        guruName: 'DK',
        trainerName: 'Aarav',
        startedAt: DateTime(2026, 4, 7, 10, 0),
        endedAt: DateTime(2026, 4, 7, 10, 30),
        durationSeconds: 1800,
      );

      final withRating = original.copyWith(rating: 5);
      expect(withRating.rating, 5);
      expect(withRating.id, original.id);
      expect(withRating.durationSeconds, original.durationSeconds);

      final withNotes = original.copyWith(
        guruNotes: 'Great!',
        trainerNotes: 'Good progress',
      );
      expect(withNotes.guruNotes, 'Great!');
      expect(withNotes.trainerNotes, 'Good progress');
    });

    test('SessionLog toJson/fromJson roundtrip', () {
      final original = SessionLog(
        id: 'session-1',
        scheduleId: 'sched-1',
        guruId: 'guru-1',
        trainerId: 'trainer-1',
        guruName: 'DK',
        trainerName: 'Aarav',
        startedAt: DateTime(2026, 4, 7, 10, 0),
        endedAt: DateTime(2026, 4, 7, 10, 30),
        durationSeconds: 1800,
        rating: 4,
        guruNotes: 'Learned a lot',
        trainerNotes: 'Good session',
        callStatus: 'completed',
      );

      final json = original.toJson();
      final restored = SessionLog.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.durationSeconds, original.durationSeconds);
      expect(restored.rating, original.rating);
      expect(restored.guruNotes, original.guruNotes);
      expect(restored.trainerNotes, original.trainerNotes);
      expect(restored.callStatus, original.callStatus);
    });
  });
}
