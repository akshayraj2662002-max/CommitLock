// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionModelAdapter extends TypeAdapter<SessionModel> {
  @override
  final int typeId = 0;

  @override
  SessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return SessionModel(
      id: fields[0] as String,
      habitCategory: fields[1] as String,
      plannedDurationMinutes: fields[2] as int,
      actualDurationSeconds: fields[3] as int,
      startTimestamp: fields[4] as DateTime,
      endTimestamp: fields[5] as DateTime?,
      status: fields[6] as String,
      penaltyAmount: fields[7] as double,
      restrictionLevel: fields[8] as String,
      blockedCategories: (fields[9] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SessionModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitCategory)
      ..writeByte(2)
      ..write(obj.plannedDurationMinutes)
      ..writeByte(3)
      ..write(obj.actualDurationSeconds)
      ..writeByte(4)
      ..write(obj.startTimestamp)
      ..writeByte(5)
      ..write(obj.endTimestamp)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.penaltyAmount)
      ..writeByte(8)
      ..write(obj.restrictionLevel)
      ..writeByte(9)
      ..write(obj.blockedCategories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
