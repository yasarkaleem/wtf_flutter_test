import '../../domain/entities/session_log.dart' as domain;
import '../../models/session_log.dart' as model;

/// Maps between the domain [domain.SessionLog] entity and the
/// Hive-annotated [model.SessionLog] data model.
class SessionLogMapper {
  SessionLogMapper._();

  /// Converts a Hive [model.SessionLog] to a domain [domain.SessionLog].
  static domain.SessionLog toEntity(model.SessionLog m) {
    return domain.SessionLog(
      id: m.id,
      scheduleId: m.scheduleId,
      guruId: m.guruId,
      trainerId: m.trainerId,
      guruName: m.guruName,
      trainerName: m.trainerName,
      startedAt: m.startedAt,
      endedAt: m.endedAt,
      durationSeconds: m.durationSeconds,
      rating: m.rating,
      guruNotes: m.guruNotes,
      trainerNotes: m.trainerNotes,
      callStatus: m.callStatus,
    );
  }

  /// Converts a domain [domain.SessionLog] to a Hive [model.SessionLog].
  static model.SessionLog toModel(domain.SessionLog entity) {
    return model.SessionLog(
      id: entity.id,
      scheduleId: entity.scheduleId,
      guruId: entity.guruId,
      trainerId: entity.trainerId,
      guruName: entity.guruName,
      trainerName: entity.trainerName,
      startedAt: entity.startedAt,
      endedAt: entity.endedAt,
      durationSeconds: entity.durationSeconds,
      rating: entity.rating,
      guruNotes: entity.guruNotes,
      trainerNotes: entity.trainerNotes,
      callStatus: entity.callStatus,
    );
  }
}
