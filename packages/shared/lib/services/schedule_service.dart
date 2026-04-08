import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../utils/constants.dart';
import 'log_service.dart';
import 'storage_service.dart';
import 'chat_service.dart';
import 'sync_service.dart';

class ScheduleValidationResult {
  final bool isValid;
  final String? error;

  const ScheduleValidationResult({required this.isValid, this.error});
}

class ScheduleService {
  ScheduleService._();
  static final ScheduleService instance = ScheduleService._();

  final _uuid = const Uuid();
  final _scheduleController = BehaviorSubject<List<Schedule>>.seeded([]);

  Stream<List<Schedule>> get scheduleStream => _scheduleController.stream;

  /// Generate available time slots for a given date.
  List<DateTime> getAvailableSlots(DateTime date) {
    final slots = <DateTime>[];
    final now = DateTime.now();

    for (int hour = AppConstants.dayStartHour;
        hour < AppConstants.dayEndHour;
        hour++) {
      for (int min = 0; min < 60; min += AppConstants.slotDurationMinutes) {
        final slot = DateTime(date.year, date.month, date.day, hour, min);
        if (slot.isAfter(now)) {
          slots.add(slot);
        }
      }
    }

    return slots;
  }

  /// Get the next N schedulable days.
  List<DateTime> getSchedulableDays() {
    final days = <DateTime>[];
    final now = DateTime.now();

    for (int i = 0; i < AppConstants.schedulableDays; i++) {
      final day = DateTime(now.year, now.month, now.day).add(Duration(days: i));
      days.add(day);
    }

    return days;
  }

  /// Validate a schedule request.
  ScheduleValidationResult validate(DateTime scheduledAt) {
    final now = DateTime.now();

    if (scheduledAt.isBefore(now)) {
      return const ScheduleValidationResult(
        isValid: false,
        error: 'Cannot schedule in the past',
      );
    }

    final maxDate = DateTime(now.year, now.month, now.day)
        .add(Duration(days: AppConstants.schedulableDays));
    if (scheduledAt.isAfter(maxDate)) {
      return ScheduleValidationResult(
        isValid: false,
        error: 'Can only schedule within the next ${AppConstants.schedulableDays} days',
      );
    }

    if (scheduledAt.hour < AppConstants.dayStartHour ||
        scheduledAt.hour >= AppConstants.dayEndHour) {
      return ScheduleValidationResult(
        isValid: false,
        error: 'Slots available between ${AppConstants.dayStartHour}:00 and ${AppConstants.dayEndHour}:00',
      );
    }

    final existing = StorageService.instance.getAllSchedules();
    final newSchedule = Schedule(
      id: 'temp',
      guruId: '',
      trainerId: '',
      guruName: '',
      trainerName: '',
      scheduledAt: scheduledAt,
      createdAt: now,
      chatRoomId: '',
    );

    for (final s in existing) {
      if (s.status == 'declined' || s.status == 'cancelled') continue;
      if (s.conflictsWith(newSchedule)) {
        return const ScheduleValidationResult(
          isValid: false,
          error: 'Time slot conflicts with an existing schedule',
        );
      }
    }

    return const ScheduleValidationResult(isValid: true);
  }

  /// Create a new schedule request.
  Future<Schedule> createSchedule({
    required String guruId,
    required String trainerId,
    required String guruName,
    required String trainerName,
    required DateTime scheduledAt,
    required String chatRoomId,
    String? notes,
  }) async {
    final validation = validate(scheduledAt);
    if (!validation.isValid) {
      throw Exception(validation.error);
    }

    final schedule = Schedule(
      id: _uuid.v4(),
      guruId: guruId,
      trainerId: trainerId,
      guruName: guruName,
      trainerName: trainerName,
      scheduledAt: scheduledAt,
      notes: notes,
      createdAt: DateTime.now(),
      chatRoomId: chatRoomId,
    );

    await StorageService.instance.saveSchedule(schedule);
    _refreshSchedules();

    final timeStr =
        '${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${scheduledAt.day}/${scheduledAt.month}/${scheduledAt.year}';
    await ChatService.instance.addSystemMessage(
      chatRoomId,
      '$guruName requested a session on $dateStr at $timeStr',
    );

    // Sync to the other app
    SyncService.instance.sendSchedule(schedule);

    LogService.instance.log(
      AppConstants.tagSchedule,
      'Schedule created: ${schedule.id.substring(0, 8)} at $dateStr $timeStr',
    );

    return schedule;
  }

  /// Approve a schedule (trainer action).
  Future<void> approveSchedule(String scheduleId) async {
    final storage = StorageService.instance;
    final schedule = storage.getSchedule(scheduleId);
    if (schedule == null) return;

    final updated = schedule.copyWith(status: 'approved');
    await storage.saveSchedule(updated);
    _refreshSchedules();

    await ChatService.instance.addSystemMessage(
      schedule.chatRoomId,
      '${schedule.trainerName} approved the session request',
    );

    // Sync updated schedule to the other app
    SyncService.instance.sendSchedule(updated);

    LogService.instance.log(
      AppConstants.tagSchedule,
      'Schedule approved: ${scheduleId.substring(0, 8)}',
    );
  }

  /// Decline a schedule (trainer action).
  Future<void> declineSchedule(String scheduleId) async {
    final storage = StorageService.instance;
    final schedule = storage.getSchedule(scheduleId);
    if (schedule == null) return;

    final updated = schedule.copyWith(status: 'declined');
    await storage.saveSchedule(updated);
    _refreshSchedules();

    await ChatService.instance.addSystemMessage(
      schedule.chatRoomId,
      '${schedule.trainerName} declined the session request',
    );

    SyncService.instance.sendSchedule(updated);

    LogService.instance.log(
      AppConstants.tagSchedule,
      'Schedule declined: ${scheduleId.substring(0, 8)}',
    );
  }

  /// Cancel a schedule.
  Future<void> cancelSchedule(String scheduleId, String cancelledBy) async {
    final storage = StorageService.instance;
    final schedule = storage.getSchedule(scheduleId);
    if (schedule == null) return;

    final updated = schedule.copyWith(status: 'cancelled');
    await storage.saveSchedule(updated);
    _refreshSchedules();

    await ChatService.instance.addSystemMessage(
      schedule.chatRoomId,
      '$cancelledBy cancelled the session',
    );

    SyncService.instance.sendSchedule(updated);

    LogService.instance.log(
      AppConstants.tagSchedule,
      'Schedule cancelled: ${scheduleId.substring(0, 8)} by $cancelledBy',
    );
  }

  List<Schedule> getSchedulesForUser(String userId) {
    return StorageService.instance.getSchedulesForUser(userId);
  }

  List<Schedule> getUpcomingApproved(String userId) {
    return getSchedulesForUser(userId)
        .where((s) =>
            s.status == 'approved' && s.scheduledAt.isAfter(DateTime.now()))
        .toList();
  }

  /// Called by SyncService when a remote schedule update arrives.
  void onRemoteDataChanged() {
    _refreshSchedules();
  }

  void _refreshSchedules() {
    final schedules = StorageService.instance.getAllSchedules();
    _scheduleController.add(schedules);
  }

  void init() {
    _refreshSchedules();
    LogService.instance.log(AppConstants.tagSchedule, 'Schedule service initialized');
  }

  void dispose() {
    _scheduleController.close();
  }
}
