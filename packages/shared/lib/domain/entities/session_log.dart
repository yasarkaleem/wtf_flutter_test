import 'package:equatable/equatable.dart';

enum SessionFilter { all, last7Days, thisMonth }

class SessionLog extends Equatable {
  final String id;
  final String scheduleId;
  final String guruId;
  final String trainerId;
  final String guruName;
  final String trainerName;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final int? rating; // 1-5 stars, set by member
  final String? guruNotes;
  final String? trainerNotes;
  final String callStatus; // completed, dropped, missed

  const SessionLog({
    required this.id,
    required this.scheduleId,
    required this.guruId,
    required this.trainerId,
    required this.guruName,
    required this.trainerName,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    this.rating,
    this.guruNotes,
    this.trainerNotes,
    this.callStatus = 'completed',
  });

  Duration get duration => Duration(seconds: durationSeconds);

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }

  bool get isWithinLast7Days {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    return startedAt.isAfter(sevenDaysAgo);
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return startedAt.year == now.year && startedAt.month == now.month;
  }

  SessionLog copyWith({
    String? id,
    String? scheduleId,
    String? guruId,
    String? trainerId,
    String? guruName,
    String? trainerName,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    int? rating,
    String? guruNotes,
    String? trainerNotes,
    String? callStatus,
  }) {
    return SessionLog(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      guruId: guruId ?? this.guruId,
      trainerId: trainerId ?? this.trainerId,
      guruName: guruName ?? this.guruName,
      trainerName: trainerName ?? this.trainerName,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      rating: rating ?? this.rating,
      guruNotes: guruNotes ?? this.guruNotes,
      trainerNotes: trainerNotes ?? this.trainerNotes,
      callStatus: callStatus ?? this.callStatus,
    );
  }

  @override
  List<Object?> get props => [
        id, scheduleId, guruId, trainerId, guruName, trainerName,
        startedAt, endedAt, durationSeconds, rating,
        guruNotes, trainerNotes, callStatus,
      ];
}
