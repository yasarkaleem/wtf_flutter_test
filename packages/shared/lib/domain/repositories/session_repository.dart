import 'dart:async';

import '../entities/entities.dart';

/// Abstract interface for session-log operations.
abstract class SessionRepository {
  /// Stream of the current list of session logs.
  Stream<List<SessionLog>> get sessionStream;

  /// Create a session log after a call ends.
  Future<SessionLog> createSessionLog({
    required String scheduleId,
    required String guruId,
    required String trainerId,
    required String guruName,
    required String trainerName,
    required DateTime startedAt,
    required DateTime endedAt,
    String callStatus,
  });

  /// Add a member rating (1-5 stars) to the given session.
  Future<void> addRating(String sessionId, int rating);

  /// Add notes to a session (from either guru or trainer).
  Future<void> addNotes({
    required String sessionId,
    required String notes,
    required bool isTrainer,
  });

  /// Return session logs matching the given [filter].
  List<SessionLog> getFilteredSessions(SessionFilter filter);

  /// Seed demo session logs for development/testing.
  Future<void> seedDemoSessions();

  /// Refresh the internal session list and notify listeners.
  void init();

  /// Release resources.
  void dispose();
}
