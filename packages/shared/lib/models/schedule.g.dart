// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

class ScheduleAdapter extends TypeAdapter<Schedule> {
  @override
  final int typeId = 3;

  @override
  Schedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Schedule(
      id: fields[0] as String,
      guruId: fields[1] as String,
      trainerId: fields[2] as String,
      guruName: fields[3] as String,
      trainerName: fields[4] as String,
      scheduledAt: fields[5] as DateTime,
      durationMinutes: fields[6] as int? ?? 30,
      status: fields[7] as String? ?? 'pending',
      notes: fields[8] as String?,
      createdAt: fields[9] as DateTime,
      chatRoomId: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Schedule obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.guruId)
      ..writeByte(2)
      ..write(obj.trainerId)
      ..writeByte(3)
      ..write(obj.guruName)
      ..writeByte(4)
      ..write(obj.trainerName)
      ..writeByte(5)
      ..write(obj.scheduledAt)
      ..writeByte(6)
      ..write(obj.durationMinutes)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.chatRoomId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
