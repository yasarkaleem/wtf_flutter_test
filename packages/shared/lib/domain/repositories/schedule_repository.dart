import 'dart:async';

import '../entities/entities.dart';

/// Result of validating a proposed schedule time.
class ScheduleValidationResult {
  final bool isValid;
  final String? error;

  const ScheduleValidationResult({required this.isValid, this.error});
}

/// Abstract interface for schedule (session-booking) operations.
abstract class ScheduleRepository {
  /// Stream of the current list of schedules.
  Stream<List<Schedule>> get scheduleStream;

  /// Return available time slots for the given [date].
  List<DateTime> getAvailableSlots(DateTime date);

  /// Return the next N schedulable calendar days.
  List<DateTime> getSchedulableDays();

  /// Validate whether [scheduledAt] is an acceptable time for a new schedule.
  ScheduleValidationResult validate(DateTime scheduledAt);

  /// Create a new schedule request.
  Future<Schedule> createSchedule({
    required String guruId,
    required String trainerId,
    required String guruName,
    required String trainerName,
    required DateTime scheduledAt,
    required String chatRoomId,
    String? notes,
  });

  /// Approve a pending schedule (trainer action).
  Future<void> approveSchedule(String scheduleId);

  /// Decline a pending schedule (trainer action).
  Future<void> declineSchedule(String scheduleId);

  /// Cancel an existing schedule.
  Future<void> cancelSchedule(String scheduleId, String cancelledBy);

  /// Return all schedules involving [userId].
  List<Schedule> getSchedulesForUser(String userId);

  /// Return upcoming approved schedules for [userId].
  List<Schedule> getUpcomingApproved(String userId);

  /// Notify the repository that remote data has changed (e.g. from sync).
  void onRemoteDataChanged();

  /// Refresh the internal schedule list and notify listeners.
  void init();

  /// Release resources.
  void dispose();
}
