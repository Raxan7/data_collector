import 'dart:io';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/technical_report.dart';

class ExportService {
  static Future<void> exportToCSV(List<TechnicalReport> data) async {
    final csvData = [
      [
        'Technician Name', 'Report Type', 'Site ID', 'Timestamp',
        'Fuel Before', 'Fuel Added', 'Gen Hours', 'PLC Photo',
        'LUKU Before', 'LUKU After', 'Before Photo', 'After Photo'
      ],
      ...data.map((e) => [
        e.technicianName,
        e.reportType,
        e.siteId,
        e.timestamp.toIso8601String(),
        e.fuelRemainingBefore?.toString() ?? '',
        e.fuelAdded?.toString() ?? '',
        e.genRunningHours?.toString() ?? '',
        e.plcDisplayPhotoUrl ?? '',
        e.lukuUnitsBefore?.toString() ?? '',
        e.lukuUnitsAfter?.toString() ?? '',
        e.lukuBeforePhotoUrl ?? '',
        e.lukuAfterPhotoUrl ?? '',
      ]),
    ];

    final csvString = const ListToCsvConverter().convert(csvData);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/tanga_tech_report_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvString);
    await Share.shareFiles([file.path]);
  }
}