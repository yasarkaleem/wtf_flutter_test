import 'dart:async';

import '../../domain/entities/entities.dart' as domain;
import '../../domain/repositories/schedule_repository.dart';
import '../../services/schedule_service.dart' as svc;
import '../mappers/schedule_mapper.dart';

/// Thin wrapper around [svc.ScheduleService] that satisfies the
/// [ScheduleRepository] contract.  Delegates every call to the existing
/// singleton and uses [ScheduleMapper] to convert between model and domain
/// types.
class ScheduleRepositoryImpl implements ScheduleRepository {
  final svc.ScheduleService _service = svc.ScheduleService.instance;

  @override
  Stream<List<domain.Schedule>> get scheduleStream =>
      _service.scheduleStream.map(
        (list) => list.map(ScheduleMapper.toEntity).toList(),
      );

  @override
  List<DateTime> getAvailableSlots(DateTime date) =>
      _service.getAvailableSlots(date);

  @override
  List<DateTime> getSchedulableDays() => _service.getSchedulableDays();

  @override
  ScheduleValidationResult validate(DateTime scheduledAt) {
    final result = _service.validate(scheduledAt);
    return ScheduleValidationResult(
      isValid: result.isValid,
      error: result.error,
    );
  }

  @override
  Future<domain.Schedule> createSchedule({
    required String guruId,
    required String trainerId,
    required String guruName,
    required String trainerName,
    required DateTime scheduledAt,
    required String chatRoomId,
    String? notes,
  }) async {
    final model = await _service.createSchedule(
      guruId: guruId,
      trainerId: trainerId,
      guruName: guruName,
      trainerName: trainerName,
      scheduledAt: scheduledAt,
      chatRoomId: chatRoomId,
      notes: notes,
    );
    return ScheduleMapper.toEntity(model);
  }

  @override
  Future<void> approveSchedule(String scheduleId) =>
      _service.approveSchedule(scheduleId);

  @override
  Future<void> declineSchedule(String scheduleId) =>
      _service.declineSchedule(scheduleId);

  @override
  Future<void> cancelSchedule(String scheduleId, String cancelledBy) =>
      _service.cancelSchedule(scheduleId, cancelledBy);

  @override
  List<domain.Schedule> getSchedulesForUser(String userId) =>
      _service.getSchedulesForUser(userId).map(ScheduleMapper.toEntity).toList();

  @override
  List<domain.Schedule> getUpcomingApproved(String userId) =>
      _service.getUpcomingApproved(userId).map(ScheduleMapper.toEntity).toList();

  @override
  void onRemoteDataChanged() => _service.onRemoteDataChanged();

  @override
  void init() => _service.init();

  @override
  void dispose() => _service.dispose();
}
