import 'dart:async';

import '../../domain/entities/entities.dart' as domain;
import '../../domain/repositories/session_repository.dart';
import '../../services/session_service.dart' as svc;
import '../mappers/session_log_mapper.dart';

/// Thin wrapper around [svc.SessionService] that satisfies the
/// [SessionRepository] contract.  Delegates every call to the existing
/// singleton and uses [SessionLogMapper] to convert between model and
/// domain types.
class SessionRepositoryImpl implements SessionRepository {
  final svc.SessionService _service = svc.SessionService.instance;

  @override
  Stream<List<domain.SessionLog>> get sessionStream =>
      _service.sessionStream.map(
        (list) => list.map(SessionLogMapper.toEntity).toList(),
      );

  @override
  Future<domain.SessionLog> createSessionLog({
    required String scheduleId,
    required String guruId,
    required String trainerId,
    required String guruName,
    required String trainerName,
    required DateTime startedAt,
    required DateTime endedAt,
    String callStatus = 'completed',
  }) async {
    final model = await _service.createSessionLog(
      scheduleId: scheduleId,
      guruId: guruId,
      trainerId: trainerId,
      guruName: guruName,
      trainerName: trainerName,
      startedAt: startedAt,
      endedAt: endedAt,
      callStatus: callStatus,
    );
    return SessionLogMapper.toEntity(model);
  }

  @override
  Future<void> addRating(String sessionId, int rating) =>
      _service.addRating(sessionId, rating);

  @override
  Future<void> addNotes({
    required String sessionId,
    required String notes,
    required bool isTrainer,
  }) =>
      _service.addNotes(
        sessionId: sessionId,
        notes: notes,
        isTrainer: isTrainer,
      );

  @override
  List<domain.SessionLog> getFilteredSessions(domain.SessionFilter filter) {
    // Map domain SessionFilter to service SessionFilter.
    final svcFilter = switch (filter) {
      domain.SessionFilter.all => svc.SessionFilter.all,
      domain.SessionFilter.last7Days => svc.SessionFilter.last7Days,
      domain.SessionFilter.thisMonth => svc.SessionFilter.thisMonth,
    };
    return _service
        .getFilteredSessions(svcFilter)
        .map(SessionLogMapper.toEntity)
        .toList();
  }

  @override
  Future<void> seedDemoSessions() => _service.seedDemoSessions();

  @override
  void init() => _service.init();

  @override
  void dispose() => _service.dispose();
}
