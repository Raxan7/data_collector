// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'technical_report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TechnicalReportAdapter extends TypeAdapter<TechnicalReport> {
  @override
  final int typeId = 64;

  @override
  TechnicalReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TechnicalReport(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      technicianName: fields[3] as String,
      reportType: fields[4] as String,
      siteId: fields[5] as String,
      createdAt: fields[6] as DateTime,
      timestamp: fields[7] as DateTime,
      fuelRemainingBefore: fields[8] as double?,
      fuelAdded: fields[9] as double?,
      genRunningHours: fields[10] as double?,
      lukuUnitsBefore: fields[12] as double?,
      lukuUnitsAfter: fields[13] as double?,
    )
      ..plcDisplayPhotoUrl = fields[11] as String?
      ..lukuBeforePhotoUrl = fields[14] as String?
      ..lukuAfterPhotoUrl = fields[15] as String?;
  }

  @override
  void write(BinaryWriter writer, TechnicalReport obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.technicianName)
      ..writeByte(4)
      ..write(obj.reportType)
      ..writeByte(5)
      ..write(obj.siteId)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.timestamp)
      ..writeByte(8)
      ..write(obj.fuelRemainingBefore)
      ..writeByte(9)
      ..write(obj.fuelAdded)
      ..writeByte(10)
      ..write(obj.genRunningHours)
      ..writeByte(11)
      ..write(obj.plcDisplayPhotoUrl)
      ..writeByte(12)
      ..write(obj.lukuUnitsBefore)
      ..writeByte(13)
      ..write(obj.lukuUnitsAfter)
      ..writeByte(14)
      ..write(obj.lukuBeforePhotoUrl)
      ..writeByte(15)
      ..write(obj.lukuAfterPhotoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TechnicalReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
