// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_storage_service.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiagnosisHistoryItemCacheAdapter extends TypeAdapter<DiagnosisHistoryItemCache> {
  @override
  final int typeId = 2;

  @override
  DiagnosisHistoryItemCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiagnosisHistoryItemCache(
      id: fields[0] as String,
      diseaseId: fields[1] as String,
      label: fields[2] as String,
      confidence: fields[3] as double,
      localImagePath: fields[4] as String,
      cloudImageUrl: fields[5] as String?,
      createdAt: fields[6] as DateTime,
      isSynced: fields[7] as bool,
      userId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DiagnosisHistoryItemCache obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.diseaseId)
      ..writeByte(2)
      ..write(obj.label)
      ..writeByte(3)
      ..write(obj.confidence)
      ..writeByte(4)
      ..write(obj.localImagePath)
      ..writeByte(5)
      ..write(obj.cloudImageUrl)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.isSynced)
      ..writeByte(8)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagnosisHistoryItemCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
