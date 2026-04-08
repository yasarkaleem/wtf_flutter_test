import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'session_log.g.dart';

@HiveType(typeId: 4)
class SessionLog extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String scheduleId;

  @HiveField(2)
  final String guruId;

  @HiveField(3)
  final String trainerId;

  @HiveField(4)
  final String guruName;

  @HiveField(5)
  final String trainerName;

  @HiveField(6)
  final DateTime startedAt;

  @HiveField(7)
  final DateTime endedAt;

  @HiveField(8)
  final int durationSeconds;

  @HiveField(9)
  final int? rating; // 1-5 stars, set by member

  @HiveField(10)
  final String? guruNotes;

  @HiveField(11)
  final String? trainerNotes;

  @HiveField(12)
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'scheduleId': scheduleId,
        'guruId': guruId,
        'trainerId': trainerId,
        'guruName': guruName,
        'trainerName': trainerName,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'durationSeconds': durationSeconds,
        'rating': rating,
        'guruNotes': guruNotes,
        'trainerNotes': trainerNotes,
        'callStatus': callStatus,
      };

  factory SessionLog.fromJson(Map<String, dynamic> json) => SessionLog(
        id: json['id'] as String,
        scheduleId: json['scheduleId'] as String,
        guruId: json['guruId'] as String,
        trainerId: json['trainerId'] as String,
        guruName: json['guruName'] as String,
        trainerName: json['trainerName'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: DateTime.parse(json['endedAt'] as String),
        durationSeconds: json['durationSeconds'] as int,
        rating: json['rating'] as int?,
        guruNotes: json['guruNotes'] as String?,
        trainerNotes: json['trainerNotes'] as String?,
        callStatus: json['callStatus'] as String? ?? 'completed',
      );

  @override
  List<Object?> get props => [
        id, scheduleId, guruId, trainerId, guruName, trainerName,
        startedAt, endedAt, durationSeconds, rating,
        guruNotes, trainerNotes, callStatus,
      ];
}
