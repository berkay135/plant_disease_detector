// Hive adapters for Garden feature

import 'package:hive/hive.dart';
import 'plant_model.dart';

/// Hive adapter for WateringFrequency enum
class WateringFrequencyAdapter extends TypeAdapter<WateringFrequency> {
  @override
  final int typeId = 10;

  @override
  WateringFrequency read(BinaryReader reader) {
    final index = reader.readByte();
    return WateringFrequency.values[index];
  }

  @override
  void write(BinaryWriter writer, WateringFrequency obj) {
    writer.writeByte(obj.index);
  }
}

/// Hive adapter for NoteType enum
class NoteTypeAdapter extends TypeAdapter<NoteType> {
  @override
  final int typeId = 11;

  @override
  NoteType read(BinaryReader reader) {
    final index = reader.readByte();
    return NoteType.values[index];
  }

  @override
  void write(BinaryWriter writer, NoteType obj) {
    writer.writeByte(obj.index);
  }
}

/// Hive adapter for PlantModel
class PlantModelAdapter extends TypeAdapter<PlantModel> {
  @override
  final int typeId = 3;

  @override
  PlantModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlantModel(
      id: fields[0] as String,
      name: fields[1] as String,
      species: fields[2] as String?,
      location: fields[3] as String?,
      imageUrl: fields[4] as String?,
      localImagePath: fields[5] as String?,
      wateringFrequency: fields[6] as WateringFrequency? ?? WateringFrequency.weekly,
      customWateringDays: fields[7] as int?,
      lastWateredAt: fields[8] as DateTime?,
      createdAt: fields[9] as DateTime,
      userId: fields[10] as String?,
      isSynced: fields[11] as bool? ?? false,
      notificationsEnabled: fields[12] as bool? ?? true,
      notificationHour: fields[13] as int? ?? 9,
      notificationMinute: fields[14] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, PlantModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.species)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.localImagePath)
      ..writeByte(6)
      ..write(obj.wateringFrequency)
      ..writeByte(7)
      ..write(obj.customWateringDays)
      ..writeByte(8)
      ..write(obj.lastWateredAt)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.userId)
      ..writeByte(11)
      ..write(obj.isSynced)
      ..writeByte(12)
      ..write(obj.notificationsEnabled)
      ..writeByte(13)
      ..write(obj.notificationHour)
      ..writeByte(14)
      ..write(obj.notificationMinute);
  }
}

/// Hive adapter for PlantNote
class PlantNoteAdapter extends TypeAdapter<PlantNote> {
  @override
  final int typeId = 4;

  @override
  PlantNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlantNote(
      id: fields[0] as String,
      plantId: fields[1] as String,
      content: fields[2] as String,
      imageUrl: fields[3] as String?,
      localImagePath: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      userId: fields[6] as String?,
      isSynced: fields[7] as bool? ?? false,
      type: fields[8] as NoteType? ?? NoteType.general,
    );
  }

  @override
  void write(BinaryWriter writer, PlantNote obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.plantId)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.localImagePath)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.isSynced)
      ..writeByte(8)
      ..write(obj.type);
  }
}
