import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../utils/constants.dart';
import 'log_service.dart';
import 'storage_service.dart';

enum SessionFilter { all, last7Days, thisMonth }

class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  final _uuid = const Uuid();
  final _sessionController = BehaviorSubject<List<SessionLog>>.seeded([]);

  Stream<List<SessionLog>> get sessionStream => _sessionController.stream;

  /// Create a session log after a call ends.
  Future<SessionLog> createSessionLog({
    required String scheduleId,
    required String guruId,
    required String trainerId,
    required String guruName,
    required String trainerName,
    required DateTime startedAt,
    required DateTime endedAt,
    String callStatus = 'completed',
  }) async {
    final durationSeconds = endedAt.difference(startedAt).inSeconds;

    final session = SessionLog(
      id: _uuid.v4(),
      scheduleId: scheduleId,
      guruId: guruId,
      trainerId: trainerId,
      guruName: guruName,
      trainerName: trainerName,
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      callStatus: callStatus,
    );

    await StorageService.instance.saveSessionLog(session);
    _refreshSessions();

    LogService.instance.log(
      AppConstants.tagSession,
      'Session created: ${session.id.substring(0, 8)} | Duration: ${session.formattedDuration}',
    );

    return session;
  }

  /// Add rating from member.
  Future<void> addRating(String sessionId, int rating) async {
    final storage = StorageService.instance;
    final session = storage.getSessionLog(sessionId);
    if (session == null) return;

    final updated = session.copyWith(rating: rating);
    await storage.saveSessionLog(updated);
    _refreshSessions();

    LogService.instance.log(
      AppConstants.tagSession,
      'Rating added: ${sessionId.substring(0, 8)} -> $rating stars',
    );
  }

  /// Add notes from either guru or trainer.
  Future<void> addNotes({
    required String sessionId,
    required String notes,
    required bool isTrainer,
  }) async {
    final storage = StorageService.instance;
    final session = storage.getSessionLog(sessionId);
    if (session == null) return;

    final updated = isTrainer
        ? session.copyWith(trainerNotes: notes)
        : session.copyWith(guruNotes: notes);

    await storage.saveSessionLog(updated);
    _refreshSessions();

    LogService.instance.log(
      AppConstants.tagSession,
      'Notes added to session ${sessionId.substring(0, 8)} by ${isTrainer ? "trainer" : "guru"}',
    );
  }

  /// Get filtered sessions.
  List<SessionLog> getFilteredSessions(SessionFilter filter) {
    final all = StorageService.instance.getAllSessionLogs();

    switch (filter) {
      case SessionFilter.last7Days:
        return all.where((s) => s.isWithinLast7Days).toList();
      case SessionFilter.thisMonth:
        return all.where((s) => s.isThisMonth).toList();
      case SessionFilter.all:
        return all;
    }
  }

  /// Seed demo session logs.
  Future<void> seedDemoSessions() async {
    final existing = StorageService.instance.getAllSessionLogs();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();

    final demoSessions = [
      SessionLog(
        id: _uuid.v4(),
        scheduleId: 'demo_1',
        guruId: AppConstants.guruId,
        trainerId: AppConstants.trainerId,
        guruName: AppConstants.guruName,
        trainerName: AppConstants.trainerName,
        startedAt: now.subtract(const Duration(days: 1, hours: 2)),
        endedAt: now.subtract(const Duration(days: 1, hours: 1, minutes: 30)),
        durationSeconds: 1800,
        rating: 5,
        guruNotes: 'Great session on form correction',
        trainerNotes: 'DK showed great improvement in posture',
        callStatus: 'completed',
      ),
      SessionLog(
        id: _uuid.v4(),
        scheduleId: 'demo_2',
        guruId: AppConstants.guruId,
        trainerId: AppConstants.trainerId,
        guruName: AppConstants.guruName,
        trainerName: AppConstants.trainerName,
        startedAt: now.subtract(const Duration(days: 3, hours: 4)),
        endedAt: now.subtract(const Duration(days: 3, hours: 3, minutes: 15)),
        durationSeconds: 2700,
        rating: 4,
        guruNotes: 'Learned new breathing techniques',
        callStatus: 'completed',
      ),
      SessionLog(
        id: _uuid.v4(),
        scheduleId: 'demo_3',
        guruId: AppConstants.guruId,
        trainerId: AppConstants.trainerId,
        guruName: AppConstants.guruName,
        trainerName: AppConstants.trainerName,
        startedAt: now.subtract(const Duration(days: 10)),
        endedAt: now.subtract(const Duration(days: 10)).add(const Duration(minutes: 45)),
        durationSeconds: 2700,
        rating: 5,
        trainerNotes: 'Covered advanced techniques',
        callStatus: 'completed',
      ),
    ];

    for (final session in demoSessions) {
      await StorageService.instance.saveSessionLog(session);
    }

    _refreshSessions();
    LogService.instance.log(AppConstants.tagSession, 'Demo sessions seeded');
  }

  void _refreshSessions() {
    final sessions = StorageService.instance.getAllSessionLogs();
    _sessionController.add(sessions);
  }

  void init() {
    _refreshSessions();
    LogService.instance.log(AppConstants.tagSession, 'Session service initialized');
  }

  void dispose() {
    _sessionController.close();
  }
}
