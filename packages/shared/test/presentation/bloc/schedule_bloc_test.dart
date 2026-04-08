import 'package:flutter_test/flutter_test.dart';
import 'package:shared/presentation/bloc/schedule/schedule_bloc.dart';
import 'package:shared/domain/entities/entities.dart';

/// Helper to create a [Schedule] with sensible defaults.
Schedule _makeSchedule({
  required String id,
  required String status,
  required DateTime scheduledAt,
  int durationMinutes = 30,
}) {
  return Schedule(
    id: id,
    guruId: 'guru_1',
    trainerId: 'trainer_1',
    guruName: 'Guru',
    trainerName: 'Trainer',
    scheduledAt: scheduledAt,
    durationMinutes: durationMinutes,
    status: status,
    createdAt: DateTime(2025, 1, 1),
    chatRoomId: 'room_1',
  );
}

void main() {
  group('ScheduleState.pendingSchedules', () {
    test('filters only pending schedules', () {
      final schedules = [
        _makeSchedule(
          id: '1',
          status: 'pending',
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        ),
        _makeSchedule(
          id: '2',
          status: 'approved',
          scheduledAt: DateTime.now().add(const Duration(hours: 2)),
        ),
        _makeSchedule(
          id: '3',
          status: 'pending',
          scheduledAt: DateTime.now().add(const Duration(hours: 3)),
        ),
        _makeSchedule(
          id: '4',
          status: 'declined',
          scheduledAt: DateTime.now().add(const Duration(hours: 4)),
        ),
      ];

      final state = ScheduleState(schedules: schedules);
      final pending = state.pendingSchedules;

      expect(pending.length, 2);
      expect(pending.every((s) => s.status == 'pending'), isTrue);
      expect(pending.map((s) => s.id).toList(), ['1', '3']);
    });

    test('returns empty list when no pending schedules', () {
      final schedules = [
        _makeSchedule(
          id: '1',
          status: 'approved',
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        ),
      ];

      final state = ScheduleState(schedules: schedules);
      expect(state.pendingSchedules, isEmpty);
    });
  });

  group('ScheduleState.upcomingApproved', () {
    test('filters approved future schedules and sorts by scheduledAt', () {
      final now = DateTime.now();
      final schedules = [
        _makeSchedule(
          id: '1',
          status: 'approved',
          scheduledAt: now.add(const Duration(hours: 3)),
        ),
        _makeSchedule(
          id: '2',
          status: 'approved',
          scheduledAt: now.add(const Duration(hours: 1)),
        ),
        _makeSchedule(
          id: '3',
          status: 'pending',
          scheduledAt: now.add(const Duration(hours: 2)),
        ),
        _makeSchedule(
          id: '4',
          status: 'approved',
          scheduledAt: now.subtract(const Duration(hours: 1)),
        ),
      ];

      final state = ScheduleState(schedules: schedules);
      final upcoming = state.upcomingApproved;

      // Only id 1 and 2 are approved + future; id 4 is in the past
      expect(upcoming.length, 2);
      // Sorted: id 2 (1h from now) before id 1 (3h from now)
      expect(upcoming[0].id, '2');
      expect(upcoming[1].id, '1');
    });

    test('returns empty when no approved future schedules', () {
      final now = DateTime.now();
      final schedules = [
        _makeSchedule(
          id: '1',
          status: 'approved',
          scheduledAt: now.subtract(const Duration(hours: 1)),
        ),
        _makeSchedule(
          id: '2',
          status: 'pending',
          scheduledAt: now.add(const Duration(hours: 1)),
        ),
      ];

      final state = ScheduleState(schedules: schedules);
      expect(state.upcomingApproved, isEmpty);
    });
  });

  group('ScheduleState.imminentCall', () {
    test('returns null when no joinable schedules', () {
      final now = DateTime.now();
      final schedules = [
        // Approved but too far in the future (not joinable)
        _makeSchedule(
          id: '1',
          status: 'approved',
          scheduledAt: now.add(const Duration(hours: 2)),
        ),
        // Pending -- not joinable regardless of time
        _makeSchedule(
          id: '2',
          status: 'pending',
          scheduledAt: now.add(const Duration(minutes: 5)),
        ),
      ];

      final state = ScheduleState(schedules: schedules);
      expect(state.imminentCall, isNull);
    });

    test('returns the nearest joinable schedule', () {
      final now = DateTime.now();
      final schedules = [
        // Approved and starts in 5 minutes (joinable)
        _makeSchedule(
          id: '1',
          status: 'approved',
          scheduledAt: now.add(const Duration(minutes: 5)),
        ),
        // Approved and starts in 8 minutes (also joinable, but later)
        _makeSchedule(
          id: '2',
          status: 'approved',
          scheduledAt: now.add(const Duration(minutes: 8)),
        ),
        // Not approved
        _makeSchedule(
          id: '3',
          status: 'pending',
          scheduledAt: now.add(const Duration(minutes: 3)),
        ),
      ];

      final state = ScheduleState(schedules: schedules);
      final imminent = state.imminentCall;

      expect(imminent, isNotNull);
      expect(imminent!.id, '1');
    });

    test('returns schedule that has already started but not ended', () {
      final now = DateTime.now();
      // Started 5 minutes ago, 30-minute duration means it ends 25 min from now
      final schedules = [
        _makeSchedule(
          id: '1',
          status: 'approved',
          scheduledAt: now.subtract(const Duration(minutes: 5)),
          durationMinutes: 30,
        ),
      ];

      final state = ScheduleState(schedules: schedules);
      final imminent = state.imminentCall;

      expect(imminent, isNotNull);
      expect(imminent!.id, '1');
    });

    test('returns null for approved schedule that has already ended', () {
      final now = DateTime.now();
      // Started 40 minutes ago with 30-minute duration => ended 10 min ago
      final schedules = [
        _makeSchedule(
          id: '1',
          status: 'approved',
          scheduledAt: now.subtract(const Duration(minutes: 40)),
          durationMinutes: 30,
        ),
      ];

      final state = ScheduleState(schedules: schedules);
      expect(state.imminentCall, isNull);
    });
  });

  group('ScheduleState.copyWith', () {
    test('preserves unchanged fields', () {
      final state = ScheduleState(
        isLoading: true,
        version: 3,
        selectedDay: DateTime(2025, 6, 1),
      );

      final newState = state.copyWith(isLoading: false);

      expect(newState.isLoading, isFalse);
      expect(newState.version, 3);
      expect(newState.selectedDay, DateTime(2025, 6, 1));
    });

    test('clears error when not passed', () {
      final state = ScheduleState(error: 'Some error');
      final newState = state.copyWith(isLoading: true);
      expect(newState.error, isNull);
    });

    test('clears successMessage when not passed', () {
      final state = ScheduleState(successMessage: 'Done!');
      final newState = state.copyWith(isLoading: true);
      expect(newState.successMessage, isNull);
    });
  });
}
