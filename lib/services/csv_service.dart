import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/entry_model.dart';
import 'permission_service.dart';

class CSVService {
  static Future<String> exportToCSV(List<EntryModel> entries) async {
    try {
      // Request storage permission
      final granted = await PermissionService.requestStorage();
      if (!granted) throw Exception('Storage permission denied');

      // Prepare CSV data
      final csvData = [
        ['ID', 'Name', 'Email', 'Phone', 'Address', 'Gender', 'Created At'],
        ...entries.map((e) => [
          e.id,
          e.name,
          e.email,
          e.phone,
          e.address,
          e.gender,
          e.createdAt.toIso8601String(),
        ])
      ];

      // Get appropriate directory
      Directory directory;
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 30) {
          directory = Directory('/storage/emulated/0/Download');
        } else {
          directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Create file
      final file = File('${directory.path}/entries_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(const ListToCsvConverter().convert(csvData));
      
      return file.path;
    } catch (e) {
      print('CSV Export Error: $e');
      rethrow;
    }
  }
}