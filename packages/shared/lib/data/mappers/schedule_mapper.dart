import '../../domain/entities/schedule.dart' as domain;
import '../../models/schedule.dart' as model;

/// Maps between the domain [domain.Schedule] entity and the
/// Hive-annotated [model.Schedule] data model.
class ScheduleMapper {
  ScheduleMapper._();

  /// Converts a Hive [model.Schedule] to a domain [domain.Schedule].
  static domain.Schedule toEntity(model.Schedule m) {
    return domain.Schedule(
      id: m.id,
      guruId: m.guruId,
      trainerId: m.trainerId,
      guruName: m.guruName,
      trainerName: m.trainerName,
      scheduledAt: m.scheduledAt,
      durationMinutes: m.durationMinutes,
      status: m.status,
      notes: m.notes,
      createdAt: m.createdAt,
      chatRoomId: m.chatRoomId,
    );
  }

  /// Converts a domain [domain.Schedule] to a Hive [model.Schedule].
  static model.Schedule toModel(domain.Schedule entity) {
    return model.Schedule(
      id: entity.id,
      guruId: entity.guruId,
      trainerId: entity.trainerId,
      guruName: entity.guruName,
      trainerName: entity.trainerName,
      scheduledAt: entity.scheduledAt,
      durationMinutes: entity.durationMinutes,
      status: entity.status,
      notes: entity.notes,
      createdAt: entity.createdAt,
      chatRoomId: entity.chatRoomId,
    );
  }
}
