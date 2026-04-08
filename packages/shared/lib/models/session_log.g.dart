// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_log.dart';

class SessionLogAdapter extends TypeAdapter<SessionLog> {
  @override
  final int typeId = 4;

  @override
  SessionLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionLog(
      id: fields[0] as String,
      scheduleId: fields[1] as String,
      guruId: fields[2] as String,
      trainerId: fields[3] as String,
      guruName: fields[4] as String,
      trainerName: fields[5] as String,
      startedAt: fields[6] as DateTime,
      endedAt: fields[7] as DateTime,
      durationSeconds: fields[8] as int,
      rating: fields[9] as int?,
      guruNotes: fields[10] as String?,
      trainerNotes: fields[11] as String?,
      callStatus: fields[12] as String? ?? 'completed',
    );
  }

  @override
  void write(BinaryWriter writer, SessionLog obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.scheduleId)
      ..writeByte(2)
      ..write(obj.guruId)
      ..writeByte(3)
      ..write(obj.trainerId)
      ..writeByte(4)
      ..write(obj.guruName)
      ..writeByte(5)
      ..write(obj.trainerName)
      ..writeByte(6)
      ..write(obj.startedAt)
      ..writeByte(7)
      ..write(obj.endedAt)
      ..writeByte(8)
      ..write(obj.durationSeconds)
      ..writeByte(9)
      ..write(obj.rating)
      ..writeByte(10)
      ..write(obj.guruNotes)
      ..writeByte(11)
      ..write(obj.trainerNotes)
      ..writeByte(12)
      ..write(obj.callStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
