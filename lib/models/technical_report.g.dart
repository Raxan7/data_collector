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
      technicianName: fields[1] as String,
      reportType: fields[2] as String,
      siteId: fields[3] as String,
      createdAt: fields[4] as DateTime,
      timestamp: fields[5] as DateTime,
      fuelRemainingBefore: fields[6] as double?,
      fuelAdded: fields[7] as double?,
      genRunningHours: fields[8] as double?,
      plcDisplayPhotoUrl: fields[9] as String?,
      lukuUnitsBefore: fields[10] as double?,
      lukuUnitsAfter: fields[11] as double?,
      lukuBeforePhotoUrl: fields[12] as String?,
      lukuAfterPhotoUrl: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TechnicalReport obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.technicianName)
      ..writeByte(2)
      ..write(obj.reportType)
      ..writeByte(3)
      ..write(obj.siteId)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.fuelRemainingBefore)
      ..writeByte(7)
      ..write(obj.fuelAdded)
      ..writeByte(8)
      ..write(obj.genRunningHours)
      ..writeByte(9)
      ..write(obj.plcDisplayPhotoUrl)
      ..writeByte(10)
      ..write(obj.lukuUnitsBefore)
      ..writeByte(11)
      ..write(obj.lukuUnitsAfter)
      ..writeByte(12)
      ..write(obj.lukuBeforePhotoUrl)
      ..writeByte(13)
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
