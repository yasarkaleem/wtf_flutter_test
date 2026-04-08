import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'schedule.g.dart';

enum ScheduleStatus { pending, approved, declined, cancelled }

@HiveType(typeId: 3)
class Schedule extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String guruId;

  @HiveField(2)
  final String trainerId;

  @HiveField(3)
  final String guruName;

  @HiveField(4)
  final String trainerName;

  @HiveField(5)
  final DateTime scheduledAt;

  @HiveField(6)
  final int durationMinutes;

  @HiveField(7)
  final String status; // pending, approved, declined, cancelled

  @HiveField(8)
  final String? notes;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final String chatRoomId;

  const Schedule({
    required this.id,
    required this.guruId,
    required this.trainerId,
    required this.guruName,
    required this.trainerName,
    required this.scheduledAt,
    this.durationMinutes = 30,
    this.status = 'pending',
    this.notes,
    required this.createdAt,
    required this.chatRoomId,
  });

  ScheduleStatus get scheduleStatus {
    switch (status) {
      case 'approved':
        return ScheduleStatus.approved;
      case 'declined':
        return ScheduleStatus.declined;
      case 'cancelled':
        return ScheduleStatus.cancelled;
      default:
        return ScheduleStatus.pending;
    }
  }

  DateTime get endTime =>
      scheduledAt.add(Duration(minutes: durationMinutes));

  bool get isPast => scheduledAt.isBefore(DateTime.now());

  bool conflictsWith(Schedule other) {
    return scheduledAt.isBefore(other.endTime) &&
        endTime.isAfter(other.scheduledAt);
  }

  Schedule copyWith({
    String? id,
    String? guruId,
    String? trainerId,
    String? guruName,
    String? trainerName,
    DateTime? scheduledAt,
    int? durationMinutes,
    String? status,
    String? notes,
    DateTime? createdAt,
    String? chatRoomId,
  }) {
    return Schedule(
      id: id ?? this.id,
      guruId: guruId ?? this.guruId,
      trainerId: trainerId ?? this.trainerId,
      guruName: guruName ?? this.guruName,
      trainerName: trainerName ?? this.trainerName,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      chatRoomId: chatRoomId ?? this.chatRoomId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'guruId': guruId,
        'trainerId': trainerId,
        'guruName': guruName,
        'trainerName': trainerName,
        'scheduledAt': scheduledAt.toIso8601String(),
        'durationMinutes': durationMinutes,
        'status': status,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'chatRoomId': chatRoomId,
      };

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        id: json['id'] as String,
        guruId: json['guruId'] as String,
        trainerId: json['trainerId'] as String,
        guruName: json['guruName'] as String,
        trainerName: json['trainerName'] as String,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        durationMinutes: json['durationMinutes'] as int? ?? 30,
        status: json['status'] as String? ?? 'pending',
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        chatRoomId: json['chatRoomId'] as String,
      );

  @override
  List<Object?> get props => [
        id, guruId, trainerId, guruName, trainerName,
        scheduledAt, durationMinutes, status, notes, createdAt, chatRoomId,
      ];
}
