import 'package:equatable/equatable.dart';

enum ScheduleStatus { pending, approved, declined, cancelled }

class Schedule extends Equatable {
  final String id;
  final String guruId;
  final String trainerId;
  final String guruName;
  final String trainerName;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String status; // pending, approved, declined, cancelled
  final String? notes;
  final DateTime createdAt;
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

  /// True when the call is approved and starts within the next 10 minutes
  /// (or has already started but not yet ended).
  bool get isJoinable {
    if (status != 'approved') return false;
    final now = DateTime.now();
    final startsIn = scheduledAt.difference(now);
    return startsIn.inMinutes <= 10 && now.isBefore(endTime);
  }

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

  @override
  List<Object?> get props => [
        id, guruId, trainerId, guruName, trainerName,
        scheduledAt, durationMinutes, status, notes, createdAt, chatRoomId,
      ];
}
