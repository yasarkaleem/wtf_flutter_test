// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room.dart';

class ChatRoomAdapter extends TypeAdapter<ChatRoom> {
  @override
  final int typeId = 2;

  @override
  ChatRoom read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatRoom(
      id: fields[0] as String,
      guruId: fields[1] as String,
      trainerId: fields[2] as String,
      guruName: fields[3] as String,
      trainerName: fields[4] as String,
      lastMessage: fields[5] as String?,
      lastMessageTime: fields[6] as DateTime?,
      unreadCount: fields[7] as int? ?? 0,
      isTyping: fields[8] as bool? ?? false,
      typingUserId: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatRoom obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.lastMessage)
      ..writeByte(6)
      ..write(obj.lastMessageTime)
      ..writeByte(7)
      ..write(obj.unreadCount)
      ..writeByte(8)
      ..write(obj.isTyping)
      ..writeByte(9)
      ..write(obj.typingUserId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatRoomAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
