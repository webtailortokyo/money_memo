// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MoneyEntryAdapter extends TypeAdapter<MoneyEntry> {
  @override
  final int typeId = 0;

  @override
  MoneyEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoneyEntry(
      amount: fields[0] as int,
      memo: fields[1] as String,
      type: fields[2] as String,
      date: fields[3] as DateTime,
      createdAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MoneyEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.memo)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoneyEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
